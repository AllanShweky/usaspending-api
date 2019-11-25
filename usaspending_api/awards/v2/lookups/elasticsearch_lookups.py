"""
Look ups for elasticsearch fields to be displayed for the front end
"""
from copy import deepcopy
from usaspending_api.awards.v2.lookups.lookups import all_award_types_mappings


TRANSACTIONS_LOOKUP = {
    "Recipient Name": "recipient_name",
    "Action Date": "action_date",
    "Transaction Amount": "transaction_amount",
    "Award Type": "type_description",
    "Awarding Agency": "awarding_toptier_agency_name",
    "Awarding Sub Agency": "awarding_subtier_agency_name",
    "Funding Agency": "funding_toptier_agency_name",
    "Funding Sub Agency": "funding_subtier_agency_name",
    "Issued Date": "period_of_performance_start_date",
    "Loan Value": "face_value_loan_guarantee",
    "Subsidy Cost": "original_loan_subsidy_cost",
    "Mod": "modification_number",
    "Award ID": "display_award_id",
    "awarding_agency_id": "awarding_agency_id",
    "internal_id": "award_id",
    "generated_internal_id": "generated_unique_award_id",
    "Last Date to Order": "ordering_period_end_date",
}

AWARDS_LOOKUP = {
    "Recipient Name": "recipient_name",
    "Action Date": "action_date",
    "Award Amount": "total_obligation",
    "Award Type": "type_description",
    "Awarding Agency": "awarding_toptier_agency_name",
    "Awarding Sub Agency": "awarding_subtier_agency_name",
    "Funding Agency": "funding_toptier_agency_name",
    "Funding Sub Agency": "funding_subtier_agency_name",
    "Loan Value": "face_value_loan_guarantee",
    "Subsidy Cost": "original_loan_subsidy_cost",
    "Award ID": "display_award_id",
    "awarding_agency_id": "awarding_agency_id",
    "internal_id": "award_id",
    "Last Date to Order": "ordering_period_end_date",
    "Start Date": "period_of_performance_start_date",
    "End Date": "period_of_performance_current_end_date",
    "Contract Award Type": "type_description",
    "recipient_id": "recipient_hash",
    "prime_award_recipient_id": "prime_award_recipient_id",
    "generated_internal_id": "generated_unique_award_id",
}
default_mapping = {
    "Award ID": "display_award_id",
    "Recipient Name": "recipient_name",
    "Recipient DUNS Number": "recipient_unique_id",
    "recipient_id": "_recipient_id",  # recipient_id conflicts with another column in the model
    "Awarding Agency": "awarding_toptier_agency_name",
    "Awarding Agency Code": "awarding_toptier_agency_code",
    "Awarding Sub Agency": "awarding_subtier_agency_name",
    "Awarding Sub Agency Code": "awarding_subtier_agency_code",
    "Funding Agency": "funding_toptier_agency_name",  # Leave in for possible future use
    "Funding Agency Code": "funding_toptier_agency_code",  # Leave in for possible future use
    "Funding Sub Agency": "funding_subtier_agency_name",  # Leave in for possible future use
    "Funding Sub Agency Code": "funding_subtier_agency_code",  # Leave in for possible future use
    "Place of Performance City Code": "pop_city_code",
    "Place of Performance State Code": "pop_state_code",
    "Place of Performance Country Code": "pop_country_code",
    "Place of Performance Zip5": "pop_zip5",
    "Period of Performance Start Date": "period_of_performance_start_date",
    "Period of Performance Current End Date": "period_of_performance_current_end_date",
    "Description": "description",
    "Last Modified Date": "last_modified_date",
    "Base Obligation Date": "date_signed",
    "prime_award_recipient_id": "prime_award_recipient_id",
    "generated_internal_id": "generated_unique_award_id",
}

award_contracts_mapping = default_mapping.copy()
award_idv_mapping = default_mapping.copy()
grant_award_mapping = default_mapping.copy()
loan_award_mapping = default_mapping.copy()
direct_payment_award_mapping = default_mapping.copy()
other_award_mapping = default_mapping.copy()

award_contracts_mapping.update(
    {
        "Start Date": "period_of_performance_start_date",
        "End Date": "period_of_performance_current_end_date",
        "Award Amount": "total_obligation",
        "Contract Award Type": "type_description",
    }
)

award_idv_mapping.update(
    {
        "Start Date": "period_of_performance_start_date",
        "Award Amount": "total_obligation",
        "Contract Award Type": "type_description",
        "Last Date to Order": "ordering_period_end_date",
    }
)

grant_award_mapping.update(
    {
        "Start Date": "period_of_performance_start_date",
        "End Date": "period_of_performance_current_end_date",
        "Award Amount": "total_obligation",
        "Award Type": "type_description",
        "SAI Number": "sai_number",
        "CFDA Number": "cfda_number",
    }
)

loan_award_mapping.update(
    {
        "Issued Date": "action_date",
        "Loan Value": "total_loan_value",
        "Subsidy Cost": "total_subsidy_cost",
        "SAI Number": "sai_number",
        "CFDA Number": "cfda_number",
    }
)

direct_payment_award_mapping.update(
    {
        "Start Date": "period_of_performance_start_date",
        "End Date": "period_of_performance_current_end_date",
        "Award Amount": "total_obligation",
        "Award Type": "type_description",
        "SAI Number": "sai_number",
        "CFDA Number": "cfda_number",
    }
)

other_award_mapping.update(
    {
        "Start Date": "period_of_performance_start_date",
        "End Date": "period_of_performance_current_end_date",
        "Award Amount": "total_obligation",
        "Award Type": "type_description",
        "SAI Number": "sai_number",
        "CFDA Number": "cfda_number",
    }
)

INDEX_ALIASES_TO_AWARD_TYPES = deepcopy(all_award_types_mappings)
INDEX_ALIASES_TO_AWARD_TYPES["directpayments"] = INDEX_ALIASES_TO_AWARD_TYPES.pop("direct_payments")
INDEX_ALIASES_TO_AWARD_TYPES["other"] = INDEX_ALIASES_TO_AWARD_TYPES.pop("other_financial_assistance")

KEYWORD_DATATYPE_FIELDS = ["recipient_name", "awarding_toptier_agency_name", "awarding_subtier_agency_name"]
