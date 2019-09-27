SELECT
    'fabs'::TEXT AS "system",
    usaspending.transaction_id,
    usaspending.published_award_financial_assistance_id AS "broker_surrogate_id",
    usaspending.afa_generated_unique AS "broker_derived_unique_key",
    concat_ws(' ', usaspending.fain, usaspending.uri) AS "piid_fain_uri",
    usaspending.unique_award_key,
    usaspending.action_date::date,
    usaspending.modified_at::date AS "record_last_modified",
    broker.created_at::TIMESTAMP WITHOUT TIME ZONE AS "broker_record_create",
    broker.updated_at::TIMESTAMP WITHOUT TIME ZONE AS "broker_record_update",
    transaction_normalized.create_date::TIMESTAMP WITH TIME ZONE AS "usaspending_record_create",
    transaction_normalized.update_date::TIMESTAMP WITH TIME ZONE AS "usaspending_record_update",
    jsonb_strip_nulls(
        jsonb_build_object(
            'created_at', CASE WHEN broker.created_at IS DISTINCT FROM usaspending.created_at::TIMESTAMP WITHOUT TIME ZONE THEN jsonb_build_object('broker', broker.created_at, 'usaspending', usaspending.created_at) ELSE null END,
            'updated_at', CASE WHEN broker.updated_at IS DISTINCT FROM usaspending.updated_at::TIMESTAMP WITHOUT TIME ZONE THEN jsonb_build_object('broker', broker.updated_at, 'usaspending', usaspending.updated_at) ELSE null END,
            'action_date', CASE WHEN broker.action_date IS DISTINCT FROM usaspending.action_date::date::text THEN jsonb_build_object('broker', broker.action_date, 'usaspending', usaspending.action_date) ELSE null END,
            'action_type', CASE WHEN broker.action_type IS DISTINCT FROM usaspending.action_type THEN jsonb_build_object('broker', broker.action_type, 'usaspending', usaspending.action_type) ELSE null END,
            'assistance_type', CASE WHEN broker.assistance_type IS DISTINCT FROM usaspending.assistance_type THEN jsonb_build_object('broker', broker.assistance_type, 'usaspending', usaspending.assistance_type) ELSE null END,
            'award_description', CASE WHEN broker.award_description IS DISTINCT FROM usaspending.award_description THEN jsonb_build_object('broker', broker.award_description, 'usaspending', usaspending.award_description) ELSE null END,
            'awardee_or_recipient_legal', CASE WHEN broker.awardee_or_recipient_legal IS DISTINCT FROM usaspending.awardee_or_recipient_legal THEN jsonb_build_object('broker', broker.awardee_or_recipient_legal, 'usaspending', usaspending.awardee_or_recipient_legal) ELSE null END,
            'awardee_or_recipient_uniqu', CASE WHEN broker.awardee_or_recipient_uniqu IS DISTINCT FROM usaspending.awardee_or_recipient_uniqu THEN jsonb_build_object('broker', broker.awardee_or_recipient_uniqu, 'usaspending', usaspending.awardee_or_recipient_uniqu) ELSE null END,
            'awarding_agency_code', CASE WHEN broker.awarding_agency_code IS DISTINCT FROM usaspending.awarding_agency_code THEN jsonb_build_object('broker', broker.awarding_agency_code, 'usaspending', usaspending.awarding_agency_code) ELSE null END,
            'awarding_office_code', CASE WHEN broker.awarding_office_code IS DISTINCT FROM usaspending.awarding_office_code THEN jsonb_build_object('broker', broker.awarding_office_code, 'usaspending', usaspending.awarding_office_code) ELSE null END,
            'awarding_sub_tier_agency_c', CASE WHEN broker.awarding_sub_tier_agency_c IS DISTINCT FROM usaspending.awarding_sub_tier_agency_c THEN jsonb_build_object('broker', broker.awarding_sub_tier_agency_c, 'usaspending', usaspending.awarding_sub_tier_agency_c) ELSE null END,
            'award_modification_amendme', CASE WHEN broker.award_modification_amendme IS DISTINCT FROM usaspending.award_modification_amendme THEN jsonb_build_object('broker', broker.award_modification_amendme, 'usaspending', usaspending.award_modification_amendme) ELSE null END,
            'business_funds_indicator', CASE WHEN broker.business_funds_indicator IS DISTINCT FROM usaspending.business_funds_indicator THEN jsonb_build_object('broker', broker.business_funds_indicator, 'usaspending', usaspending.business_funds_indicator) ELSE null END,
            'business_types', CASE WHEN broker.business_types IS DISTINCT FROM usaspending.business_types THEN jsonb_build_object('broker', broker.business_types, 'usaspending', usaspending.business_types) ELSE null END,
            'cfda_number', CASE WHEN broker.cfda_number IS DISTINCT FROM usaspending.cfda_number THEN jsonb_build_object('broker', broker.cfda_number, 'usaspending', usaspending.cfda_number) ELSE null END,
            'correction_delete_indicatr', CASE WHEN broker.correction_delete_indicatr IS DISTINCT FROM usaspending.correction_delete_indicatr THEN jsonb_build_object('broker', broker.correction_delete_indicatr, 'usaspending', usaspending.correction_delete_indicatr) ELSE null END,
            'face_value_loan_guarantee', CASE WHEN broker.face_value_loan_guarantee IS DISTINCT FROM usaspending.face_value_loan_guarantee THEN jsonb_build_object('broker', broker.face_value_loan_guarantee, 'usaspending', usaspending.face_value_loan_guarantee) ELSE null END,
            'fain', CASE WHEN broker.fain IS DISTINCT FROM usaspending.fain THEN jsonb_build_object('broker', broker.fain, 'usaspending', usaspending.fain) ELSE null END,
            'federal_action_obligation', CASE WHEN broker.federal_action_obligation IS DISTINCT FROM usaspending.federal_action_obligation THEN jsonb_build_object('broker', broker.federal_action_obligation, 'usaspending', usaspending.federal_action_obligation) ELSE null END,
            'fiscal_year_and_quarter_co', CASE WHEN broker.fiscal_year_and_quarter_co IS DISTINCT FROM usaspending.fiscal_year_and_quarter_co THEN jsonb_build_object('broker', broker.fiscal_year_and_quarter_co, 'usaspending', usaspending.fiscal_year_and_quarter_co) ELSE null END,
            'funding_agency_code', CASE WHEN broker.funding_agency_code IS DISTINCT FROM usaspending.funding_agency_code THEN jsonb_build_object('broker', broker.funding_agency_code, 'usaspending', usaspending.funding_agency_code) ELSE null END,
            'funding_office_code', CASE WHEN broker.funding_office_code IS DISTINCT FROM usaspending.funding_office_code THEN jsonb_build_object('broker', broker.funding_office_code, 'usaspending', usaspending.funding_office_code) ELSE null END,
            'funding_sub_tier_agency_co', CASE WHEN broker.funding_sub_tier_agency_co IS DISTINCT FROM usaspending.funding_sub_tier_agency_co THEN jsonb_build_object('broker', broker.funding_sub_tier_agency_co, 'usaspending', usaspending.funding_sub_tier_agency_co) ELSE null END,
            'legal_entity_address_line1', CASE WHEN broker.legal_entity_address_line1 IS DISTINCT FROM usaspending.legal_entity_address_line1 THEN jsonb_build_object('broker', broker.legal_entity_address_line1, 'usaspending', usaspending.legal_entity_address_line1) ELSE null END,
            'legal_entity_address_line2', CASE WHEN broker.legal_entity_address_line2 IS DISTINCT FROM usaspending.legal_entity_address_line2 THEN jsonb_build_object('broker', broker.legal_entity_address_line2, 'usaspending', usaspending.legal_entity_address_line2) ELSE null END,
            'legal_entity_address_line3', CASE WHEN broker.legal_entity_address_line3 IS DISTINCT FROM usaspending.legal_entity_address_line3 THEN jsonb_build_object('broker', broker.legal_entity_address_line3, 'usaspending', usaspending.legal_entity_address_line3) ELSE null END,
            'legal_entity_country_code', CASE WHEN broker.legal_entity_country_code IS DISTINCT FROM usaspending.legal_entity_country_code THEN jsonb_build_object('broker', broker.legal_entity_country_code, 'usaspending', usaspending.legal_entity_country_code) ELSE null END,
            'legal_entity_foreign_city', CASE WHEN broker.legal_entity_foreign_city IS DISTINCT FROM usaspending.legal_entity_foreign_city THEN jsonb_build_object('broker', broker.legal_entity_foreign_city, 'usaspending', usaspending.legal_entity_foreign_city) ELSE null END,
            'legal_entity_foreign_posta', CASE WHEN broker.legal_entity_foreign_posta IS DISTINCT FROM usaspending.legal_entity_foreign_posta THEN jsonb_build_object('broker', broker.legal_entity_foreign_posta, 'usaspending', usaspending.legal_entity_foreign_posta) ELSE null END,
            'legal_entity_foreign_provi', CASE WHEN broker.legal_entity_foreign_provi IS DISTINCT FROM usaspending.legal_entity_foreign_provi THEN jsonb_build_object('broker', broker.legal_entity_foreign_provi, 'usaspending', usaspending.legal_entity_foreign_provi) ELSE null END,
            'legal_entity_zip5', CASE WHEN broker.legal_entity_zip5 IS DISTINCT FROM usaspending.legal_entity_zip5 THEN jsonb_build_object('broker', broker.legal_entity_zip5, 'usaspending', usaspending.legal_entity_zip5) ELSE null END,
            'legal_entity_zip_last4', CASE WHEN broker.legal_entity_zip_last4 IS DISTINCT FROM usaspending.legal_entity_zip_last4 THEN jsonb_build_object('broker', broker.legal_entity_zip_last4, 'usaspending', usaspending.legal_entity_zip_last4) ELSE null END,
            'non_federal_funding_amount', CASE WHEN broker.non_federal_funding_amount IS DISTINCT FROM usaspending.non_federal_funding_amount THEN jsonb_build_object('broker', broker.non_federal_funding_amount, 'usaspending', usaspending.non_federal_funding_amount) ELSE null END,
            'original_loan_subsidy_cost', CASE WHEN broker.original_loan_subsidy_cost IS DISTINCT FROM usaspending.original_loan_subsidy_cost THEN jsonb_build_object('broker', broker.original_loan_subsidy_cost, 'usaspending', usaspending.original_loan_subsidy_cost) ELSE null END,
            'period_of_performance_curr', CASE WHEN broker.period_of_performance_curr IS DISTINCT FROM usaspending.period_of_performance_curr THEN jsonb_build_object('broker', broker.period_of_performance_curr, 'usaspending', usaspending.period_of_performance_curr) ELSE null END,
            'period_of_performance_star', CASE WHEN broker.period_of_performance_star IS DISTINCT FROM usaspending.period_of_performance_star THEN jsonb_build_object('broker', broker.period_of_performance_star, 'usaspending', usaspending.period_of_performance_star) ELSE null END,
            'place_of_performance_code', CASE WHEN broker.place_of_performance_code IS DISTINCT FROM usaspending.place_of_performance_code THEN jsonb_build_object('broker', broker.place_of_performance_code, 'usaspending', usaspending.place_of_performance_code) ELSE null END,
            'place_of_performance_congr', CASE WHEN broker.place_of_performance_congr IS DISTINCT FROM usaspending.place_of_performance_congr THEN jsonb_build_object('broker', broker.place_of_performance_congr, 'usaspending', usaspending.place_of_performance_congr) ELSE null END,
            'place_of_perform_country_c', CASE WHEN broker.place_of_perform_country_c IS DISTINCT FROM usaspending.place_of_perform_country_c THEN jsonb_build_object('broker', broker.place_of_perform_country_c, 'usaspending', usaspending.place_of_perform_country_c) ELSE null END,
            'place_of_performance_forei', CASE WHEN broker.place_of_performance_forei IS DISTINCT FROM usaspending.place_of_performance_forei THEN jsonb_build_object('broker', broker.place_of_performance_forei, 'usaspending', usaspending.place_of_performance_forei) ELSE null END,
            'place_of_performance_zip4a', CASE WHEN broker.place_of_performance_zip4a IS DISTINCT FROM usaspending.place_of_performance_zip4a THEN jsonb_build_object('broker', broker.place_of_performance_zip4a, 'usaspending', usaspending.place_of_performance_zip4a) ELSE null END,
            'record_type', CASE WHEN broker.record_type IS DISTINCT FROM usaspending.record_type THEN jsonb_build_object('broker', broker.record_type, 'usaspending', usaspending.record_type) ELSE null END,
            'sai_number', CASE WHEN broker.sai_number IS DISTINCT FROM usaspending.sai_number THEN jsonb_build_object('broker', broker.sai_number, 'usaspending', usaspending.sai_number) ELSE null END,
            'uri', CASE WHEN broker.uri IS DISTINCT FROM usaspending.uri THEN jsonb_build_object('broker', broker.uri, 'usaspending', usaspending.uri) ELSE null END,
            'legal_entity_congressional', CASE WHEN broker.legal_entity_congressional IS DISTINCT FROM usaspending.legal_entity_congressional THEN jsonb_build_object('broker', broker.legal_entity_congressional, 'usaspending', usaspending.legal_entity_congressional) ELSE null END,
            'total_funding_amount', CASE WHEN broker.total_funding_amount IS DISTINCT FROM usaspending.total_funding_amount THEN jsonb_build_object('broker', broker.total_funding_amount, 'usaspending', usaspending.total_funding_amount) ELSE null END,
            'cfda_title', CASE WHEN broker.cfda_title IS DISTINCT FROM usaspending.cfda_title THEN jsonb_build_object('broker', broker.cfda_title, 'usaspending', usaspending.cfda_title) ELSE null END
        ) || jsonb_build_object(
            'awarding_agency_name', CASE WHEN broker.awarding_agency_name IS DISTINCT FROM usaspending.awarding_agency_name THEN jsonb_build_object('broker', broker.awarding_agency_name, 'usaspending', usaspending.awarding_agency_name) ELSE null END,
            'awarding_sub_tier_agency_n', CASE WHEN broker.awarding_sub_tier_agency_n IS DISTINCT FROM usaspending.awarding_sub_tier_agency_n THEN jsonb_build_object('broker', broker.awarding_sub_tier_agency_n, 'usaspending', usaspending.awarding_sub_tier_agency_n) ELSE null END,
            'funding_agency_name', CASE WHEN broker.funding_agency_name IS DISTINCT FROM usaspending.funding_agency_name THEN jsonb_build_object('broker', broker.funding_agency_name, 'usaspending', usaspending.funding_agency_name) ELSE null END,
            'funding_sub_tier_agency_na', CASE WHEN broker.funding_sub_tier_agency_na IS DISTINCT FROM usaspending.funding_sub_tier_agency_na THEN jsonb_build_object('broker', broker.funding_sub_tier_agency_na, 'usaspending', usaspending.funding_sub_tier_agency_na) ELSE null END,
            'is_historical', CASE WHEN broker.is_historical IS DISTINCT FROM usaspending.is_historical THEN jsonb_build_object('broker', broker.is_historical, 'usaspending', usaspending.is_historical) ELSE null END,
            'place_of_perform_county_na', CASE WHEN broker.place_of_perform_county_na IS DISTINCT FROM usaspending.place_of_perform_county_na THEN jsonb_build_object('broker', broker.place_of_perform_county_na, 'usaspending', usaspending.place_of_perform_county_na) ELSE null END,
            'place_of_perform_state_nam', CASE WHEN broker.place_of_perform_state_nam IS DISTINCT FROM usaspending.place_of_perform_state_nam THEN jsonb_build_object('broker', broker.place_of_perform_state_nam, 'usaspending', usaspending.place_of_perform_state_nam) ELSE null END,
            'place_of_performance_city', CASE WHEN broker.place_of_performance_city IS DISTINCT FROM usaspending.place_of_performance_city THEN jsonb_build_object('broker', broker.place_of_performance_city, 'usaspending', usaspending.place_of_performance_city) ELSE null END,
            'legal_entity_city_name', CASE WHEN broker.legal_entity_city_name IS DISTINCT FROM usaspending.legal_entity_city_name THEN jsonb_build_object('broker', broker.legal_entity_city_name, 'usaspending', usaspending.legal_entity_city_name) ELSE null END,
            'legal_entity_county_code', CASE WHEN broker.legal_entity_county_code IS DISTINCT FROM usaspending.legal_entity_county_code THEN jsonb_build_object('broker', broker.legal_entity_county_code, 'usaspending', usaspending.legal_entity_county_code) ELSE null END,
            'legal_entity_county_name', CASE WHEN broker.legal_entity_county_name IS DISTINCT FROM usaspending.legal_entity_county_name THEN jsonb_build_object('broker', broker.legal_entity_county_name, 'usaspending', usaspending.legal_entity_county_name) ELSE null END,
            'legal_entity_state_code', CASE WHEN broker.legal_entity_state_code IS DISTINCT FROM usaspending.legal_entity_state_code THEN jsonb_build_object('broker', broker.legal_entity_state_code, 'usaspending', usaspending.legal_entity_state_code) ELSE null END,
            'legal_entity_state_name', CASE WHEN broker.legal_entity_state_name IS DISTINCT FROM usaspending.legal_entity_state_name THEN jsonb_build_object('broker', broker.legal_entity_state_name, 'usaspending', usaspending.legal_entity_state_name) ELSE null END,
            'modified_at', CASE WHEN broker.modified_at IS DISTINCT FROM usaspending.modified_at::TIMESTAMP WITHOUT TIME ZONE THEN jsonb_build_object('broker', broker.modified_at, 'usaspending', usaspending.modified_at) ELSE null END,
            'afa_generated_unique', CASE WHEN broker.afa_generated_unique IS DISTINCT FROM usaspending.afa_generated_unique THEN jsonb_build_object('broker', broker.afa_generated_unique, 'usaspending', usaspending.afa_generated_unique) ELSE null END,
            'is_active', CASE WHEN broker.is_active IS DISTINCT FROM usaspending.is_active THEN jsonb_build_object('broker', broker.is_active, 'usaspending', usaspending.is_active) ELSE null END,
            'awarding_office_name', CASE WHEN broker.awarding_office_name IS DISTINCT FROM usaspending.awarding_office_name THEN jsonb_build_object('broker', broker.awarding_office_name, 'usaspending', usaspending.awarding_office_name) ELSE null END,
            'funding_office_name', CASE WHEN broker.funding_office_name IS DISTINCT FROM usaspending.funding_office_name THEN jsonb_build_object('broker', broker.funding_office_name, 'usaspending', usaspending.funding_office_name) ELSE null END,
            'legal_entity_city_code', CASE WHEN broker.legal_entity_city_code IS DISTINCT FROM usaspending.legal_entity_city_code THEN jsonb_build_object('broker', broker.legal_entity_city_code, 'usaspending', usaspending.legal_entity_city_code) ELSE null END,
            'legal_entity_foreign_descr', CASE WHEN broker.legal_entity_foreign_descr IS DISTINCT FROM usaspending.legal_entity_foreign_descr THEN jsonb_build_object('broker', broker.legal_entity_foreign_descr, 'usaspending', usaspending.legal_entity_foreign_descr) ELSE null END,
            'legal_entity_country_name', CASE WHEN broker.legal_entity_country_name IS DISTINCT FROM usaspending.legal_entity_country_name THEN jsonb_build_object('broker', broker.legal_entity_country_name, 'usaspending', usaspending.legal_entity_country_name) ELSE null END,
            'place_of_perform_country_n', CASE WHEN broker.place_of_perform_country_n IS DISTINCT FROM usaspending.place_of_perform_country_n THEN jsonb_build_object('broker', broker.place_of_perform_country_n, 'usaspending', usaspending.place_of_perform_country_n) ELSE null END,
            'place_of_perform_county_co', CASE WHEN broker.place_of_perform_county_co IS DISTINCT FROM usaspending.place_of_perform_county_co THEN jsonb_build_object('broker', broker.place_of_perform_county_co, 'usaspending', usaspending.place_of_perform_county_co) ELSE null END,
            'submission_id', CASE WHEN broker.submission_id IS DISTINCT FROM usaspending.submission_id::text THEN jsonb_build_object('broker', broker.submission_id, 'usaspending', usaspending.submission_id) ELSE null END,
            'place_of_perfor_state_code', CASE WHEN broker.place_of_perfor_state_code IS DISTINCT FROM usaspending.place_of_perfor_state_code THEN jsonb_build_object('broker', broker.place_of_perfor_state_code, 'usaspending', usaspending.place_of_perfor_state_code) ELSE null END,
            'place_of_performance_zip5', CASE WHEN broker.place_of_performance_zip5 IS DISTINCT FROM usaspending.place_of_performance_zip5 THEN jsonb_build_object('broker', broker.place_of_performance_zip5, 'usaspending', usaspending.place_of_performance_zip5) ELSE null END,
            'place_of_perform_zip_last4', CASE WHEN broker.place_of_perform_zip_last4 IS DISTINCT FROM usaspending.place_of_perform_zip_last4 THEN jsonb_build_object('broker', broker.place_of_perform_zip_last4, 'usaspending', usaspending.place_of_perform_zip_last4) ELSE null END,
            'action_type_description', CASE WHEN broker.action_type_description IS DISTINCT FROM usaspending.action_type_description THEN jsonb_build_object('broker', broker.action_type_description, 'usaspending', usaspending.action_type_description) ELSE null END,
            'assistance_type_desc', CASE WHEN broker.assistance_type_desc IS DISTINCT FROM usaspending.assistance_type_desc THEN jsonb_build_object('broker', broker.assistance_type_desc, 'usaspending', usaspending.assistance_type_desc) ELSE null END,
            'business_funds_ind_desc', CASE WHEN broker.business_funds_ind_desc IS DISTINCT FROM usaspending.business_funds_ind_desc THEN jsonb_build_object('broker', broker.business_funds_ind_desc, 'usaspending', usaspending.business_funds_ind_desc) ELSE null END,
            'business_types_desc', CASE WHEN broker.business_types_desc IS DISTINCT FROM usaspending.business_types_desc THEN jsonb_build_object('broker', broker.business_types_desc, 'usaspending', usaspending.business_types_desc) ELSE null END,
            'correction_delete_ind_desc', CASE WHEN broker.correction_delete_ind_desc IS DISTINCT FROM usaspending.correction_delete_ind_desc THEN jsonb_build_object('broker', broker.correction_delete_ind_desc, 'usaspending', usaspending.correction_delete_ind_desc) ELSE null END,
            'record_type_description', CASE WHEN broker.record_type_description IS DISTINCT FROM usaspending.record_type_description THEN jsonb_build_object('broker', broker.record_type_description, 'usaspending', usaspending.record_type_description) ELSE null END,
            'ultimate_parent_legal_enti', CASE WHEN broker.ultimate_parent_legal_enti IS DISTINCT FROM usaspending.ultimate_parent_legal_enti THEN jsonb_build_object('broker', broker.ultimate_parent_legal_enti, 'usaspending', usaspending.ultimate_parent_legal_enti) ELSE null END,
            'ultimate_parent_unique_ide', CASE WHEN broker.ultimate_parent_unique_ide IS DISTINCT FROM usaspending.ultimate_parent_unique_ide THEN jsonb_build_object('broker', broker.ultimate_parent_unique_ide, 'usaspending', usaspending.ultimate_parent_unique_ide) ELSE null END,
            'unique_award_key', CASE WHEN broker.unique_award_key IS DISTINCT FROM usaspending.unique_award_key THEN jsonb_build_object('broker', broker.unique_award_key, 'usaspending', usaspending.unique_award_key) ELSE null END,
            'high_comp_officer1_amount', CASE WHEN broker.high_comp_officer1_amount IS DISTINCT FROM usaspending.officer_1_amount THEN jsonb_build_object('broker', broker.high_comp_officer1_amount, 'usaspending', usaspending.officer_1_amount) ELSE null END,
            'high_comp_officer1_full_na', CASE WHEN broker.high_comp_officer1_full_na IS DISTINCT FROM usaspending.officer_1_name THEN jsonb_build_object('broker', broker.high_comp_officer1_full_na, 'usaspending', usaspending.officer_1_name) ELSE null END,
            'high_comp_officer2_amount', CASE WHEN broker.high_comp_officer2_amount IS DISTINCT FROM usaspending.officer_2_amount THEN jsonb_build_object('broker', broker.high_comp_officer2_amount, 'usaspending', usaspending.officer_2_amount) ELSE null END,
            'high_comp_officer2_full_na', CASE WHEN broker.high_comp_officer2_full_na IS DISTINCT FROM usaspending.officer_2_name THEN jsonb_build_object('broker', broker.high_comp_officer2_full_na, 'usaspending', usaspending.officer_2_name) ELSE null END,
            'high_comp_officer3_amount', CASE WHEN broker.high_comp_officer3_amount IS DISTINCT FROM usaspending.officer_3_amount THEN jsonb_build_object('broker', broker.high_comp_officer3_amount, 'usaspending', usaspending.officer_3_amount) ELSE null END,
            'high_comp_officer3_full_na', CASE WHEN broker.high_comp_officer3_full_na IS DISTINCT FROM usaspending.officer_3_name THEN jsonb_build_object('broker', broker.high_comp_officer3_full_na, 'usaspending', usaspending.officer_3_name) ELSE null END,
            'high_comp_officer4_amount', CASE WHEN broker.high_comp_officer4_amount IS DISTINCT FROM usaspending.officer_4_amount THEN jsonb_build_object('broker', broker.high_comp_officer4_amount, 'usaspending', usaspending.officer_4_amount) ELSE null END,
            'high_comp_officer4_full_na', CASE WHEN broker.high_comp_officer4_full_na IS DISTINCT FROM usaspending.officer_4_name THEN jsonb_build_object('broker', broker.high_comp_officer4_full_na, 'usaspending', usaspending.officer_4_name) ELSE null END,
            'high_comp_officer5_amount', CASE WHEN broker.high_comp_officer5_amount IS DISTINCT FROM usaspending.officer_5_amount THEN jsonb_build_object('broker', broker.high_comp_officer5_amount, 'usaspending', usaspending.officer_5_amount) ELSE null END,
            'high_comp_officer5_full_na', CASE WHEN broker.high_comp_officer5_full_na IS DISTINCT FROM usaspending.officer_5_name THEN jsonb_build_object('broker', broker.high_comp_officer5_full_na, 'usaspending', usaspending.officer_5_name) ELSE null END
        )
    ) as fields_diff_json
