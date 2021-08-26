alter table brs.project_details_config add column if not exists update_first_value_only_id varchar;

alter table brs.project_details add column if not exists ahj_inspection_start_time_ppscfv_id integer;
alter table brs.project_details add column if not exists ahj_inspection_scheduled_date_ppscfv_id integer;
alter table brs.project_details add column if not exists installation_agreement_signed_date_ppscfv_id integer;
alter table brs.project_details add column if not exists credit_decision_date_ppscfv_id integer;
alter table brs.project_details add column if not exists installation_scheduled_ppscfv_id integer;
alter table brs.project_details add column if not exists permit_pack_complete_ppscfv_id integer;
alter table brs.project_details add column if not exists site_survey_verified_date_ppscfv_id integer;
alter table brs.project_details add column if not exists ahj_final_inspection_verified_ppscfv_id integer;
alter table brs.project_details add column if not exists final_design_created_timestamp_ppscfv_id integer;
alter table brs.project_details add column if not exists final_design_sent_to_homeowner_date_ppscfv_id integer;
alter table brs.project_details add column if not exists financial_agreement_signed_date_ppscfv_id integer;
alter table brs.project_details add column if not exists credit_check_ppscfv_id integer;
alter table brs.project_details add column if not exists plan_set_created_date_ppscfv_id integer;
alter table brs.project_details add column if not exists final_design_complete_date_ppscfv_id integer;
alter table brs.project_details add column if not exists substantial_completion_date_ppscfv_id integer;
alter table brs.project_details add column if not exists final_design_signed_date_ppscfv_id integer;
alter table brs.project_details add column if not exists final_completion_submitted_date_ppscfv_id integer;
alter table brs.project_details add column if not exists final_completion_approved_date_ppscfv_id integer;
alter table brs.project_details add column if not exists appointment_check_in_ppscfv_id integer;
alter table brs.project_details add column if not exists utility_bill_verified_date_ppscfv_id integer;
alter table brs.project_details add column if not exists proof_of_homeowners_insurance_obtained_date_ppscfv_id integer;
alter table brs.project_details add column if not exists first_cash_payment_paid_date_ppscfv_id integer;
alter table brs.project_details add column if not exists proof_of_homeowners_insurance_required_ppscfv_id integer;
alter table brs.project_details add column if not exists online_submission_time_ppscfv_id integer;
alter table brs.project_details add column if not exists permit_pack_submittal_end_time_ppscfv_id integer;
alter table brs.project_details add column if not exists permit_approved_date_ppscfv_id integer;
alter table brs.project_details add column if not exists setter_milestone_pay_ppscfv_id integer;
alter table brs.project_details add column if not exists first_appointment_pitched_ppscfv_id integer;
alter table brs.project_details add column if not exists first_appointment_missed_ppscfv_id integer;
alter table brs.project_details add column if not exists first_appointment_not_pitched_or_missed_ppscfv_id integer;



create index if not exists pd_ahj_inspection_start_time_ppscfv_id_idx
  on brs.project_details (ahj_inspection_start_time_ppscfv_id);
create index if not exists pd_ahj_inspection_scheduled_date_ppscfv_id_idx
  on brs.project_details (ahj_inspection_scheduled_date_ppscfv_id);
create index if not exists pd_installation_agreement_signed_date_ppscfv_id_idx
  on brs.project_details (installation_agreement_signed_date_ppscfv_id);
create index if not exists pd_credit_decision_date_ppscfv_id_idx
  on brs.project_details (credit_decision_date_ppscfv_id);
create index if not exists pd_installation_scheduled_ppscfv_id_idx
  on brs.project_details (installation_scheduled_ppscfv_id);
create index if not exists pd_permit_pack_complete_ppscfv_id_idx
  on brs.project_details (permit_pack_complete_ppscfv_id);
create index if not exists pd_site_survey_verified_date_ppscfv_id_idx
  on brs.project_details (site_survey_verified_date_ppscfv_id);
create index if not exists pd_ahj_final_inspection_verified_ppscfv_id_idx
  on brs.project_details (ahj_final_inspection_verified_ppscfv_id);
create index if not exists pd_final_design_created_timestamp_ppscfv_id_idx
  on brs.project_details (final_design_created_timestamp_ppscfv_id);
create index if not exists pd_final_design_sent_to_homeowner_date_ppscfv_id_idx
  on brs.project_details (final_design_sent_to_homeowner_date_ppscfv_id);
create index if not exists pd_financial_agreement_signed_date_ppscfv_id_idx
  on brs.project_details (financial_agreement_signed_date_ppscfv_id);
create index if not exists pd_credit_check_ppscfv_id_idx
  on brs.project_details (credit_check_ppscfv_id);
create index if not exists pd_plan_set_created_date_ppscfv_id_idx
  on brs.project_details (plan_set_created_date_ppscfv_id);
create index if not exists pd_final_design_complete_date_ppscfv_id_idx
  on brs.project_details (final_design_complete_date_ppscfv_id);
create index if not exists pd_substantial_completion_date_ppscfv_id_idx
  on brs.project_details (substantial_completion_date_ppscfv_id);
create index if not exists pd_final_design_signed_date_ppscfv_id_idx
  on brs.project_details (final_design_signed_date_ppscfv_id);
create index if not exists pd_final_completion_submitted_date_ppscfv_id_idx
  on brs.project_details (final_completion_submitted_date_ppscfv_id);
create index if not exists pd_final_completion_approved_date_ppscfv_id_idx
  on brs.project_details (final_completion_approved_date_ppscfv_id);
create index if not exists pd_appointment_check_in_ppscfv_id_idx
  on brs.project_details (appointment_check_in_ppscfv_id);
