
alter table  brs.residual_ledger drop column if exists user_project_id;
alter table  brs.residual_ledger add column if not exists user_id integer not null;
alter table brs.residual_ledger drop constraint if exists residual_ledger_user_id_fk;
alter table brs.residual_ledger add
    CONSTRAINT residual_ledger_user_id_fk FOREIGN KEY (user_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION;
drop table if exists flow.user_project;

alter table flow.attachment alter column filename type character varying(200);
alter table flow.user alter column date_modified drop not null;



CREATE TABLE if NOT EXISTS brs.project_details_config
(
    id        serial                NOT NULL,
    company_id integer not null,
    custom_field_group_assignment_id integer NOT NULL,
    field_to_update character varying (100) not null,
    data_type_id integer not null,
    CONSTRAINT project_details_config_pk PRIMARY KEY (id),
    CONSTRAINT pdc_custom_field_group_assignment_id_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pdc_data_type_id_fk FOREIGN KEY (data_type_id)
        REFERENCES flow.data_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pdc_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
CREATE INDEX if not exists pdc_custom_field_group_assignment_id_idx ON brs.project_details_config (custom_field_group_assignment_id);
CREATE INDEX if not exists pdc_data_type_id_idx ON brs.project_details_config (data_type_id);
CREATE INDEX if not exists pdc_company_id_idx ON brs.project_details_config (company_id);

insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id )
values(3,11,'installation_agreement_signed_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id )
values(3,460,'primary_financier',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id )
values(3,54,'num_of_promotion_payments',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id )
values(3,172,'product',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id )
values(3,51,'total_promotion_amount',4);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id )
values(3,400,'entered_into_payment_system_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id )
values(3,467,'cancelled_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id )
values(3,7,'closer_user_id',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id )
values(3,61,'credit_check',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id )
values(3,62,'credit_decision_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,59,'final_design_sent_to_homeowner_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,459,'final_design_signed_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,13,'financial_agreement_signed_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,210,'first_cash_payment_paid_date',1);
-- insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
-- values(3,404,'on_hold',3);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,110,'proof_of_homeowners_insurance_obtained_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,111,'proof_of_homeowners_insurance_required',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,31,'site_survey_verified_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,401,'source',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,402,'stage',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,138,'substantial_completion_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,40,'system_size',4);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,109,'utility_bill_verified_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,209,'first_cash_payment_amount',4);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,49,'total_system_price',4);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,152,'ahj_final_inspection_verified',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,5,'closer_appointment_start',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,6,'closer_appointment_end',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,4,'closer_appointment_outcome',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,202,'Energized_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,207,'final_completion_approved_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,206,'final_completion_submitted_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,36,'final_design_qa_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,12,'financial_agreement_sent_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,208,'first_cash_payment_invoiced_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,119,'hoa_approval_received_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,118,'hoa_request_for_approval_submitted_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,190,'in_house_mpu_end_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,189,'in_house_mpu_start_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,181,'in_house_mpu_inspection_scheduled_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,180,'in_house_mpu_materials_ordered_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,125,'in_house_mpu_permit_approved_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,120,'in_house_mpu_permit_pack_complete_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,122,'in_house_mpu_permit_submittal_end_date',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,121,'in_house_mpu_permit_submittal_start_date',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,124,'in_house_mpu_permit_submittal_verified_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,191,'in_house_mpu_resource',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,140,'installation_closeout_end_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,139,'installation_closeout_start_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,135,'installation_start_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,136,'installation_end_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,126,'installation_ready_to_schedule_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,137,'installation_resource',6);
 insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
 values(3,114,'interconnection_application_approved_date',1);
 insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
 values(3,112,'interconnection_application_signed_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,113,'interconnection_application_submitted_to_utility_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,48,'interest_rate',4);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,14,'introduction_call',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,44,'inverter_brand',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,395,'lead_source',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,396,'lead_source_detail',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,46,'loan_amount',4);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,58,'loan_term',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,142,'materials_ordered_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,176,'low_production_inquiry_requested_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,175,'low_production_inquiry_resolved_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,177,'low_production_inquiry_reviewed_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,194,'non_standard_installation_work_end_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,193,'non_standard_installation_work_start_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,195,'non_standard_installation_resource',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,196,'non_standard_installation_work_verified_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,41,'panel_brand',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,42,'panel_quantity',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,43,'panel_watts',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,106,'permit_approved_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,98,'permit_pack_submittal_end_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,97,'permit_pack_submittal_start_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,104,'permit_pack_submittal_verified_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,129,'permit_pickup_end_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,128,'permit_pickup_start_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,187,'permit_pickup_verified_date',1);
 insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
 values(3,63,'plan_set_created_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,65,'plan_set_qa_date',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,50,'referral_promotion_amount',4);
 insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
 values(3,461,'secondary_financier',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,212,'second_cash_payment_amount',4);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,211,'second_cash_payment_invoiced_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,213,'second_cash_payment_paid_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,16,'site_survey_end_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,15,'site_survey_start_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,19,'site_survey_type',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
 values(3,20,'site_survey_uploaded_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,82,'structural_analysis_required_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,83,'structural_analysis_complete_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,167,'structural_engineering_review_complete_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,165,'structural_engineering_review_required_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,87,'structural_engineering_stamp_received_date',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,86,'structural_engineering_stamp_requested_date',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,173,'structural_post_install_engineering_letter_complete_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,147,'substantial_completion_approved_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,53,'total_ancillary_cost_with_fees',4);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,52,'total_cash_down_payment',4);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,155,'utility_meter_ordered_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,157,'utility_meter_set_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,184,'utility_rebate_application_approved_date',1);
 insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
 values(3,182,'utility_rebate_application_sent_to_homeowner_date',1);
 insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
 values(3,436,'utility_rebate_application_signed_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,160,'work_order_end_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,161,'work_order_resource',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,159,'work_order_start_time',2);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,162,'work_order_verified_date',1);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,472,'verified_setter_lead',3);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,473,'verified_usage',3);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,405,'ahj',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,470,'utility_company',6);
insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id)
values(3,482,'installation_agreement_sent_to_homeowner',2);



CREATE TABLE if NOT EXISTS brs.project_details
(
    id        serial                NOT NULL,
    company_id integer,
    project_id integer not null,
    primary_financier integer,
    installation_agreement_signed_date date,
    num_of_promotion_payments integer,
    product integer,
    total_promotion_amount numeric,
    entered_into_payment_system_date date,
    cancelled_date date,
    closer_user_id integer,
    credit_check integer,
    credit_decision_date date,
    final_design_sent_to_homeowner_date timestamp without time zone,
    final_design_signed_date date,
    financial_agreement_signed_date date,
    first_cash_payment_paid_date date,
--     on_hold boolean,
    proof_of_homeowners_insurance_obtained_date date,
    proof_of_homeowners_insurance_required integer,
    site_survey_verified_date date,
    source integer,
    stage integer,
    substantial_completion_date date,
    system_size numeric,
    utility_bill_verified_date date,
    first_cash_payment_amount numeric,
    total_system_price numeric,
    ahj_final_inspection_verified date,
    closer_appointment_start  timestamp without time zone,
    closer_appointment_end timestamp without time zone,
    closer_appointment_outcome integer,
    Energized_date  date,
    final_completion_approved_date date,
    final_completion_submitted_date date,
    final_design_qa_date date,
    financial_agreement_sent_date date,
    first_cash_payment_invoiced_date date,
    hoa_approval_received_date date,
    hoa_request_for_approval_submitted_date date,
    in_house_mpu_end_time timestamp without time zone,
    in_house_mpu_start_time timestamp without time zone,
    in_house_mpu_inspection_scheduled_date date,
    in_house_mpu_materials_ordered_date date,
    in_house_mpu_permit_approved_date date,
    in_house_mpu_permit_pack_complete_date date,
    in_house_mpu_permit_submittal_end_date timestamp without time zone,
    in_house_mpu_permit_submittal_start_date timestamp without time zone,
    in_house_mpu_permit_submittal_verified_date date,
    in_house_mpu_resource integer,
    installation_closeout_end_time timestamp without time zone,
    installation_closeout_start_time timestamp without time zone,
    installation_start_time timestamp without time zone,
    installation_end_time timestamp without time zone,
    installation_ready_to_schedule_date date,
    installation_resource integer,
    interconnection_application_approved_date date,
    interconnection_application_signed_date date,
    interconnection_application_submitted_to_utility_date date,
    interest_rate numeric,
    introduction_call integer,
    inverter_brand integer,
    lead_source integer,
    lead_source_detail integer,
    loan_amount numeric,
    loan_term integer,
    materials_ordered_date date,
    low_production_inquiry_requested_date date,
    low_production_inquiry_resolved_date date,
    low_production_inquiry_reviewed_date date,
    non_standard_installation_work_end_time timestamp without time zone,
    non_standard_installation_work_start_time timestamp without time zone,
    non_standard_installation_resource integer,
    non_standard_installation_work_verified_date date,
    panel_brand integer,
    panel_quantity integer,
    panel_watts integer,
    permit_approved_date date,
    permit_pack_submittal_end_time timestamp without time zone,
    permit_pack_submittal_start_time timestamp without time zone,
    permit_pack_submittal_verified_date date,
    permit_pickup_end_time timestamp without time zone,
    permit_pickup_start_time timestamp without time zone,
    permit_pickup_verified_date date,
    plan_set_created_date date,
    plan_set_qa_date timestamp without time zone,
    referral_promotion_amount numeric,
    secondary_financier integer,
    second_cash_payment_amount numeric,
    second_cash_payment_invoiced_date date,
    second_cash_payment_paid_date date,
    site_survey_end_time timestamp without time zone,
    site_survey_start_time timestamp without time zone,
    site_survey_type integer,
    site_survey_uploaded_date date,
    structural_analysis_required_date date,
    structural_analysis_complete_date date,
    structural_engineering_review_complete_date date,
    structural_engineering_review_required_date date,
    structural_engineering_stamp_received_date timestamp without time zone,
    structural_engineering_stamp_requested_date timestamp without time zone,
    structural_post_install_engineering_letter_complete_date date,
    substantial_completion_approved_date date,
    total_ancillary_cost_with_fees numeric,
    total_cash_down_payment numeric,
    utility_meter_ordered_date date,
    utility_meter_set_date date,
    utility_rebate_application_approved_date date,
    utility_rebate_application_sent_to_homeowner_date date,
    utility_rebate_application_signed_date date,
    work_order_end_time timestamp without time zone,
    work_order_resource integer,
    work_order_start_time timestamp without time zone,
    work_order_verified_date date,
    verified_setter_lead boolean,
    verified_usage boolean,
    ahj integer,
    utility_company integer,
    installation_agreement_sent_to_homeowner timestamp without time zone,
    CONSTRAINT project_details_pk PRIMARY KEY (id),
    CONSTRAINT pb_project_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pb_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);


