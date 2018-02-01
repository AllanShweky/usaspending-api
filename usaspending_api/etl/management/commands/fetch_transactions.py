import boto3
import os
import pandas as pd
import pytz
import subprocess
import tempfile

from datetime import date
from datetime import datetime
from django.core.management.base import BaseCommand
from django.db import connection
from time import perf_counter

# SCRIPT OBJECTIVES and ORDER OF EXECUTION STEPS
# 1. [conditional] Gather the list of deleted transactions from S3
# 2. Create temporary view of transaction records
# 3. Copy/dump transaction rows to CSV file
# 4. [conditional] Compare row IDs to see if a "deleted" transaction is back and remove from list
# 5. [conditional] Store deleted ids in separate file
#    (possible future step) Transfer output csv files to S3


class Command(BaseCommand):
    help = '''
    This script is to gather a single fiscal year of transaction records as a CSV file

    (example: 2018_transactions_20180121T195109Z.csv).

    If the option parameter `--award-type` is provided then the transactions CSV will only have
    transactions of that award type.

    If the optional parameter `-d` is used, a second CSV file will be generated of deleted transactions
    (example: deleted_ids_20180121T200832Z.csv).

    To customize a delta of added/modified transactions from a specific date to present datetime use `--since`
    '''

    # used by parent class
    def add_arguments(self, parser):
        parser.add_argument(
            'fiscal_year',
            type=int,
            help='Desired fiscal year of retrieved transactions')
        parser.add_argument(
            '--since',
            default='2001-01-01',
            type=str,
            help='Start date for computing the delta of changed transactions [YYYY-MM-DD]')
        parser.add_argument(
            '--dir',
            default=os.path.dirname(os.path.abspath(__file__)),
            type=str,
            help='Set for a custom location of output files')
        parser.add_argument(
            '-d',
            '--deleted',
            action='store_true',
            help='Flag to include deleted transactions into script results')
        parser.add_argument(
            '--sql-only',
            action='store_true',
            help='Prints SQL which would be used with the provided flags')
        parser.add_argument(
            '--award-type',
            choices=['contract', 'grant', 'loans', 'direct payment', 'other'],
            type=str,
            default=None,
            help='If this flag is used the CSV will only have transactions of this award category description')

    # used by parent class
    def handle(self, *args, **options):
        ''' Script execution of custom code starts in this method'''
        start = perf_counter()

        self.config = set_config()
        self.config['formatted_now'] = datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')  # ISO8601
        self.config['verbose'] = True if options['verbosity'] > 1 else False
        self.config['fiscal_year'] = options['fiscal_year']
        self.config['directory'] = options['dir'] + os.sep
        self.config['provide_deleted'] = options['deleted']
        self.config['award_category'] = options['award_type']

        try:
            self.config['starting_date'] = date(*[int(x) for x in options['since'].split('-')])
        except Exception:
            print('Malformed date string provided. `--since` requires YYYY-MM-DD')
            raise SystemExit

        if not os.path.isdir(self.config['directory']):
            print('Provided directory does not exist')
            raise SystemExit

        if options['sql_only']:
            self.sql_only_print()
            return

        self.deleted_ids = gather_deleted_ids(self.config)
        self.db_interactions()
        self.write_deleted_ids()

        print('---------------------------------------------------------------')
        print("Script completed in {} seconds".format(perf_counter() - start))

    def sql_only_print(self):
        self.deleted_ids = {
            '<id0>': {'timestamp': '1970-01-01'},
            '<id1>': {'timestamp': '1970-01-01'},
            '<id2>': {'timestamp': '1970-01-01'},
        }
        filename = self.config['directory'] + '<filename>'

        view, copy_sql, ids, count_sql, drop_view = configure_sql_strings(self.config, filename, self.deleted_ids)
        print('========================================')
        print('--- Postgres View SQL ---')
        print(view)
        print('========================================')
        print('--- SQL to copy rows to CSV ---')
        print(copy_sql)
        print('========================================')
        print('--- SQL to gather all existing transactions in deleted list ---')
        if not ids:
            ids = '*** No ID SQL generated with provided script flags ***'
        print(ids)
        print('========================================')
        print('--- Drop SQL ---')
        print(drop_view)

    def db_interactions(self):
        '''
        All DB statements/commands/transactions are controlled by this method.
        Some are using the django DB client, others using psql
        '''
        print('---------------------------------------------------------------')
        print('Executing Postgres statements')
        start = perf_counter()
        type_str = ''
        if self.config['award_category']:
            type_str = '{}_'.format(self.config['award_category'])
        filename = '{dir}{fy}_transactions_{type}{now}.csv'.format(
            dir=self.config['directory'],
            fy=self.config['fiscal_year'],
            type=type_str,
            now=self.config['formatted_now'])
        view_sql, copy_sql, ids, count_sql, drop_view = configure_sql_strings(self.config, filename, self.deleted_ids)

        execute_sql_statement(view_sql, False, self.config['verbose'])

        count = execute_sql_statement(count_sql, True, self.config['verbose'])
        print('\nWriting {} transactions to this file:'.format(count[0]['count']))
        print(filename)
        # It is preferable to not use shell=True, but this command works. Limited user-input so risk is low
        subprocess.Popen('psql "${{DATABASE_URL}}" -c {}'.format(copy_sql), shell=True).wait()

        if ids:
            restored_ids = execute_sql_statement(ids, True, self.config['verbose'])
            if self.config['verbose']:
                print(restored_ids)
            print('{} "deleted" IDs were found in DB'.format(len(restored_ids)))
            self.correct_deleted_ids(restored_ids)

        execute_sql_statement(drop_view, False, self.config['verbose'])
        print("Database interactions took {} seconds".format(perf_counter() - start))

    def correct_deleted_ids(self, existing_ids):
        '''
            This function removeds transactions from the deleted list.
            Necessary for when a transaction was previously deleted and then recreted
        '''
        print('Verifying deleted transactions')
        count = 0
        for record in existing_ids:
            uid = record['generated_unique_transaction_id']
            if uid in self.deleted_ids:
                if record['update_date'] > self.deleted_ids[uid]['timestamp']:
                    # Remove recreated transaction from the final list
                    del self.deleted_ids[uid]
                    count += 1
        print('Removed {} IDs from list'.format(count))

    def write_deleted_ids(self):
        ''' Write the list of deleted (and not recreated) transactions to disk'''
        print('---------------------------------------------------------------')
        if not self.config['provide_deleted']:
            print('Skipping deleted transactions output')
            return
        print('There are {} transaction records to delete'.format(len(self.deleted_ids)))
        print('Writing deleted transactions csv. Filepath:')
        csv_file = self.config['directory'] + 'deleted_ids_{}.csv'.format(self.config['formatted_now'])
        print(csv_file)

        with open(csv_file, 'w') as f:
            f.write('generated_unique_transaction_id\n')
            f.writelines('\n'.join(self.deleted_ids.keys()))