create index if not exists pd_utility_bill_verified_date_ppscfv_id_idx
  on brs.project_details (utility_bill_verified_date_ppscfv_id);
create index if not exists pd_proof_of_homeowners_insurance_obtained_date_ppscfv_id_idx
  on brs.project_details (proof_of_homeowners_insurance_obtained_date_ppscfv_id);
create index if not exists pd_first_cash_payment_paid_date_ppscfv_id_idx
  on brs.project_details (first_cash_payment_paid_date_ppscfv_id);
create index if not exists pd_proof_of_homeowners_insurance_required_ppscfv_id_idx
  on brs.project_details (proof_of_homeowners_insurance_required_ppscfv_id);
create index if not exists pd_online_submission_time_ppscfv_id_idx
  on brs.project_details (online_submission_time_ppscfv_id);
create index if not exists pd_permit_pack_submittal_end_time_ppscfv_id_idx
  on brs.project_details (permit_pack_submittal_end_time_ppscfv_id);
create index if not exists pd_permit_approved_date_ppscfv_id_idx
  on brs.project_details (permit_approved_date_ppscfv_id);
create index if not exists pd_setter_milestone_pay_ppscfv_id_idx
  on brs.project_details (setter_milestone_pay_ppscfv_id);
create index if not exists pd_first_appointment_pitched_ppscfv_id_idx
  on brs.project_details (first_appointment_pitched_ppscfv_id);
create index if not exists pd_first_appointment_missed_ppscfv_id_idx
  on brs.project_details (first_appointment_missed_ppscfv_id);
create index if not exists pd_first_appointment_not_pitched_or_missed_ppscfv_id_idx
  on brs.project_details (first_appointment_not_pitched_or_missed_ppscfv_id);


update brs.project_details_config set update_first_value_only_id = 'ahj_inspection_start_time_ppscfv_id' where id = 4375;
update brs.project_details_config set update_first_value_only_id = 'ahj_inspection_start_time_ppscfv_id' where id = 4376;
update brs.project_details_config set update_first_value_only_id = 'ahj_inspection_scheduled_date_ppscfv_id' where id = 4374;
update brs.project_details_config set update_first_value_only_id = 'installation_agreement_signed_date_ppscfv_id' where id = 1;
update brs.project_details_config set update_first_value_only_id = 'credit_decision_date_ppscfv_id' where id = 10;
update brs.project_details_config set update_first_value_only_id = 'installation_scheduled_ppscfv_id' where id = 4784;
update brs.project_details_config set update_first_value_only_id = 'permit_pack_complete_ppscfv_id' where id = 4783;
update brs.project_details_config set update_first_value_only_id = 'permit_pack_complete_ppscfv_id' where id = 4822;
update brs.project_details_config set update_first_value_only_id = 'permit_pack_complete_ppscfv_id' where id = 4827;
update brs.project_details_config set update_first_value_only_id = 'site_survey_verified_date_ppscfv_id' where id = 17;
update brs.project_details_config set update_first_value_only_id = 'ahj_final_inspection_verified_ppscfv_id' where id = 25;
update brs.project_details_config set update_first_value_only_id = 'final_design_created_timestamp_ppscfv_id' where id = 4802;
update brs.project_details_config set update_first_value_only_id = 'final_design_sent_to_homeowner_date_ppscfv_id' where id = 11;
update brs.project_details_config set update_first_value_only_id = 'financial_agreement_signed_date_ppscfv_id' where id = 13;
update brs.project_details_config set update_first_value_only_id = 'credit_check_ppscfv_id' where id = 9;
update brs.project_details_config set update_first_value_only_id = 'site_survey_verified_date_ppscfv_id' where id = 5897;
update brs.project_details_config set update_first_value_only_id = 'ahj_final_inspection_verified_ppscfv_id' where id = 156;
update brs.project_details_config set update_first_value_only_id = 'plan_set_created_date_ppscfv_id' where id = 81;
update brs.project_details_config set update_first_value_only_id = 'final_design_complete_date_ppscfv_id' where id = 4179;
update brs.project_details_config set update_first_value_only_id = 'substantial_completion_date_ppscfv_id' where id = 20;
update brs.project_details_config set update_first_value_only_id = 'final_design_signed_date_ppscfv_id' where id = 12;
update brs.project_details_config set update_first_value_only_id = 'final_completion_submitted_date_ppscfv_id' where id = 31;
update brs.project_details_config set update_first_value_only_id = 'final_completion_approved_date_ppscfv_id' where id = 30;
update brs.project_details_config set update_first_value_only_id = 'appointment_check_in_ppscfv_id' where id = 181;
update brs.project_details_config set update_first_value_only_id = 'utility_bill_verified_date_ppscfv_id' where id = 22;
update brs.project_details_config set update_first_value_only_id = 'proof_of_homeowners_insurance_obtained_date_ppscfv_id' where id = 15;
update brs.project_details_config set update_first_value_only_id = 'financial_agreement_signed_date_ppscfv_id' where id = 179;
update brs.project_details_config set update_first_value_only_id = 'first_cash_payment_paid_date_ppscfv_id' where id = 14;
update brs.project_details_config set update_first_value_only_id = 'proof_of_homeowners_insurance_required_ppscfv_id' where id = 16;
update brs.project_details_config set update_first_value_only_id = 'online_submission_time_ppscfv_id' where id = 5896;
update brs.project_details_config set update_first_value_only_id = 'permit_pack_submittal_end_time_ppscfv_id' where id = 75;
update brs.project_details_config set update_first_value_only_id = 'permit_approved_date_ppscfv_id' where id = 74;
update brs.project_details_config set update_first_value_only_id = 'ahj_inspection_scheduled_date_ppscfv_id' where id = 4335;
