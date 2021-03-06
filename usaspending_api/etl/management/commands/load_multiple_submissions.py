import logging

from django.conf import settings
from django.core.management import call_command
from django.core.management.base import BaseCommand
from django.db import connection
from usaspending_api.common.helpers.date_helper import datetime_command_line_argument_type
from usaspending_api.etl.management.helpers.load_submission import (
    calculate_load_submissions_since_datetime,
    get_publish_history_table,
)


logger = logging.getLogger("script")


class Command(BaseCommand):
    def add_arguments(self, parser):
        mutually_exclusive_group = parser.add_mutually_exclusive_group(required=True)
        mutually_exclusive_group.add_argument(
            "--submission-ids",
            help=("Optionally supply one or more Broker submission_ids to be created or updated."),
            nargs="+",
            type=int,
        )
        mutually_exclusive_group.add_argument(
            "--incremental", action="store_true", help="Loads newly created or updated submissions.",
        )
        mutually_exclusive_group.add_argument(
            "--start-datetime",
            type=datetime_command_line_argument_type(naive=True),  # Broker date/times are naive.
            help=(
                "Manually set the date from which to start loading submissions.  This was originally designed "
                "to be used for testing, but there are definitely real world usages for it... just be careful."
            ),
        )
        parser.add_argument(
            "--list-ids-only",
            action="store_true",
            help="Only list submissions to be loaded.  Do not actually load them.",
        )

    def handle(self, *args, **options):

        if options["submission_ids"]:
            submission_ids = options["submission_ids"]
        else:
            submission_ids = self.get_incremental_submission_ids(options.get("start_datetime"))

        if submission_ids:
            msg = f"{len(submission_ids):,} submissions will be created or updated"
            if len(submission_ids) <= 1000:
                logger.info(f"The following {msg}: {submission_ids}")
            else:
                logger.info(f"{msg}.")
            if options["list_ids_only"]:
                logger.info("Exiting script before data load occurs in accordance with the --list-ids-only flag.")
                return
        else:
            logger.info("There are no new or updated submissions to load.")
            return

        failed_submissions = []
        for submission_id in submission_ids:
            try:
                call_command("load_submission", submission_id)
            except (Exception, SystemExit):
                logger.exception(f"Submission {submission_id} failed to load")
                failed_submissions.append(submission_id)

        if failed_submissions:
            logger.error(
                f"Script completed with the following {len(failed_submissions):,} "
                f"submission failures: {failed_submissions}"
            )
            raise SystemExit(3)
        else:
            logger.info("Script completed with no failures.")

    @staticmethod
    def get_since_sql(start_datetime=None):
        """
        For performance reasons, we intentionally use updated_at here even though we're comparing against
        published_date later.  submission.updated_at should always be greater than or equal to published_date.
        """
        since = start_datetime or calculate_load_submissions_since_datetime()
        if since is None:
            logger.info("No records found in submission_attributes.  Performing a full load.")
            since = ""
        else:
            logger.info(f"Performing incremental load starting from {since}.")
            since = f"and s.updated_at >= ''{since}''::timestamp"
        return since

    @classmethod
    def get_incremental_submission_ids(cls, start_datetime=None):
        # Note that this is designed to work with our conservative lookback period by filtering
        # out rows that haven't changed.  Look back as far as you want!
        sql = f"""
            select
                bs.submission_id
            from
                dblink(
                    '{settings.DATA_BROKER_DBLINK_NAME}',
                    '
                        select
                            s.submission_id,
                            (
                                select  max(updated_at)
                                from    {get_publish_history_table()}
                                where   submission_id = s.submission_id
                            ) as published_date,
                            (
                                select  max(updated_at)
                                from    certify_history
                                where   submission_id = s.submission_id
                            ) as certified_date,
                            coalesce(s.cgac_code, s.frec_code) as toptier_code,
                            s.reporting_start_date,
                            s.reporting_end_date,
                            s.reporting_fiscal_year,
                            s.reporting_fiscal_period,
                            s.is_quarter_format
                        from
                            submission as s
                        where
                            s.d2_submission is false and
                            s.publish_status_id in (2, 3)
                            {cls.get_since_sql(start_datetime)}
                    '
                ) as bs (
                    submission_id integer,
                    published_date timestamp,
                    certified_date timestamp,
                    toptier_code text,
                    reporting_start_date date,
                    reporting_end_date date,
                    reporting_fiscal_year integer,
                    reporting_fiscal_period integer,
                    is_quarter_format boolean
                )
                left outer join submission_attributes sa on
                    sa.submission_id = bs.submission_id and
                    sa.published_date::timestamp is not distinct from bs.published_date and
                    sa.certified_date::timestamp is not distinct from bs.certified_date and
                    sa.toptier_code is not distinct from bs.toptier_code and
                    sa.reporting_period_start is not distinct from bs.reporting_start_date and
                    sa.reporting_period_end is not distinct from bs.reporting_end_date and
                    sa.reporting_fiscal_year is not distinct from bs.reporting_fiscal_year and
                    sa.reporting_fiscal_period is not distinct from bs.reporting_fiscal_period and
                    sa.quarter_format_flag is not distinct from bs.is_quarter_format
            where
                sa.submission_id is null
            order by
                bs.published_date,
                bs.submission_id
        """
        with connection.cursor() as cursor:
            cursor.execute(sql)
            return [s[0] for s in cursor.fetchall()]