def db_rows_to_dict(cursor):
    ''' Return a dictionary of all row results from a database connection cursor '''
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]


def execute_sql_statement(cmd, results=False, verbose=False):
    ''' Simple function to execute SQL using the Django DB connection'''
    rows = None
    if verbose:
        print(cmd)
    with connection.cursor() as cursor:
        cursor.execute(cmd)
        if results:
            rows = db_rows_to_dict(cursor)
    return rows


def configure_sql_strings(config, filename, deleted_ids):
    '''
    Populates the formatted strings defined globally in this file to create the desired SQL
    '''
    update_date_str = UPDATE_DATE_SQL.format(config['starting_date'].strftime('%Y-%m-%d'))
    award_type_str = ''
    if config['award_category']:
        if config['award_category'] == 'contract':
            award_type_str = CONTRACTS_IDV_SQL.format(config['award_category'])
        else:
            award_type_str = CATEGORY_SQL.format(config['award_category'])

    view_sql = TEMP_ES_DELTA_VIEW

    copy_sql = COPY_SQL.format(
        fy=config['fiscal_year'],
        update_date=update_date_str,
        award_category=award_type_str,
        filename=filename)

    count_sql = COUNT_SQL.format(
        fy=config['fiscal_year'],
        update_date=update_date_str,
        award_category=award_type_str,
    )

    if deleted_ids and config['provide_deleted']:
        id_list = ','.join(["('{}')".format(x) for x in deleted_ids.keys()])
        id_sql = CHECK_IDS_SQL.format(id_list=id_list)
    else:
        id_sql = None

    drop_view = DROP_VIEW_SQL

    return view_sql, copy_sql, id_sql, count_sql, drop_view


def set_config():

    if not os.environ.get('CSV_AWS_REGION'):
        print('Missing environment variable `CSV_AWS_REGION`')
        raise SystemExit

    if not os.environ.get('DELETED_TRANSACTIONS_S3_BUCKET_NAME'):
        print('Missing environment variable `DELETED_TRANSACTIONS_S3_BUCKET_NAME`')
        raise SystemExit

    if not os.environ.get('DATABASE_URL'):
        print('Missing environment variable `DATABASE_URL`')
        raise SystemExit

    config = {
        'aws_region': os.environ.get('CSV_AWS_REGION'),
        's3_bucket': os.environ.get('DELETED_TRANSACTIONS_S3_BUCKET_NAME')
    }

    return config


