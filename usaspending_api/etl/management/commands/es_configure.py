import json
import subprocess

from django.core.management.base import BaseCommand

from usaspending_api import settings
from usaspending_api.etl.es_etl_helpers import VIEW_COLUMNS, AWARD_VIEW_COLUMNS

CURL_STATEMENT = 'curl -XPUT "{url}" -H "Content-Type: application/json" -d \'{data}\''

CURL_COMMANDS = {
    "template": "{host}/_template/{name}?pretty",
    "cluster": "{host}/_cluster/settings?pretty",
    "settings": "{host}/_settings?pretty",
}

FILES = {
    "transaction_template": settings.APP_DIR / "etl" / "es_transaction_template.json",
    "award_template": settings.APP_DIR / "etl" / "es_award_template.json",
    "settings": settings.APP_DIR / "etl" / "es_config_objects.json",
}


class Command(BaseCommand):
    help = """
    This script applies configuration changes to an Elasticsearch cluster.
    Requires env var ES_HOSTNAME to be set
    """

    def add_arguments(self, parser):
        parser.add_argument(
            "--awards",
            action="store_true",
            help="When this flag is set, will create an awards type index instead of a transaction type index.",
        )
        parser.add_argument(
            "--template-only",
            action="store_true",
            help="When this flag is set, skip the cluster and index settings. Useful when creating a new index",
        )

    def handle(self, *args, **options):
        if not settings.ES_HOSTNAME:
            raise SystemExit("Fatal error: $ES_HOSTNAME is not set.")
        if options["awards"]:
            self.awards = True
        else:
            self.awards = False
        cluster, index_settings = self.get_elasticsearch_settings()
        template = self.get_index_template()

        if not options["template_only"]:
            self.run_curl_cmd(payload=cluster, url=CURL_COMMANDS["cluster"], host=settings.ES_HOSTNAME)
            self.run_curl_cmd(payload=index_settings, url=CURL_COMMANDS["settings"], host=settings.ES_HOSTNAME)

        template_name = "{type}_template".format(type="award" if self.awards else "transaction")

        self.run_curl_cmd(
            payload=template, url=CURL_COMMANDS["template"], host=settings.ES_HOSTNAME, name=template_name
        )

    def run_curl_cmd(self, **kwargs):
        url = kwargs["url"].format(**kwargs)
        cmd = CURL_STATEMENT.format(url=url, data=json.dumps(kwargs["payload"]))
        print("Running: {}\n\n".format(cmd))

        subprocess.Popen(cmd, shell=True).wait()
        print("\n\n---------------------------------------------------------------")
        return

    def get_elasticsearch_settings(self):
        es_config = self.return_json_from_file(FILES["settings"])
        es_config["settings"]["index.max_result_window"] = settings.ES_TRANSACTIONS_MAX_RESULT_WINDOW
        return es_config["cluster"], es_config["settings"]

    def get_index_template(self):
        template = self.return_json_from_file(
            FILES["{view}_template".format(view="award" if self.awards else "transaction")]
        )
        template["index_patterns"] = [
            "*{}".format(settings.ES_AWARDS_NAME_SUFFIX if self.awards else settings.ES_TRANSACTIONS_NAME_SUFFIX)
        ]
        template["settings"]["index.max_result_window"] = (
            settings.ES_AWARDS_MAX_RESULT_WINDOW if self.awards else settings.ES_TRANSACTIONS_MAX_RESULT_WINDOW
        )
        self.validate_known_fields(template)
        return template

    def return_json_from_file(self, path):
        """Read and parse file as JSON

        Library performs JSON validation which is helpful before sending to ES
        """
        filepath = str(path)
        if not path.exists():
            raise SystemExit("Fatal error: file {} does not exist.".format(filepath))

        print("Reading file: {}".format(filepath))
        with open(filepath, "r") as f:
            json_to_dict = json.load(f)

        return json_to_dict

    def validate_known_fields(self, template):
        defined_fields = set(
            [
                field
                for field in template["mappings"][
                    "{view}_mapping".format(view="award" if self.awards else "transaction")
                ]["properties"]
            ]
        )
        load_columns = set(AWARD_VIEW_COLUMNS) if self.awards else set(VIEW_COLUMNS)
        if defined_fields ^ load_columns:  # check if any fields are not in both sets
            raise RuntimeError("Mismatch between template and fields in ETL! Resolve before continuing!")


def retrieve_transaction_index_template():
    """This function is used for test configuration"""
    with open(str(FILES["{}_template".format("transaction")])) as f:
        mapping_dict = json.load(f)
        template = json.dumps(mapping_dict)

    return template
