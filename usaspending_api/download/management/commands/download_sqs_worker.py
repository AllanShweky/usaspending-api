import logging
import time
import traceback

from django.core.management.base import BaseCommand

from usaspending_api.common.sqs.sqs_handler import get_sqs_queue
from usaspending_api.common.sqs.sqs_work_dispatcher import SQSWorkDispatcher, QueueWorkerProcessError
from usaspending_api.download.filestreaming.download_generation import generate_download
from usaspending_api.common.sqs.sqs_job_logging import log_job_message
from usaspending_api.download.helpers.monthly_helpers import download_job_to_log_dict
from usaspending_api.download.lookups import JOB_STATUS_DICT
from usaspending_api.download.models import DownloadJob

logger = logging.getLogger(__name__)
JOB_TYPE = "USAspendingDownloader"


class Command(BaseCommand):
    def handle(self, *args, **options):
        queue = get_sqs_queue()

        log_job_message(
            logger=logger, message="Starting SQS polling", job_type=JOB_TYPE,
        )
        keep_polling = True
        while keep_polling:
            # Setup dispatcher that coordinates job activity on SQS
            dispatcher = SQSWorkDispatcher(queue, worker_process_name=JOB_TYPE, worker_can_start_child_processes=True,)

            try:

                # Check the queue for work
                message_found = dispatcher.dispatch(download_service_app)

                # Mark the job as failed if there was an error processing the download, if retries after interrupt
                # are not allowed, or if all retries have been exhausted
                # If the job is interrupted by an OS signal, the dispatcher's signal handling logic will log and
                # handle this case
                # Retries are allowed or denied by the SQS queue's RedrivePolicy config (maxReceiveCount > 1 = retries)
                # - if queue retries are allowed, the queue message will retry to the max allowed by the queue
                # - As coded, no cleanup should be needed to retry a download
                #   - the psql -o will overwrite the output file
                #   - the zip will use 'w' write mode to create from scratch each time
                # The worker function controls the maximum allowed runtime of the job

            except QueueWorkerProcessError as exc:
                # This means an error occurred in the job-processing code
                # Try to mark the job as failed, but continue raising the original Exception if not possible
                # This has likely already been set on the job from within error-handling code of the target of the
                # worker process, but this is here to for redundancy. Do not set an error
                try:
                    if exc.queue_message and exc.queue_message.body:
                        download_job_id = int(exc.queue_message.body)
                        stack_trace = "".join(
                            traceback.format_exception(etype=type(exc), value=exc, tb=exc.__traceback__)
                        )
                        _update_download_job_status(download_job_id, "failed", stack_trace)
                except:
                    pass
                raise exc

            # When you receive an empty response from the queue, wait before trying again
            if not message_found:
                time.sleep(1)

            # If this process is exiting, don't poll for more work
            keep_polling = not dispatcher.is_exiting


def download_service_app(download_job_id):
    download_job = _retrieve_download_job_from_db(download_job_id)
    log_job_message(
        logger=logger,
        message="Starting processing of download request",
        job_type=JOB_TYPE,
        job_id=download_job_id,
        other_params=download_job_to_log_dict(download_job),
    )
    generate_download(download_job=download_job)


def _retrieve_download_job_from_db(download_job_id):
    download_job = DownloadJob.objects.filter(download_job_id=download_job_id).first()

    if download_job is None:
        raise DownloadJobNoneError(download_job_id)

    return download_job


def _update_download_job_status(download_job_id, status, error_message=None, overwrite_error_message=False):
    """Handles status updates on the DownloadJob records

    Args:
        download_job_id (int): id of the DownloadJob record being processed
        status (str): a status key to JOB_STATUS_DICT dictionary
        error_message (str): error message to potentially apply to the DownloadJob record if
            ``overwrite_error_message`` is True or if there is no prior error message on the record
        overwrite_error_message (bool): if explicitly set to True, and error_message is not None, the provided error
            message will overwrite an existing error message on the DownloadJob object. By default it will not.
    """
    download_job = _retrieve_download_job_from_db(download_job_id)

    download_job.job_status_id = JOB_STATUS_DICT[status]
    if overwrite_error_message or (error_message and not download_job.error_message):
        download_job.error_message = str(error_message) if error_message else None

    download_job.save()


class DownloadJobNoneError(ValueError):
    """ Custom fatal exception representing the scenario where the DownloadJob object to be processed does not
        exist in the database with the given ID.
    """

    def __init__(self, download_job_id, *args, **kwargs):
        default_message = f"DownloadJob with id = {download_job_id} was not found in the database."

        if args or kwargs:
            super().__init__(*args, **kwargs)
        else:
            super().__init__(default_message)
        self.download_job_id = download_job_id