CREATE INDEX if not exists pd_company_id_idx ON brs.project_details (company_id);
CREATE INDEX if not exists pd_project_id_idx ON brs.project_details (project_id);
CREATE INDEX if not exists pd_installation_agreement_signed_date_idx ON brs.project_details (installation_agreement_signed_date);
CREATE INDEX if not exists pd_primary_financier_idx ON brs.project_details (primary_financier);
CREATE INDEX if not exists pd_num_of_promotion_payments_idx ON brs.project_details (num_of_promotion_payments);
CREATE INDEX if not exists pd_product_idx ON brs.project_details (product);
CREATE INDEX if not exists pd_total_promotion_amount_idx ON brs.project_details (total_promotion_amount);
CREATE INDEX if not exists pd_entered_into_payment_system_date_idx ON brs.project_details (entered_into_payment_system_date);
CREATE INDEX if not exists pd_cancelled_date_idx ON brs.project_details (cancelled_date);
CREATE INDEX if not exists pd_closer_user_id_idx ON brs.project_details (closer_user_id);
CREATE INDEX if not exists pd_credit_check_idx ON brs.project_details (credit_check);
CREATE INDEX if not exists pd_credit_decision_date_idx ON brs.project_details (credit_decision_date);
CREATE INDEX if not exists pd_final_design_sent_to_homeowner_date_idx ON brs.project_details (final_design_sent_to_homeowner_date);
CREATE INDEX if not exists pd_final_design_signed_date_idx ON brs.project_details (final_design_signed_date);
CREATE INDEX if not exists pd_financial_agreement_signed_date_idx ON brs.project_details (financial_agreement_signed_date);
CREATE INDEX if not exists pd_first_cash_payment_paid_date_idx ON brs.project_details (first_cash_payment_paid_date);
-- CREATE INDEX if not exists pd_on_hold_idx ON brs.project_details (on_hold);
CREATE INDEX if not exists pd_proof_of_homeowners_insurance_obtained_date_idx ON brs.project_details (proof_of_homeowners_insurance_obtained_date);
CREATE INDEX if not exists pd_proof_of_homeowners_insurance_required_idx ON brs.project_details (proof_of_homeowners_insurance_required);
CREATE INDEX if not exists pd_site_survey_verified_date_idx ON brs.project_details (site_survey_verified_date);
CREATE INDEX if not exists pd_source_idx ON brs.project_details (source);
CREATE INDEX if not exists pd_stage_idx ON brs.project_details (stage);
CREATE INDEX if not exists pd_substantial_completion_date_idx ON brs.project_details (substantial_completion_date);
CREATE INDEX if not exists pd_system_size_idx ON brs.project_details (system_size);
CREATE INDEX if not exists pd_utility_bill_verified_date_idx ON brs.project_details (utility_bill_verified_date);
CREATE INDEX if not exists pd_first_cash_payment_amount_idx ON brs.project_details (first_cash_payment_amount);
CREATE INDEX if not exists pd_total_system_price_idx ON brs.project_details (total_system_price);
CREATE INDEX if not exists pd_ahj_final_inspection_verified_idx ON brs.project_details (ahj_final_inspection_verified);
CREATE INDEX if not exists pd_closer_appointment_start_idx ON brs.project_details (closer_appointment_start);
CREATE INDEX if not exists pd_closer_appointment_end_idx ON brs.project_details (closer_appointment_end);
CREATE INDEX if not exists pd_closer_appointment_outcome_idx ON brs.project_details (closer_appointment_outcome);
CREATE INDEX if not exists pd_Energized_date_idx ON brs.project_details (Energized_date);
CREATE INDEX if not exists pd_final_completion_approved_date_idx ON brs.project_details (final_completion_approved_date);
CREATE INDEX if not exists pd_final_completion_submitted_date_idx ON brs.project_details (final_completion_submitted_date);
CREATE INDEX if not exists pd_final_design_qa_date_idx ON brs.project_details (final_design_qa_date);
CREATE INDEX if not exists pd_financial_agreement_sent_date_idx ON brs.project_details (financial_agreement_sent_date);
CREATE INDEX if not exists pd_first_cash_payment_invoiced_date_idx ON brs.project_details (first_cash_payment_invoiced_date);
CREATE INDEX if not exists pd_hoa_approval_received_date_idx ON brs.project_details (hoa_approval_received_date);
CREATE INDEX if not exists pd_hoa_request_for_approval_submitted_date_idx ON brs.project_details (hoa_request_for_approval_submitted_date);
CREATE INDEX if not exists pd_in_house_mpu_end_time_idx ON brs.project_details (in_house_mpu_end_time);
CREATE INDEX if not exists pd_in_house_mpu_start_time_idx ON brs.project_details (in_house_mpu_start_time);
CREATE INDEX if not exists pd_in_house_mpu_inspection_scheduled_date_idx ON brs.project_details (in_house_mpu_inspection_scheduled_date);
CREATE INDEX if not exists pd_in_house_mpu_materials_ordered_date_idx ON brs.project_details (in_house_mpu_materials_ordered_date);
CREATE INDEX if not exists pd_in_house_mpu_permit_approved_date_idx ON brs.project_details (in_house_mpu_permit_approved_date);
CREATE INDEX if not exists pd_in_house_mpu_permit_pack_complete_date_idx ON brs.project_details (in_house_mpu_permit_pack_complete_date);
CREATE INDEX if not exists pd_in_house_mpu_permit_submittal_end_date_idx ON brs.project_details (in_house_mpu_permit_submittal_end_date);
CREATE INDEX if not exists pd_in_house_mpu_permit_submittal_start_date_idx ON brs.project_details (in_house_mpu_permit_submittal_start_date);
CREATE INDEX if not exists pd_in_house_mpu_permit_submittal_verified_date_idx ON brs.project_details (in_house_mpu_permit_submittal_verified_date);
CREATE INDEX if not exists pd_in_house_mpu_resource_idx ON brs.project_details (in_house_mpu_resource);
CREATE INDEX if not exists pd_installation_closeout_end_time_idx ON brs.project_details (installation_closeout_end_time);
CREATE INDEX if not exists pd_installation_closeout_start_time_idx ON brs.project_details (installation_closeout_start_time);
CREATE INDEX if not exists pd_installation_start_time_idx ON brs.project_details (installation_start_time);
CREATE INDEX if not exists pd_installation_end_time_idx ON brs.project_details (installation_end_time);
CREATE INDEX if not exists pd_installation_ready_to_schedule_date_idx ON brs.project_details (installation_ready_to_schedule_date);
CREATE INDEX if not exists pd_installation_resource_idx ON brs.project_details (installation_resource);
CREATE INDEX if not exists pd_interconnection_application_approved_date_idx ON brs.project_details (interconnection_application_approved_date);
CREATE INDEX if not exists pd_interconnection_application_signed_date_idx ON brs.project_details (interconnection_application_signed_date);
CREATE INDEX if not exists pd_interconnection_application_submitted_to_utility_date_idx ON brs.project_details (interconnection_application_submitted_to_utility_date);
CREATE INDEX if not exists pd_interest_rate_idx ON brs.project_details (interest_rate);
CREATE INDEX if not exists pd_introduction_call_idx ON brs.project_details (introduction_call);
CREATE INDEX if not exists pd_inverter_brand_idx ON brs.project_details (inverter_brand);
CREATE INDEX if not exists pd_lead_source_idx ON brs.project_details (lead_source);
CREATE INDEX if not exists pd_lead_source_detail_idx ON brs.project_details (lead_source_detail);
CREATE INDEX if not exists pd_loan_amount_idx ON brs.project_details (loan_amount);
CREATE INDEX if not exists pd_loan_term_idx ON brs.project_details (loan_term);
CREATE INDEX if not exists pd_materials_ordered_date_idx ON brs.project_details (materials_ordered_date);
CREATE INDEX if not exists pd_low_production_inquiry_requested_date_idx ON brs.project_details (low_production_inquiry_requested_date);
CREATE INDEX if not exists pd_low_production_inquiry_resolved_date_idx ON brs.project_details (low_production_inquiry_resolved_date);
CREATE INDEX if not exists pd_low_production_inquiry_reviewed_date_idx ON brs.project_details (low_production_inquiry_reviewed_date);
CREATE INDEX if not exists pd_non_standard_installation_work_end_time_idx ON brs.project_details (non_standard_installation_work_end_time);
CREATE INDEX if not exists pd_non_standard_installation_work_start_time_idx ON brs.project_details (non_standard_installation_work_start_time);
CREATE INDEX if not exists pd_non_standard_installation_resource_idx ON brs.project_details (non_standard_installation_resource);
CREATE INDEX if not exists pd_non_standard_installation_work_verified_date_idx ON brs.project_details (non_standard_installation_work_verified_date);
CREATE INDEX if not exists pd_panel_brand_idx ON brs.project_details (panel_brand);
CREATE INDEX if not exists pd_panel_quantity_idx ON brs.project_details (panel_quantity);
CREATE INDEX if not exists pd_panel_watts_idx ON brs.project_details (panel_watts);
CREATE INDEX if not exists pd_permit_approved_date_idx ON brs.project_details (permit_approved_date);
CREATE INDEX if not exists pd_permit_pack_submittal_end_time_idx ON brs.project_details (permit_pack_submittal_end_time);
CREATE INDEX if not exists pd_permit_pack_submittal_start_time_idx ON brs.project_details (permit_pack_submittal_start_time);
CREATE INDEX if not exists pd_permit_pack_submittal_verified_date_idx ON brs.project_details (permit_pack_submittal_verified_date);
CREATE INDEX if not exists pd_permit_pickup_end_time_idx ON brs.project_details (permit_pickup_end_time);
CREATE INDEX if not exists pd_permit_pickup_start_time_idx ON brs.project_details (permit_pickup_start_time);
CREATE INDEX if not exists pd_permit_pickup_verified_date_idx ON brs.project_details (permit_pickup_verified_date);
CREATE INDEX if not exists pd_plan_set_created_date_idx ON brs.project_details (plan_set_created_date);
CREATE INDEX if not exists pd_plan_set_qa_date_idx ON brs.project_details (plan_set_qa_date);
CREATE INDEX if not exists pd_referral_promotion_amount_idx ON brs.project_details (referral_promotion_amount);
CREATE INDEX if not exists pd_secondary_financier_idx ON brs.project_details (secondary_financier);
CREATE INDEX if not exists pd_second_cash_payment_amount_idx ON brs.project_details (second_cash_payment_amount);
CREATE INDEX if not exists pd_second_cash_payment_invoiced_date_idx ON brs.project_details (second_cash_payment_invoiced_date);
CREATE INDEX if not exists pd_second_cash_payment_paid_date_idx ON brs.project_details (second_cash_payment_paid_date);
CREATE INDEX if not exists pd_site_survey_end_time_idx ON brs.project_details (site_survey_end_time);
CREATE INDEX if not exists pd_site_survey_start_time_idx ON brs.project_details (site_survey_start_time);
CREATE INDEX if not exists pd_site_survey_type_idx ON brs.project_details (site_survey_type);
CREATE INDEX if not exists pd_site_survey_uploaded_date_idx ON brs.project_details (site_survey_uploaded_date);
CREATE INDEX if not exists pd_structural_analysis_required_date_idx ON brs.project_details (structural_analysis_required_date);
CREATE INDEX if not exists pd_structural_analysis_complete_date_idx ON brs.project_details (structural_analysis_complete_date);
CREATE INDEX if not exists pd_structural_engineering_review_complete_date_idx ON brs.project_details (structural_engineering_review_complete_date);
CREATE INDEX if not exists pd_structural_engineering_review_required_date_idx ON brs.project_details (structural_engineering_review_required_date);
CREATE INDEX if not exists pd_structural_engineering_stamp_received_date_idx ON brs.project_details (structural_engineering_stamp_received_date);
CREATE INDEX if not exists pd_structural_engineering_stamp_requested_date_idx ON brs.project_details (structural_engineering_stamp_requested_date);
CREATE INDEX if not exists pd_structural_post_install_engineering_letter_complete_date_idx ON brs.project_details (structural_post_install_engineering_letter_complete_date);
CREATE INDEX if not exists pd_substantial_completion_approved_date_idx ON brs.project_details (substantial_completion_approved_date);
CREATE INDEX if not exists pd_total_ancillary_cost_with_fees_idx ON brs.project_details (total_ancillary_cost_with_fees);
CREATE INDEX if not exists pd_total_cash_down_payment_idx ON brs.project_details (total_cash_down_payment);
CREATE INDEX if not exists pd_utility_meter_ordered_date_idx ON brs.project_details (utility_meter_ordered_date);
CREATE INDEX if not exists pd_utility_meter_set_date_idx ON brs.project_details (utility_meter_set_date);
CREATE INDEX if not exists pd_utility_rebate_application_approved_date_idx ON brs.project_details (utility_rebate_application_approved_date);
CREATE INDEX if not exists pd_utility_rebate_application_sent_to_homeowner_date_idx ON brs.project_details (utility_rebate_application_sent_to_homeowner_date);
CREATE INDEX if not exists pd_utility_rebate_application_signed_date_idx ON brs.project_details (utility_rebate_application_signed_date);
CREATE INDEX if not exists pd_work_order_end_time_idx ON brs.project_details (work_order_end_time);
CREATE INDEX if not exists pd_work_order_resource_idx ON brs.project_details (work_order_resource);
CREATE INDEX if not exists pd_work_order_start_time_idx ON brs.project_details (work_order_start_time);
CREATE INDEX if not exists pd_work_order_verified_date_idx ON brs.project_details (work_order_verified_date);
CREATE INDEX if not exists pd_verified_setter_lead_idx ON brs.project_details (verified_setter_lead);
CREATE INDEX if not exists pd_verified_usage_idx ON brs.project_details (verified_usage);
CREATE INDEX if not exists pd_ahj_idx ON brs.project_details (ahj);
CREATE INDEX if not exists pd_utility_company_idx ON brs.project_details (utility_company);
CREATE INDEX if not exists pd_installation_agreement_sent_to_homeowner_idx ON brs.project_details (installation_agreement_sent_to_homeowner);


create unique index project_process_step_pk
    on flow.project_process_step (id,process_step_id);

create index project_process_step1_pk
    on flow.project_process_step (id);


create unique index on flow.project_process_step (project_id,process_step_id)
    where main = true;

create index project_process_step_main_idx on flow.project_process_step (main);

create index if not exists p_postal_code4_idx
    on flow.project (postal_code);

