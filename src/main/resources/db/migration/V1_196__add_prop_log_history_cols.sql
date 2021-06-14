alter table brs.proposal_log_history
    add column if not exists monthly_cost_today_after_solar varchar(100);

alter table brs.proposal_log_history
    add column if not exists monthly_cost_5_years_after_solar varchar(100);

alter table brs.proposal_log_history
    add column if not exists monthly_cost_5_years_before_solar varchar(100);

alter table brs.proposal_log_history
    add column if not exists twenty_five_year_cost_before_solar varchar(100);

alter table brs.proposal_log_history
    add column if not exists twenty_five_year_savings_after_solar varchar(100);

alter table brs.proposal_log_history
    add column if not exists monthly_payment_first_5_years_tax_to_loan varchar(100);

alter table brs.proposal_log_history
    add column if not exists monthly_payment_first_5_years_tax_and_savings_to_loan varchar(100);

alter table brs.proposal_log_history
    add column if not exists monthly_payment_6_to_24_years_tax_to_loan varchar(100);

alter table brs.proposal_log_history
    add column if not exists monthly_payment_6_to_24_years_tax_and_savings_to_loan varchar(100);

alter table brs.proposal_log_history
    add column if not exists monthly_payment_first_5_years_no_incentive varchar(100);

alter table brs.proposal_log_history
    add column if not exists monthly_payment_6_to_24_years_no_incentive varchar(100);

alter table brs.proposal_log_history
    add column if not exists smart_start_months_19_to_60_monthly_rebate varchar(100);

alter table brs.proposal_log_history
    add column if not exists month_19_required_payment varchar(100);

alter table brs.proposal_log_history
    add column if not exists month_0_to_18_loan_payment varchar(100);

alter table brs.proposal_log_history
    add column if not exists month_0_to_18_net_payment varchar(100);

alter table brs.proposal_log_history
    add column if not exists month_19_to_60_net_payment varchar(100);

alter table brs.proposal_log_history
    add column if not exists month_60_plus_net_payment varchar(100);

alter table brs.proposal_log_history
    add column if not exists total_ancillary_cost varchar(100);

alter table brs.proposal_log_history
    add column if not exists loan_product varchar(100);

alter table brs.proposal_log_history
    add column if not exists number_of_promotion_payments varchar(100);

alter table brs.proposal_log_history
    add column if not exists promotion_payment_amount varchar(100);

alter table brs.proposal_log_history
    add column if not exists proposal_tool_version varchar(100);

