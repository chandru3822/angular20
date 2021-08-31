alter table brs.proposal_log_history
    add column if not exists storage_brand varchar(100);

alter table brs.proposal_log_history
    add column if not exists storage_size_kwh varchar(100);

alter table brs.proposal_log_history
    add column if not exists financed_ancillary_cost_with_fees varchar(100);

alter table brs.proposal_log_history
    add column if not exists financed_system_cost_with_fees varchar(100);

alter table brs.proposal_log_history
    add column if not exists discount varchar(100);

alter table brs.proposal_log_history
    add column if not exists manual_adjustment varchar(100);

alter table brs.proposal_log_history
    add column if not exists total_promotion_amount varchar(100);

alter table brs.proposal_log_history
    add column if not exists storage_cost_with_fees varchar(100);

alter table brs.proposal_log_history
    add column if not exists site_survey_resource_type varchar(100);

alter table brs.proposal_log_history
    add column if not exists site_survey_time_estimate varchar(100);

alter table brs.proposal_log_history
    add column if not exists site_survey_items varchar(100);