def gather_deleted_ids(config):
    '''
    Connect to S3 and gather all of the transaction ids stored in CSV files
    generated by the broker when transactions are removed from the DB.
    '''
    print('---------------------------------------------------------------')
    if not config['provide_deleted']:
        print('Skipping the S3 CSV fetch for deleted transactions')
        return
    print('Gathering all deleted transactions from S3')
    start = perf_counter()
    try:
        s3 = boto3.resource('s3', region_name=config['aws_region'])
        bucket = s3.Bucket(config['s3_bucket'])
        bucket_objects = list(bucket.objects.all())
    except Exception as e:
        print('\n[ERROR]\n')
        print('Verify settings.CSV_AWS_REGION and settings.DELETED_TRANSACTIONS_S3_BUCKET_NAME are correct')
        print('  or is using env variables: CSV_AWS_REGION and DELETED_TRANSACTIONS_S3_BUCKET_NAME')
        print('\n{}\n'.format(e))
        raise SystemExit

    if config['verbose']:
        print('CSV data from {} to now.'.format(config['starting_date']))

    to_datetime = datetime.combine(config['starting_date'], datetime.min.time(), tzinfo=pytz.UTC)
    filtered_csv_list = [
        x for x in bucket_objects
        if (
            x.key.endswith('.csv') and
            not x.key.startswith('staging') and
            x.last_modified >= to_datetime
        )
    ]

    if config['verbose']:
        print('Found {} csv files'.format(len(filtered_csv_list)))

    deleted_ids = {}

    for obj in filtered_csv_list:
        # Use temporary files to facilitate date moving from csv files on S3 into pands
        (file, file_path) = tempfile.mkstemp()
        bucket.download_file(obj.key, file_path)

        # Ingests the CSV into a dataframe. pandas thinks some ids are dates, so disable parsing
        data = pd.DataFrame.from_csv(file_path, parse_dates=False)

        if 'detached_award_proc_unique' in data:
            new_ids = ['cont_tx_' + x for x in data['detached_award_proc_unique'].values]
        elif 'afa_generated_unique' in data:
            new_ids = ['asst_tx_' + x for x in data['afa_generated_unique'].values]
        else:
            print('  [Missing valid col] in {}'.format(obj.key))

        # Next statements are ugly, but properly handle the temp files
        os.close(file)
        os.remove(file_path)

        if config['verbose']:
            print('{:<55} ... {}'.format(obj.key, len(new_ids)))

        for uid in new_ids:
            if uid in deleted_ids:
                if deleted_ids[uid]['timestamp'] < obj.last_modified:
                    deleted_ids[uid]['timestamp'] = obj.last_modified
            else:
                deleted_ids[uid] = {'timestamp': obj.last_modified}

    if config['verbose']:
        for k, v in deleted_ids.items():
            print('id: {} last modified: {}'.format(k, str(v['timestamp'])))

    print('Found {} IDs'.format(len(deleted_ids)))
    print("Gathering deleted transactions took {} seconds".format(perf_counter() - start))
    return deleted_ids

# ==============================================================================
# SQL Template Strings for Postgres Statements
# ==============================================================================


