alter table brs.proposal_log_history
  add column if not exists custom_adder_amount numeric;
alter table brs.proposal_log_history
  add column if not exists custom_adders jsonb;
alter table brs.proposal_log_history
  add column if not exists selected_adder_amount numeric;
alter table brs.proposal_log_history
  add column if not exists selected_adders jsonb;
alter table brs.proposal_log_history
  add column if not exists auto_applied_adder_amount numeric;
alter table brs.proposal_log_history
  add column if not exists auto_applied_adders jsonb;
alter table brs.proposal_log_history
  add column if not exists storage_cost numeric;
alter table brs.proposal_log_history
  add column if not exists proposal_version_id bigint;
alter table brs.proposal_log_history
  add column if not exists redline_per_watt numeric;
alter table brs.proposal_log_history
  add column if not exists dealer_id bigint;
alter table brs.proposal_log_history
  add column if not exists desired_commission_adder numeric;
alter table brs.proposal_log_history
  add column if not exists financial_product_id bigint;
alter table brs.proposal_log_history
  add column if not exists override_plan_id bigint;

alter table brs.financial_details
  add column if not exists proposal_version_id bigint;
alter table brs.financial_details
  add column if not exists proposal_custom_adder_amount numeric;
alter table brs.financial_details
  add column if not exists proposal_selected_adder_amount numeric;
alter table brs.financial_details
  add column if not exists project_custom_adder_amount numeric;
alter table brs.financial_details
  add column if not exists project_selected_adder_amount numeric;
alter table brs.financial_details
  add column if not exists auto_applied_adder_amount numeric;
alter table brs.financial_details
  add column if not exists desired_commission_adder numeric;

drop function if exists brs.get_commission_data(p_project_id bigint);
drop function if exists brs.get_commission_data(p_project_id bigint, p_from_booking boolean);


update flow.custom_field_group_assignment
set data_view_child_field_config_id = null
where id in (select id from flow.data_view_child_field_config where unique_behavior_type_id
                                                                      in (26,31,33,27,30,28,29,34));

delete from flow.data_view_child_field_config
where unique_behavior_type_id in (26,31,33,27,30,28,29,34);

delete from flow.unique_behavior_type where id in (26,31,33,27,30,28,29,34);