FROM transaction_fabs AS usaspending
INNER JOIN transaction_normalized ON usaspending.transaction_id = transaction_normalized.id
INNER JOIN
(
    SELECT * FROM dblink (
        'broker_server',
        'SELECT
            created_at::TIMESTAMP WITHOUT TIME ZONE,
            updated_at::TIMESTAMP WITHOUT TIME ZONE,
            published_award_financial_assistance_id,
            action_date::date::text,
            UPPER(action_type) AS action_type,
            UPPER(assistance_type) AS assistance_type,
            UPPER(award_description) AS award_description,
            UPPER(awardee_or_recipient_legal) AS awardee_or_recipient_legal,
            UPPER(awardee_or_recipient_uniqu) AS awardee_or_recipient_uniqu,
            UPPER(awarding_agency_code) AS awarding_agency_code,
            UPPER(awarding_office_code) AS awarding_office_code,
            UPPER(awarding_sub_tier_agency_c) AS awarding_sub_tier_agency_c,
            UPPER(award_modification_amendme) AS award_modification_amendme,
            UPPER(business_funds_indicator) AS business_funds_indicator,
            UPPER(business_types) AS business_types,
            UPPER(cfda_number) AS cfda_number,
            UPPER(correction_delete_indicatr) AS correction_delete_indicatr,
            face_value_loan_guarantee::numeric(23,2),
            UPPER(fain) AS fain,
            federal_action_obligation::numeric(23,2),
            UPPER(fiscal_year_and_quarter_co) AS fiscal_year_and_quarter_co,
            UPPER(funding_agency_code) AS funding_agency_code,
            UPPER(funding_office_code) AS funding_office_code,
            UPPER(funding_sub_tier_agency_co) AS funding_sub_tier_agency_co,
            UPPER(REGEXP_REPLACE(legal_entity_address_line1, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_address_line1,
            UPPER(REGEXP_REPLACE(legal_entity_address_line2, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_address_line2,
            UPPER(REGEXP_REPLACE(legal_entity_address_line3, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_address_line3,
            UPPER(REGEXP_REPLACE(legal_entity_country_code, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_country_code,
            UPPER(REGEXP_REPLACE(legal_entity_foreign_city, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_foreign_city,
            UPPER(REGEXP_REPLACE(legal_entity_foreign_posta, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_foreign_posta,
            UPPER(REGEXP_REPLACE(legal_entity_foreign_provi, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_foreign_provi,
            UPPER(REGEXP_REPLACE(legal_entity_zip5, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_zip5,
            UPPER(REGEXP_REPLACE(legal_entity_zip_last4, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_zip_last4,
            non_federal_funding_amount::numeric(23,2),
            original_loan_subsidy_cost::numeric(23,2),
            UPPER(period_of_performance_curr) AS period_of_performance_curr,
            UPPER(period_of_performance_star) AS period_of_performance_star,
            UPPER(REGEXP_REPLACE(place_of_performance_code, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_performance_code,
            UPPER(REGEXP_REPLACE(place_of_performance_congr, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_performance_congr,
            UPPER(REGEXP_REPLACE(place_of_perform_country_c, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_perform_country_c,
            UPPER(REGEXP_REPLACE(place_of_performance_forei, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_performance_forei,
            UPPER(REGEXP_REPLACE(place_of_performance_zip4a, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_performance_zip4a,
            record_type,
            UPPER(sai_number) AS sai_number,
            UPPER(uri) AS uri,
            UPPER(REGEXP_REPLACE(legal_entity_congressional, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_congressional,
            total_funding_amount,
            UPPER(cfda_title) AS cfda_title,
            UPPER(awarding_agency_name) AS awarding_agency_name,
            UPPER(awarding_sub_tier_agency_n) AS awarding_sub_tier_agency_n,
            UPPER(funding_agency_name) AS funding_agency_name,
            UPPER(funding_sub_tier_agency_na) AS funding_sub_tier_agency_na,
            is_historical,
            UPPER(REGEXP_REPLACE(place_of_perform_county_na, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_perform_county_na,
            UPPER(REGEXP_REPLACE(place_of_perform_state_nam, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_perform_state_nam,
            UPPER(REGEXP_REPLACE(place_of_performance_city, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_performance_city,
            UPPER(REGEXP_REPLACE(legal_entity_city_name, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_city_name,
            UPPER(REGEXP_REPLACE(legal_entity_county_code, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_county_code,
            UPPER(REGEXP_REPLACE(legal_entity_county_name, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_county_name,
            UPPER(REGEXP_REPLACE(legal_entity_state_code, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_state_code,
            UPPER(REGEXP_REPLACE(legal_entity_state_name, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_state_name,
            modified_at::TIMESTAMP WITHOUT TIME ZONE,
            UPPER(afa_generated_unique) AS afa_generated_unique,
            COALESCE(is_active::boolean, False) AS is_active,
            UPPER(awarding_office_name) AS awarding_office_name,
            UPPER(funding_office_name) AS funding_office_name,
            UPPER(REGEXP_REPLACE(legal_entity_city_code, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_city_code,
            UPPER(REGEXP_REPLACE(legal_entity_foreign_descr, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_foreign_descr,
            UPPER(REGEXP_REPLACE(legal_entity_country_name, E''\\s{{2,}}|\\\\n'', '' '')) AS legal_entity_country_name,
            UPPER(REGEXP_REPLACE(place_of_perform_country_n, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_perform_country_n,
            UPPER(REGEXP_REPLACE(place_of_perform_county_co, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_perform_county_co,
            submission_id::text,
            UPPER(REGEXP_REPLACE(place_of_perfor_state_code, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_perfor_state_code,
            UPPER(REGEXP_REPLACE(place_of_performance_zip5, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_performance_zip5,
            UPPER(REGEXP_REPLACE(place_of_perform_zip_last4, E''\\s{{2,}}|\\\\n'', '' '')) AS place_of_perform_zip_last4,
            UPPER(action_type_description) AS action_type_description,
            UPPER(assistance_type_desc) AS assistance_type_desc,
            UPPER(business_funds_ind_desc) AS business_funds_ind_desc,
            UPPER(business_types_desc) AS business_types_desc,
            UPPER(correction_delete_ind_desc) AS correction_delete_ind_desc,
            UPPER(record_type_description) AS record_type_description,
            UPPER(ultimate_parent_legal_enti) AS ultimate_parent_legal_enti,
            UPPER(ultimate_parent_unique_ide) AS ultimate_parent_unique_ide,
            UPPER(unique_award_key) AS unique_award_key,
            high_comp_officer1_amount::numeric(23,2),
            UPPER(high_comp_officer1_full_na) AS high_comp_officer1_full_na,
            high_comp_officer2_amount::numeric(23,2),
            UPPER(high_comp_officer2_full_na) AS high_comp_officer2_full_na,
            high_comp_officer3_amount::numeric(23,2),
            UPPER(high_comp_officer3_full_na) AS high_comp_officer3_full_na,
            high_comp_officer4_amount::numeric(23,2),
            UPPER(high_comp_officer4_full_na) AS high_comp_officer4_full_na,
            high_comp_officer5_amount::numeric(23,2),
            UPPER(high_comp_officer5_full_na) AS high_comp_officer5_full_na
        FROM published_award_financial_assistance
        WHERE {predicate}'
    ) AS broker(
        created_at TIMESTAMP WITHOUT TIME ZONE,
        updated_at TIMESTAMP WITHOUT TIME ZONE,
        published_award_financial_assistance_id integer,
        action_date text,
        action_type text,
        assistance_type text,
        award_description text,
        awardee_or_recipient_legal text,
        awardee_or_recipient_uniqu text,
        awarding_agency_code text,
        awarding_office_code text,
        awarding_sub_tier_agency_c text,
        award_modification_amendme text,
        business_funds_indicator text,
        business_types text,
        cfda_number text,
        correction_delete_indicatr text,
        face_value_loan_guarantee numeric(23,2),
        fain text,
        federal_action_obligation numeric(23,2),
        fiscal_year_and_quarter_co text,
        funding_agency_code text,
        funding_office_code text,
        funding_sub_tier_agency_co text,
        legal_entity_address_line1 text,
        legal_entity_address_line2 text,
        legal_entity_address_line3 text,
        legal_entity_country_code text,
        legal_entity_foreign_city text,
        legal_entity_foreign_posta text,
        legal_entity_foreign_provi text,
        legal_entity_zip5 text,
        legal_entity_zip_last4 text,
        non_federal_funding_amount numeric(23,2),
        original_loan_subsidy_cost numeric(23,2),
        period_of_performance_curr text,
        period_of_performance_star text,
        place_of_performance_code text,
        place_of_performance_congr text,
        place_of_perform_country_c text,
        place_of_performance_forei text,
        place_of_performance_zip4a text,
        record_type integer,
        sai_number text,
        uri text,
        legal_entity_congressional text,
        total_funding_amount text,
        cfda_title text,
        awarding_agency_name text,
        awarding_sub_tier_agency_n text,
        funding_agency_name text,
        funding_sub_tier_agency_na text,
        is_historical boolean,
        place_of_perform_county_na text,
        place_of_perform_state_nam text,
        place_of_performance_city text,
        legal_entity_city_name text,
        legal_entity_county_code text,
        legal_entity_county_name text,
        legal_entity_state_code text,
        legal_entity_state_name text,
        modified_at TIMESTAMP WITHOUT TIME ZONE,
        afa_generated_unique text,
        is_active boolean,
        awarding_office_name text,
        funding_office_name text,
        legal_entity_city_code text,
        legal_entity_foreign_descr text,
        legal_entity_country_name text,
        place_of_perform_country_n text,
        place_of_perform_county_co text,
        submission_id text,
        place_of_perfor_state_code text,
        place_of_performance_zip5 text,
        place_of_perform_zip_last4 text,
        action_type_description text,
        assistance_type_desc text,
        business_funds_ind_desc text,
        business_types_desc text,
        correction_delete_ind_desc text,
        record_type_description text,
        ultimate_parent_legal_enti text,
        ultimate_parent_unique_ide text,
        unique_award_key text,
        high_comp_officer1_amount numeric(23,2),
        high_comp_officer1_full_na text,
        high_comp_officer2_amount numeric(23,2),
        high_comp_officer2_full_na text,
        high_comp_officer3_amount numeric(23,2),
        high_comp_officer3_full_na text,
        high_comp_officer4_amount numeric(23,2),
        high_comp_officer4_full_na text,
        high_comp_officer5_amount numeric(23,2),
        high_comp_officer5_full_na text
    )
) AS broker ON (
    (broker.published_award_financial_assistance_id = usaspending.published_award_financial_assistance_id)
    AND (
         (broker.created_at IS DISTINCT FROM usaspending.created_at::TIMESTAMP WITHOUT TIME ZONE)
        OR (broker.updated_at IS DISTINCT FROM usaspending.updated_at::TIMESTAMP WITHOUT TIME ZONE)
        OR (broker.action_date IS DISTINCT FROM usaspending.action_date::date::text)
        OR (broker.action_type IS DISTINCT FROM usaspending.action_type)
        OR (broker.assistance_type IS DISTINCT FROM usaspending.assistance_type)
        OR (broker.award_description IS DISTINCT FROM usaspending.award_description)
        OR (broker.awardee_or_recipient_legal IS DISTINCT FROM usaspending.awardee_or_recipient_legal)
        OR (broker.awardee_or_recipient_uniqu IS DISTINCT FROM usaspending.awardee_or_recipient_uniqu)
        OR (broker.awarding_agency_code IS DISTINCT FROM usaspending.awarding_agency_code)
        OR (broker.awarding_office_code IS DISTINCT FROM usaspending.awarding_office_code)
        OR (broker.awarding_sub_tier_agency_c IS DISTINCT FROM usaspending.awarding_sub_tier_agency_c)
        OR (broker.award_modification_amendme IS DISTINCT FROM usaspending.award_modification_amendme)
        OR (broker.business_funds_indicator IS DISTINCT FROM usaspending.business_funds_indicator)
        OR (broker.business_types IS DISTINCT FROM usaspending.business_types)
        OR (broker.cfda_number IS DISTINCT FROM usaspending.cfda_number)
        OR (broker.correction_delete_indicatr IS DISTINCT FROM usaspending.correction_delete_indicatr)
        OR (broker.face_value_loan_guarantee IS DISTINCT FROM usaspending.face_value_loan_guarantee)
        OR (broker.fain IS DISTINCT FROM usaspending.fain)
        OR (broker.federal_action_obligation IS DISTINCT FROM usaspending.federal_action_obligation)
        OR (broker.fiscal_year_and_quarter_co IS DISTINCT FROM usaspending.fiscal_year_and_quarter_co)
        OR (broker.funding_agency_code IS DISTINCT FROM usaspending.funding_agency_code)
        OR (broker.funding_office_code IS DISTINCT FROM usaspending.funding_office_code)
        OR (broker.funding_sub_tier_agency_co IS DISTINCT FROM usaspending.funding_sub_tier_agency_co)
        OR (broker.legal_entity_address_line1 IS DISTINCT FROM usaspending.legal_entity_address_line1)
        OR (broker.legal_entity_address_line2 IS DISTINCT FROM usaspending.legal_entity_address_line2)
        OR (broker.legal_entity_address_line3 IS DISTINCT FROM usaspending.legal_entity_address_line3)
        OR (broker.legal_entity_country_code IS DISTINCT FROM usaspending.legal_entity_country_code)
        OR (broker.legal_entity_foreign_city IS DISTINCT FROM usaspending.legal_entity_foreign_city)
        OR (broker.legal_entity_foreign_posta IS DISTINCT FROM usaspending.legal_entity_foreign_posta)
        OR (broker.legal_entity_foreign_provi IS DISTINCT FROM usaspending.legal_entity_foreign_provi)
        OR (broker.legal_entity_zip5 IS DISTINCT FROM usaspending.legal_entity_zip5)
        OR (broker.legal_entity_zip_last4 IS DISTINCT FROM usaspending.legal_entity_zip_last4)
        OR (broker.non_federal_funding_amount IS DISTINCT FROM usaspending.non_federal_funding_amount)
        OR (broker.original_loan_subsidy_cost IS DISTINCT FROM usaspending.original_loan_subsidy_cost)
        OR (broker.period_of_performance_curr IS DISTINCT FROM usaspending.period_of_performance_curr)
        OR (broker.period_of_performance_star IS DISTINCT FROM usaspending.period_of_performance_star)
        OR (broker.place_of_performance_code IS DISTINCT FROM usaspending.place_of_performance_code)
        OR (broker.place_of_performance_congr IS DISTINCT FROM usaspending.place_of_performance_congr)
        OR (broker.place_of_perform_country_c IS DISTINCT FROM usaspending.place_of_perform_country_c)
        OR (broker.place_of_performance_forei IS DISTINCT FROM usaspending.place_of_performance_forei)
        OR (broker.place_of_performance_zip4a IS DISTINCT FROM usaspending.place_of_performance_zip4a)
        OR (broker.record_type IS DISTINCT FROM usaspending.record_type)
        OR (broker.sai_number IS DISTINCT FROM usaspending.sai_number)
        OR (broker.uri IS DISTINCT FROM usaspending.uri)
        OR (broker.legal_entity_congressional IS DISTINCT FROM usaspending.legal_entity_congressional)
        OR (broker.total_funding_amount IS DISTINCT FROM usaspending.total_funding_amount)
        OR (broker.cfda_title IS DISTINCT FROM usaspending.cfda_title)
        OR (broker.awarding_agency_name IS DISTINCT FROM usaspending.awarding_agency_name)
        OR (broker.awarding_sub_tier_agency_n IS DISTINCT FROM usaspending.awarding_sub_tier_agency_n)
        OR (broker.funding_agency_name IS DISTINCT FROM usaspending.funding_agency_name)
        OR (broker.funding_sub_tier_agency_na IS DISTINCT FROM usaspending.funding_sub_tier_agency_na)
        OR (broker.is_historical IS DISTINCT FROM usaspending.is_historical)
        OR (broker.place_of_perform_county_na IS DISTINCT FROM usaspending.place_of_perform_county_na)
        OR (broker.place_of_perform_state_nam IS DISTINCT FROM usaspending.place_of_perform_state_nam)
        OR (broker.place_of_performance_city IS DISTINCT FROM usaspending.place_of_performance_city)
        OR (broker.legal_entity_city_name IS DISTINCT FROM usaspending.legal_entity_city_name)
        OR (broker.legal_entity_county_code IS DISTINCT FROM usaspending.legal_entity_county_code)
        OR (broker.legal_entity_county_name IS DISTINCT FROM usaspending.legal_entity_county_name)
        OR (broker.legal_entity_state_code IS DISTINCT FROM usaspending.legal_entity_state_code)
        OR (broker.legal_entity_state_name IS DISTINCT FROM usaspending.legal_entity_state_name)
        OR (broker.modified_at IS DISTINCT FROM usaspending.modified_at::TIMESTAMP WITHOUT TIME ZONE)
        OR (broker.afa_generated_unique IS DISTINCT FROM usaspending.afa_generated_unique)
        OR (broker.is_active IS DISTINCT FROM usaspending.is_active)
        OR (broker.awarding_office_name IS DISTINCT FROM usaspending.awarding_office_name)
        OR (broker.funding_office_name IS DISTINCT FROM usaspending.funding_office_name)
        OR (broker.legal_entity_city_code IS DISTINCT FROM usaspending.legal_entity_city_code)
        OR (broker.legal_entity_foreign_descr IS DISTINCT FROM usaspending.legal_entity_foreign_descr)
        OR (broker.legal_entity_country_name IS DISTINCT FROM usaspending.legal_entity_country_name)
        OR (broker.place_of_perform_country_n IS DISTINCT FROM usaspending.place_of_perform_country_n)
        OR (broker.place_of_perform_county_co IS DISTINCT FROM usaspending.place_of_perform_county_co)
        OR (broker.submission_id IS DISTINCT FROM usaspending.submission_id::text)
        OR (broker.place_of_perfor_state_code IS DISTINCT FROM usaspending.place_of_perfor_state_code)
        OR (broker.place_of_performance_zip5 IS DISTINCT FROM usaspending.place_of_performance_zip5)
        OR (broker.place_of_perform_zip_last4 IS DISTINCT FROM usaspending.place_of_perform_zip_last4)
        OR (broker.action_type_description IS DISTINCT FROM usaspending.action_type_description)
        OR (broker.assistance_type_desc IS DISTINCT FROM usaspending.assistance_type_desc)
        OR (broker.business_funds_ind_desc IS DISTINCT FROM usaspending.business_funds_ind_desc)
        OR (broker.business_types_desc IS DISTINCT FROM usaspending.business_types_desc)
        OR (broker.correction_delete_ind_desc IS DISTINCT FROM usaspending.correction_delete_ind_desc)
        OR (broker.record_type_description IS DISTINCT FROM usaspending.record_type_description)
        OR (broker.ultimate_parent_legal_enti IS DISTINCT FROM usaspending.ultimate_parent_legal_enti)
        OR (broker.ultimate_parent_unique_ide IS DISTINCT FROM usaspending.ultimate_parent_unique_ide)
        OR (broker.unique_award_key IS DISTINCT FROM usaspending.unique_award_key)
        OR (broker.high_comp_officer1_amount IS DISTINCT FROM usaspending.officer_1_amount)
        OR (broker.high_comp_officer1_full_na IS DISTINCT FROM usaspending.officer_1_name)
        OR (broker.high_comp_officer2_amount IS DISTINCT FROM usaspending.officer_2_amount)
        OR (broker.high_comp_officer2_full_na IS DISTINCT FROM usaspending.officer_2_name)
        OR (broker.high_comp_officer3_amount IS DISTINCT FROM usaspending.officer_3_amount)
        OR (broker.high_comp_officer3_full_na IS DISTINCT FROM usaspending.officer_3_name)
        OR (broker.high_comp_officer4_amount IS DISTINCT FROM usaspending.officer_4_amount)
        OR (broker.high_comp_officer4_full_na IS DISTINCT FROM usaspending.officer_4_name)
        OR (broker.high_comp_officer5_amount IS DISTINCT FROM usaspending.officer_5_amount)
        OR (broker.high_comp_officer5_full_na IS DISTINCT FROM usaspending.officer_5_name)
    )
)