TEMP_ES_DELTA_VIEW = '''
CREATE OR REPLACE VIEW transaction_delta_view AS
SELECT
  UTM.transaction_id,
  TM.modification_number,
  UAM.award_id,
  UTM.piid,
  UTM.fain,
  UTM.uri,
  AW.description AS award_description,

  UTM.product_or_service_code,
  UTM.product_or_service_description,
  UTM.naics_code,
  UTM.naics_description,
  UAM.type_description,
  UTM.award_category,
  UTM.recipient_unique_id,
  UTM.parent_recipient_unique_id,
  UTM.recipient_name,

  UTM.action_date::date,
  UAM.period_of_performance_start_date,
  UAM.period_of_performance_current_end_date,
  UTM.fiscal_year AS transaction_fiscal_year,
  UAM.fiscal_year AS award_fiscal_year,
  UAM.total_obligation AS award_amount,
  UTM.federal_action_obligation AS transaction_amount,
  UAM.face_value_loan_guarantee,
  UAM.original_loan_subsidy_cost,

  UTM.awarding_agency_id,
  UTM.funding_agency_id,
  UAM.awarding_toptier_agency_name,
  UTM.funding_toptier_agency_name,
  UTM.awarding_subtier_agency_name,
  UTM.funding_subtier_agency_name,
  UTM.awarding_toptier_agency_abbreviation,
  UTM.funding_toptier_agency_abbreviation,
  UTM.awarding_subtier_agency_abbreviation,
  UTM.funding_subtier_agency_abbreviation,

  UTM.cfda_title,
  UTM.cfda_popular_name,
  UTM.type_of_contract_pricing,
  UTM.type_set_aside,
  UTM.extent_competed,
  UTM.pulled_from,
  UTM.type,

  UTM.pop_country_code,
  UTM.pop_country_name,
  UTM.pop_state_code,
  UTM.pop_county_code,
  UTM.pop_county_name,
  UTM.pop_zip5,
  UTM.pop_congressional_code,

  UTM.recipient_location_country_code,
  UTM.recipient_location_country_name,
  UTM.recipient_location_state_code,
  UTM.recipient_location_county_code,
  UTM.recipient_location_zip5,

  FPDS.detached_award_proc_unique,
  FABS.afa_generated_unique,

  CASE
    WHEN FPDS.detached_award_proc_unique IS NOT NULL THEN 'cont_tx_' || FPDS.detached_award_proc_unique
    WHEN FABS.afa_generated_unique IS NOT NULL THEN 'asst_tx_' || FABS.afa_generated_unique
    ELSE NULL  -- if this happens: Activate Batsignal
  END AS generated_unique_transaction_id,
  TM.update_date

FROM universal_transaction_matview UTM
JOIN transaction_normalized TM ON (UTM.transaction_id = TM.id)
LEFT JOIN transaction_fpds FPDS ON (UTM.transaction_id = FPDS.transaction_id)
LEFT JOIN transaction_fabs FABS ON (UTM.transaction_id = FABS.transaction_id)
LEFT JOIN universal_award_matview UAM ON (UTM.award_id = UAM.award_id)
JOIN awards AW ON (UAM.award_id = AW.id);'''

VIEW_COLUMNS = [
    'transaction_id', 'modification_number', 'award_id', 'piid', 'fain', 'uri',
    'award_description', 'product_or_service_code', 'product_or_service_description',
    'naics_code', 'naics_description', 'type_description', 'award_category',
    'recipient_unique_id', 'parent_recipient_unique_id', 'recipient_name',
    'action_date', 'period_of_performance_start_date', 'period_of_performance_current_end_date',
    'transaction_fiscal_year', 'award_fiscal_year', 'award_amount',
    'transaction_amount', 'face_value_loan_guarantee', 'original_loan_subsidy_cost',
    'awarding_agency_id', 'funding_agency_id', 'awarding_toptier_agency_name',
    'funding_toptier_agency_name', 'awarding_subtier_agency_name',
    'funding_subtier_agency_name', 'awarding_toptier_agency_abbreviation',
    'funding_toptier_agency_abbreviation', 'awarding_subtier_agency_abbreviation',
    'funding_subtier_agency_abbreviation', 'cfda_title', 'cfda_popular_name',
    'type_of_contract_pricing', 'type_set_aside', 'extent_competed', 'pulled_from',
    'type', 'pop_country_code', 'pop_country_name', 'pop_state_code', 'pop_county_code',
    'pop_county_name', 'pop_zip5', 'pop_congressional_code',
    'recipient_location_country_code', 'recipient_location_country_name',
    'recipient_location_state_code', 'recipient_location_county_code',
    'recipient_location_zip5', 'detached_award_proc_unique', 'afa_generated_unique',
    'generated_unique_transaction_id', 'update_date',
]

UPDATE_DATE_SQL = ' AND update_date >= \'{}\''

CATEGORY_SQL = ' AND award_category = \'{}\''

CONTRACTS_IDV_SQL = ' AND (award_category = \'{}\' OR award_category IS NULL AND pulled_from = \'IDV\')'

COUNT_SQL = '''SELECT COUNT(*) AS count
FROM transaction_delta_view
WHERE transaction_fiscal_year={fy}{update_date}{award_category};'''

COPY_SQL = '''"COPY (
    SELECT *
    FROM transaction_delta_view
    WHERE transaction_fiscal_year={fy}{update_date}{award_category}
) TO STDOUT DELIMITER ',' CSV HEADER" > '{filename}'
'''

DROP_VIEW_SQL = 'DROP VIEW transaction_delta_view;'

CHECK_IDS_SQL = '''
WITH temp_transaction_ids AS (
  SELECT * FROM (VALUES {id_list}) AS unique_id_list (generated_unique_transaction_id)
)
SELECT transaction_id, generated_unique_transaction_id, update_date FROM transaction_delta_view
WHERE EXISTS (
  SELECT *
  FROM temp_transaction_ids
  WHERE transaction_delta_view.generated_unique_transaction_id = temp_transaction_ids.generated_unique_transaction_id
);
'''
