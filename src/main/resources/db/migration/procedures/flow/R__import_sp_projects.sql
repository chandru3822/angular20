drop function if exists flow.import_sp_projects(p_record jsonb, p_file_name text);
CREATE OR REPLACE FUNCTION flow.import_sp_projects(p_record jsonb, p_file_name text)
  RETURNS table
          (
            flow_project_id   bigint,
            sp_project_id     text,
            created_timestamp timestamp,
            error_status      text,
            pps_id            bigint
          )
  LANGUAGE plpgsql
AS
$$
DECLARE
  v_project_id                                       bigint;
  v_contact_id                                       bigint;
  v_sp_project_id                                    text;
  v_current_milestone                                text;
  v_current_milestone_id                             bigint;
  v_current_critical_path_task_name                  text;
  v_current_critical_path_task_name_id               bigint;
  v_utility                                          text;
  v_email                                            text;
  v_first_name                                       text;
  v_last_name                                        text;
  v_phone                                            text;
  v_postal_code                                      text;
  v_state                                            text;
  v_street_1                                         text;
  v_street_2                                         text;
  v_total_yearly_usage_pre_solar                     text;
  v_inverter                                         text;
  v_inverter_id                                      bigint;
  v_panel_brand                                      text;
  v_panel_brand_id                                   bigint;
  v_panel_part_number                                text;
  v_panel_wattage                                    text;
  v_panel_quantity                                   text;
  v_system_size                                      text;
  v_year_1_kwh_output                                text;
  v_storage_brand                                    text;
  v_storage_brand_id                                 bigint;
  v_number_of_batteries                              text;
  v_storage_size_kwh                                 text;
  v_installation_agreement_signed_date               text;
  v_hoa_approval_required                            text;
  v_hoa_approval_required_id                         bigint;
  v_original_credit_expiration_date                  text;
  v_ahj                                              text;
  v_permit_submission_method_online_in_person        text;
  v_permit_submission_method_online_in_person_id     bigint;
  v_permit_submitted_date                            text;
  v_permit_fee                                       text;
  v_permit_approved                                  text;
  v_utility_account_number                           text;
  v_meter_number                                     text;
  v_interconnection_application_submitted_to_utility text;
  v_Site_Survey_PhotoCircle_Link                     text;
  v_mpu_required                                     text;
  v_mpu_required_id                                  bigint;
  v_reroof_required                                  text;
  v_reroof_required_id                               bigint;
  v_trenching_required                               text;
  v_trenching_required_id                            bigint;
  v_structural_upgrades                              text;
  v_structural_upgrades_id                           bigint;
  v_battery_topic                                    text;
  v_change_order_topic                               text;
  v_design_rework_topic                              text;
  v_electrical_review_topic                          text;
  v_final_design_topic                               text;
  v_financing_topic                                  text;
  v_hic_topic                                        text;
  v_hoa_topic                                        text;
  v_installation_topic                               text;
  v_interconnection_topic                            text;
  v_intro_call_topic                                 text;
  v_mpu_topic                                        text;
  v_permit_pack_topic                                text;
  v_permit_rework_topic                              text;
  v_permitting_topic                                 text;
  v_proposals_topic                                  text;
  v_rebate_topic                                     text;
  v_reroof_topic                                     text;
  v_resurvey_topic                                   text;
  v_site_survey_topic                                text;
  v_structural_review_topic                          text;
  v_trenching_topic                                  text;
  v_tree_trimming_or_removal_topic                   text;
  v_utility_bill_verification_topic                  text;
  v_other_topic                                      text;
  v_hic_filename                                     text;
  v_hic_displayname                                  text;
  v_hic_content_type                                 text;
  v_hic_s3_key                                       text;
  v_hic_size                                         text;
  v_hic_attachment_type_id                           bigint default 41;
  v_hic_attachment_id                                bigint;
  v_proposal_document_filename                       text;
  v_proposal_document_displayname                    text;
  v_proposal_document_content_type                   text;
  v_proposal_document_s3_key                         text;
  v_proposal_document_size                           text;
  v_proposal_document_attachment_type_id             bigint default 37;
  v_proposal_document_attachment_id                  bigint;
  v_utility_bill_document_filename                   text;
  v_utility_bill_document_displayname                text;
  v_utility_bill_document_content_type               text;
  v_utility_bill_document_s3_key                     text;
  v_utility_bill_document_size                       text;
  v_utility_bill_document_attachment_type_id         bigint default 47;
  v_utility_bill_document_attachment_id              bigint;
  v_site_survey_photos_filename                      text;
  v_site_survey_photos_displayname                   text;
  v_site_survey_photos_content_type                  text;
  v_site_survey_photos_s3_key                        text;
  v_site_survey_photos_size                          text;
  v_site_survey_photos_attachment_type_id            bigint default 36;
  v_site_survey_photos_attachment_id                 bigint;
  v_final_design_filename                            text;
  v_final_design_displayname                         text;
  v_final_design_content_type                        text;
  v_final_design_s3_key                              text;
  v_final_design_size                                text;
  v_final_design_attachment_type_id                  bigint default 38;
  v_final_design_attachment_id                       bigint;
  v_permit_pack_filename                             text;
  v_permit_pack_displayname                          text;
  v_permit_pack_content_type                         text;
  v_permit_pack_s3_key                               text;
  v_permit_pack_size                                 text;
  v_permit_pack_attachment_type_id                   bigint default 40;
  v_permit_pack_attachment_id                        bigint;
  v_shade_report_filename                            text;
  v_shade_report_displayname                         text;
  v_shade_report_content_type                        text;
  v_shade_report_s3_key                              text;
  v_shade_report_size                                text;
  v_shade_report_attachment_type_id                  bigint default 465;
  v_shade_report_attachment_id                       bigint;
  v_approved_permit_pack_filename                    text;
  v_approved_permit_pack_displayname                 text;
  v_approved_permit_pack_content_type                text;
  v_approved_permit_pack_s3_key                      text;
  v_approved_permit_pack_size                        text;
  v_approved_permit_pack_attachment_type_id          bigint default 950;
  v_approved_permit_pack_attachment_id               bigint;
  v_chatter_file_filename                            text;
  v_chatter_file_displayname                         text;
  v_chatter_file_content_type                        text;
  v_chatter_file_s3_key                              text;
  v_chatter_file_size                                text;
  v_chatter_file_attachment_type_id                  bigint default 994;
  v_chatter_file_attachment_id                       bigint;
  v_company_state_id                                 bigint;
  v_error_message                                    text;
  v_project_activity_id                              bigint;
  v_pps_id                                           bigint;
  v_existing_project_id                              bigint;

BEGIN
  select p_record ->> 'Project_ID',
         p_record ->> 'current_milestone',
         p_record ->> 'current_critical_path_task_name',
         p_record ->> 'utility',
         p_record ->> 'email',
         p_record ->> 'first_name',
         p_record ->> 'last_name',
         p_record ->> 'phone',
         p_record ->> 'postal_code',
         p_record ->> 'state',
         p_record ->> 'street_1',
         p_record ->> 'street_2',
         p_record ->> 'total_yearly_usage_pre_solar',
         p_record ->> 'inverter',
         p_record ->> 'panel_brand',
         p_record ->> 'panel_part_number',
         p_record ->> 'panel_wattage',
         p_record ->> 'panel_quantity',
         p_record ->> 'system_size',
         p_record ->> 'year_1_kwh_output',
         p_record ->> 'storage_brand',
         p_record ->> 'number_of_batteries',
         p_record ->> 'storage_size_kwh',
         p_record ->> 'installation_agreement_signed_date',
         p_record ->> 'HOA_Approval_Required',
         p_record ->> 'Original_Credit_Expiration_Date',
         p_record ->> 'AHJ',
         p_record ->> 'Permit_Submission_Method_online_in_person',
         p_record ->> 'Permit_Submitted_Date',
         p_record ->> 'Permit_Fee',
         p_record ->> 'Permit_Approved',
         p_record ->> 'utility_account_number',
         p_record ->> 'meter_number',
         p_record ->> 'Interconnection_Application_Submitted_to_Utility',
         p_record ->> 'Site_Survey_PhotoCircle_Link',
         p_record ->> 'MPU_required',
         p_record ->> 'Reroof_required',
         p_record ->> 'Trenching_required',
         p_record ->> 'Structural_upgrades',
         p_record ->> 'Battery_Topic',
         p_record ->> 'Change_Order_Topic',
         p_record ->> 'Design_Rework_topic',
         p_record ->> 'Electrical_Review_Topic',
         p_record ->> 'Final_Design_Topic',
         p_record ->> 'Financing_Topic',
         p_record ->> 'HIC_Topic',
         p_record ->> 'HOA_Topic',
         p_record ->> 'Installation_Topic',
         p_record ->> 'Interconnection_Topic',
         p_record ->> 'Intro_call_Topic',
         p_record ->> 'MPU_Topic',
         p_record ->> 'Permit_Pack_Topic',
         p_record ->> 'Permit_Rework_Topic',
         p_record ->> 'Permitting_Topic',
         p_record ->> 'Proposals_Topic',
         p_record ->> 'Rebate_Topic',
         p_record ->> 'Reroof_Topic',
         p_record ->> 'Resurvey_Topic',
         p_record ->> 'Site_Survey_Topic',
         p_record ->> 'Structural_Review_Topic',
         p_record ->> 'Trenching_Topic',
         p_record ->> 'Tree_Trimming_Or_Removal_Topic',
         p_record ->> 'Utility_Bill_Verification_Topic',
         p_record ->> 'Other_Topic',
         p_record -> 'Signed_HIC_Document' ->> 'filename',
         p_record -> 'Signed_HIC_Document' ->> 'displayName',
         p_record -> 'Signed_HIC_Document' ->> 'contentType',
         p_record -> 'Signed_HIC_Document' ->> 's3Key',
         p_record -> 'Signed_HIC_Document' ->> 'size',
         p_record -> 'Proposal_Document' ->> 'filename',
         p_record -> 'Proposal_Document' ->> 'displayName',
         p_record -> 'Proposal_Document' ->> 'contentType',
         p_record -> 'Proposal_Document' ->> 's3Key',
         p_record -> 'Proposal_Document' ->> 'size',
         p_record -> 'Utility_Bill_Document' ->> 'filename',
         p_record -> 'Utility_Bill_Document' ->> 'displayName',
         p_record -> 'Utility_Bill_Document' ->> 'contentType',
         p_record -> 'Utility_Bill_Document' ->> 's3Key',
         p_record -> 'Utility_Bill_Document' ->> 'size',
         p_record -> 'Site_Survey_Photos' ->> 'filename',
         p_record -> 'Site_Survey_Photos' ->> 'displayName',
         p_record -> 'Site_Survey_Photos' ->> 'contentType',
         p_record -> 'Site_Survey_Photos' ->> 's3Key',
         p_record -> 'Site_Survey_Photos' ->> 'size',
         p_record -> 'Final_Design' ->> 'filename',
         p_record -> 'Final_Design' ->> 'displayName',
         p_record -> 'Final_Design' ->> 'contentType',
         p_record -> 'Final_Design' ->> 's3Key',
         p_record -> 'Final_Design' ->> 'size',
         p_record -> 'Permit_Pack' ->> 'filename',
         p_record -> 'Permit_Pack' ->> 'displayName',
         p_record -> 'Permit_Pack' ->> 'contentType',
         p_record -> 'Permit_Pack' ->> 's3Key',
         p_record -> 'Permit_Pack' ->> 'size',
         p_record -> 'Shade_Report' ->> 'filename',
         p_record -> 'Shade_Report' ->> 'displayName',
         p_record -> 'Shade_Report' ->> 'contentType',
         p_record -> 'Shade_Report' ->> 's3Key',
         p_record -> 'Shade_Report' ->> 'size',
         p_record -> 'Approved_Permit_Pack' ->> 'filename',
         p_record -> 'Approved_Permit_Pack' ->> 'displayName',
         p_record -> 'Approved_Permit_Pack' ->> 'contentType',
         p_record -> 'Approved_Permit_Pack' ->> 's3Key',
         p_record -> 'Approved_Permit_Pack' ->> 'size',
         p_record -> 'Chatter_File' ->> 'filename',
         p_record -> 'Chatter_File' ->> 'displayName',
         p_record -> 'Chatter_File' ->> 'contentType',
         p_record -> 'Chatter_File' ->> 's3Key',
         p_record -> 'Chatter_File' ->> 'size'
  into
    v_sp_project_id,
    v_current_milestone,
    v_current_critical_path_task_name,
    v_utility,
    v_email,
    v_first_name,
    v_last_name,
    v_phone,
    v_postal_code,
    v_state,
    v_street_1,
    v_street_2,
    v_total_yearly_usage_pre_solar,
    v_inverter,
    v_panel_brand,
    v_panel_part_number,
    v_panel_wattage,
    v_panel_quantity,
    v_system_size,
    v_year_1_kwh_output,
    v_storage_brand,
    v_number_of_batteries,
    v_storage_size_kwh,
    v_installation_agreement_signed_date,
    v_hoa_approval_required,
    v_original_credit_expiration_date,
    v_ahj,
    v_permit_submission_method_online_in_person,
    v_permit_submitted_date,
    v_permit_fee,
    v_permit_approved,
    v_utility_account_number,
    v_meter_number,
    v_interconnection_application_submitted_to_utility,
    v_Site_Survey_PhotoCircle_Link,
    v_mpu_required,
    v_reroof_required,
    v_trenching_required,
    v_structural_upgrades,
    v_battery_topic,
    v_change_order_topic,
    v_design_rework_topic,
    v_electrical_review_topic,
    v_final_design_topic,
    v_financing_topic,
    v_hic_topic,
    v_hoa_topic,
    v_installation_topic,
    v_interconnection_topic,
    v_intro_call_topic,
    v_mpu_topic,
    v_permit_pack_topic,
    v_permit_rework_topic,
    v_permitting_topic,
    v_proposals_topic,
    v_rebate_topic,
    v_reroof_topic,
    v_resurvey_topic,
    v_site_survey_topic,
    v_structural_review_topic,
    v_trenching_topic,
    v_tree_trimming_or_removal_topic,
    v_utility_bill_verification_topic,
    v_other_topic,
    v_hic_filename,
    v_hic_displayname,
    v_hic_content_type,
    v_hic_s3_key,
    v_hic_size,
    v_proposal_document_filename,
    v_proposal_document_displayname,
    v_proposal_document_content_type,
    v_proposal_document_s3_key,
    v_proposal_document_size,
    v_utility_bill_document_filename,
    v_utility_bill_document_displayname,
    v_utility_bill_document_content_type,
    v_utility_bill_document_s3_key,
    v_utility_bill_document_size,
    v_site_survey_photos_filename,
    v_site_survey_photos_displayname,
    v_site_survey_photos_content_type,
    v_site_survey_photos_s3_key,
    v_site_survey_photos_size,
    v_final_design_filename,
    v_final_design_displayname,
    v_final_design_content_type,
    v_final_design_s3_key,
    v_final_design_size,
    v_permit_pack_filename,
    v_permit_pack_displayname,
    v_permit_pack_content_type,
    v_permit_pack_s3_key,
    v_permit_pack_size,
    v_shade_report_filename,
    v_shade_report_displayname,
    v_shade_report_content_type,
    v_shade_report_s3_key,
    v_shade_report_size,
    v_approved_permit_pack_filename,
    v_approved_permit_pack_displayname,
    v_approved_permit_pack_content_type,
    v_approved_permit_pack_s3_key,
    v_approved_permit_pack_size,
    v_chatter_file_filename,
    v_chatter_file_displayname,
    v_chatter_file_content_type,
    v_chatter_file_s3_key,
    v_chatter_file_size;

  select count(1)
  into v_existing_project_id
  from flow.import_sp_project isp
  where isp.sp_project_id = v_sp_project_id;

  if v_existing_project_id < 1 then
    begin
      select cs.id
      into v_company_state_id
      from flow.company_state cs
             inner join flow.state s on s.id = cs.state_id
      where cs.company_id = 3
        and s.abbreviation = v_state;


      insert into flow.contact (contact_type_id, first_name, last_name, street1, street2, postal_code, phone, email,
                                date_created, date_modified, created_by_id, modified_by_id,
                                company_id, archived, owner_user_position_id, company_state_id)
      values (1, v_first_name, v_last_name, v_street_1, v_street_2, v_postal_code, v_phone, v_email,
              now(), now(), 2384850, 2384850, 3, false, 105806, v_company_state_id)
      returning id into v_contact_id;

      perform flow.set_contact_cfv(v_contact_id, 2384850, 395, 24629::text);
      perform flow.set_contact_cfv(v_contact_id, 2384850, 396, 24630::text);

      insert into flow.project (contact_id, company_process_id, project_name, date_created, date_modified,
                                created_by_id, modified_by_id, company_project_status_type_id, user_position_id,
                                street1, street2, postal_code, company_state_id, company_country_id, archived)
        (select v_contact_id,
                1,
                concat(v_first_name, ' ', v_last_name),
                now(),
                now(),
                2384850,
                2384850,
                69,
                105806,
                v_street_1,
                v_street_2,
                v_postal_code,
                v_company_state_id,
                1,
                false)
      returning id into v_project_id;

      insert into flow.project_process_step(project_id, process_step_id, company_process_step_status_type_id,
                                            date_created, date_modified, created_by_id, modified_by_id,
                                            archived, main)
      values (v_project_id, 3695, 1, now(), now(), 2384850, 2384850, false, true)
      returning id into v_pps_id;


      perform flow.set_pps_cfv(v_project_id, 2384850, 27055, v_sp_project_id::text); --v_sp_project_id
      if v_current_milestone is not null and v_current_milestone != '' then
        select lov.id
        into v_current_milestone_id
        from flow.list_of_value lov
        where parent_id = 24419
          and lower(lov.name) = lower(v_current_milestone);
        if v_current_milestone_id is not null then
          perform flow.set_pps_cfv(v_project_id, 2384850, 27056, v_current_milestone_id::text); --v_current_milestone
        end if;
      end if;

      if v_current_critical_path_task_name is not null and v_current_critical_path_task_name != '' then
        select lov.id
        into v_current_critical_path_task_name_id
        from flow.list_of_value lov
        where parent_id = 24455
          and lower(lov.name) = lower(v_current_critical_path_task_name);

        if v_current_critical_path_task_name_id is not null then
          perform flow.set_pps_cfv(v_project_id, 2384850, 27112,
                                   '{' || v_current_critical_path_task_name_id::text ||
                                   '}'); --v_current_critical_path_task_name
        end if;
      end if;

      if v_utility is not null and v_utility != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27058, v_utility::text); --v_utility
      end if;

      if v_total_yearly_usage_pre_solar is not null and v_total_yearly_usage_pre_solar != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27075,
                                 round(v_total_yearly_usage_pre_solar::numeric)::text); --v_total_yearly_usage_pre_solar
      end if;

      if v_inverter is not null and v_inverter != '' then

        if v_inverter = 'ENPHASE IQ7HS MICROINVERTER' then
          v_inverter_id = 22929;
        elsif v_inverter = 'ENPHASE IQ7XS MICROINVERTER' then
          v_inverter_id = 23299;
        end if;
        if v_inverter_id is not null then
          perform flow.set_pps_cfv(v_project_id, 2384850, 27076, v_inverter_id::text); --v_inverter
        end if;
      end if;

      if v_panel_brand is not null and v_panel_brand != '' then

        if v_panel_brand = 'Waaree Energies Ltd.' then
          v_panel_brand_id = 24438;
        elsif v_panel_brand = 'SunPower' then
          v_panel_brand_id = 20062;
        elsif v_panel_brand = 'Hanwha Q-Cells' then
          v_panel_brand_id = 242;
        end if;
        if v_panel_brand_id is not null then
          perform flow.set_pps_cfv(v_project_id, 2384850, 27077, v_panel_brand_id::text); --v_panel_brand
        end if;
      end if;

      if v_panel_part_number is not null and v_panel_part_number != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27078, v_panel_part_number::text); --v_panel_part_number
      end if;

      if v_panel_wattage is not null and v_panel_wattage != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27079, v_panel_wattage::text); --v_panel_wattage
      end if;

      if v_panel_quantity is not null and v_panel_quantity != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27080, v_panel_quantity::text); --v_panel_quantity
      end if;

      if v_system_size is not null and v_system_size != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27081, v_system_size::text); --v_system_size
      end if;

      if v_year_1_kwh_output is not null and v_year_1_kwh_output != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27082,
                                 round(v_year_1_kwh_output::numeric)::text); --v_year_1_kwh_output
      end if;

      if v_storage_brand is not null and v_storage_brand != '' then
        if v_storage_brand = 'SunPower' then
          v_storage_brand_id = 20090;
        elsif v_storage_brand = 'Enphase' then
          v_storage_brand_id = 19408;
        elsif v_storage_brand = 'Tesla' then
          v_storage_brand_id = 23856;
        end if;
        if v_storage_brand_id is not null then
          perform flow.set_pps_cfv(v_project_id, 2384850, 27083, v_storage_brand_id::text); --v_storage_brand
        end if;
      end if;

      if v_number_of_batteries is not null and v_number_of_batteries != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27084, v_number_of_batteries::text); --v_number_of_batteries
      end if;

      if v_storage_size_kwh is not null and v_storage_size_kwh != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27085, v_storage_size_kwh::text); --v_storage_size_kwh
      end if;

      if v_installation_agreement_signed_date is not null and v_installation_agreement_signed_date != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27059,
                                 v_installation_agreement_signed_date::text); --v_installation_agreement_signed_date
      end if;

      if v_hoa_approval_required is not null and v_hoa_approval_required != '' then
        select lov.id
        into v_hoa_approval_required_id
        from flow.list_of_value lov
        where parent_id = 124
          and lower(lov.name) = lower(v_hoa_approval_required);

        if v_hoa_approval_required_id is not null then
          perform flow.set_pps_cfv(v_project_id, 2384850, 27060,
                                   v_hoa_approval_required_id::text); --v_hoa_approval_required
        end if;
      end if;

      if v_original_credit_expiration_date is not null and v_original_credit_expiration_date != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27061,
                                 v_original_credit_expiration_date::text); --v_original_credit_expiration_date
      end if;

      if v_ahj is not null and v_ahj != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27062, v_ahj::text); --v_ahj
      end if;

      if v_permit_submission_method_online_in_person is not null and
         v_permit_submission_method_online_in_person != '' then
        select lov.id
        into v_permit_submission_method_online_in_person_id
        from flow.list_of_value lov
        where parent_id = 24425
          and lower(lov.name) = lower(v_permit_submission_method_online_in_person);

        if v_permit_submission_method_online_in_person_id is not null then
          perform flow.set_pps_cfv(v_project_id, 2384850, 27063,
                                   v_permit_submission_method_online_in_person_id::text); --v_permit_submission_method_online_in_person
        end if;
      end if;

      if v_permit_submitted_date is not null and v_permit_submitted_date != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27064, v_permit_submitted_date::text); --v_permit_submitted_date
      end if;

      if v_permit_fee is not null and v_permit_fee != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27065, v_permit_fee::text); --v_permit_fee
      end if;

      if v_permit_approved is not null and v_permit_approved != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27066, v_permit_approved::text); --v_permit_approved
      end if;

      if v_utility_account_number is not null and v_utility_account_number != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27067,
                                 v_utility_account_number::text); --v_utility_account_number
      end if;

      if v_meter_number is not null and v_meter_number != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27068, v_meter_number::text); --v_meter_number
      end if;

      if v_interconnection_application_submitted_to_utility is not null and
         v_interconnection_application_submitted_to_utility != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27069,
                                 v_interconnection_application_submitted_to_utility::text); --v_interconnection_application_submitted_to_utility
      end if;

      if v_Site_Survey_PhotoCircle_Link is not null and
         v_Site_Survey_PhotoCircle_Link != '' then
        perform flow.set_pps_cfv(v_project_id, 2384850, 27102,
                                 v_Site_Survey_PhotoCircle_Link::text); --v_Site_Survey_PhotoCircle_Link
      end if;

      if v_mpu_required is not null and v_mpu_required != '' then
        select lov.id
        into v_mpu_required_id
        from flow.list_of_value lov
        where parent_id = 19189
          and lower(lov.name) = lower(v_mpu_required);

        if v_mpu_required_id is not null then
          perform flow.set_pps_cfv(v_project_id, 2384850, 27070, v_mpu_required_id::text); --v_mpu_required
        end if;
      end if;

      if v_reroof_required is not null and v_reroof_required != '' then
        select lov.id
        into v_reroof_required_id
        from flow.list_of_value lov
        where parent_id = 882
          and lower(lov.name) = lower(v_reroof_required);
        if v_reroof_required_id is not null then
          perform flow.set_pps_cfv(v_project_id, 2384850, 27071, v_reroof_required_id::text); --v_reroof_required
        end if;
      end if;

      if v_trenching_required is not null and v_trenching_required != '' then
        select lov.id
        into v_trenching_required_id
        from flow.list_of_value lov
        where parent_id = 885
          and lower(lov.name) = lower(v_trenching_required);
        if v_trenching_required_id is not null then
          perform flow.set_pps_cfv(v_project_id, 2384850, 27072, v_trenching_required_id::text); --v_trenching_required
        end if;
      end if;

      if v_structural_upgrades is not null and v_structural_upgrades != '' then
        select lov.id
        into v_structural_upgrades_id
        from flow.list_of_value lov
        where parent_id = 879
          and lower(lov.name) = lower(v_structural_upgrades);
        if v_structural_upgrades_id is not null then
          perform flow.set_pps_cfv(v_project_id, 2384850, 27073,
                                   v_structural_upgrades_id::text); --v_structural_upgrades
        end if;
      end if;

      if v_hic_filename is not null and v_hic_filename != '' then
        insert into flow.attachment(attachment_type_id, company_id, filename, content_type, s3_key, size, archived,
                                    date_created, date_modified, created_by_id, modified_by_id, show, uuid,
                                    display_name)
        values (v_hic_attachment_type_id, 3, v_hic_filename, v_hic_content_type, v_hic_s3_key, v_hic_size::integer,
                false, now(),
                now(), 2384850, 2384850, false, uuid_generate_v4(), v_hic_displayname)
        returning id into v_hic_attachment_id;

        insert into flow.project_attachment(attachment_id, project_id, date_created, date_modified, created_by_id,
                                            modified_by_id, linked, archived)
        values (v_hic_attachment_id, v_project_id, now(), now(), 2384850, 2384850, false, false);

      end if;

      if v_proposal_document_filename is not null and v_proposal_document_filename != '' then

        insert into flow.attachment(attachment_type_id, company_id, filename, content_type, s3_key, size, archived,
                                    date_created, date_modified, created_by_id, modified_by_id, show, uuid,
                                    display_name)
        values (v_proposal_document_attachment_type_id, 3, v_proposal_document_filename,
                v_proposal_document_content_type,
                v_proposal_document_s3_key, v_proposal_document_size::integer, false, now(), now(), 2384850, 2384850,
                false,
                uuid_generate_v4(),
                v_proposal_document_displayname)
        returning id into v_proposal_document_attachment_id;

        insert into flow.project_attachment(attachment_id, project_id, date_created, date_modified, created_by_id,
                                            modified_by_id, linked, archived)
        values (v_proposal_document_attachment_id, v_project_id, now(), now(), 2384850, 2384850, false, false);

      end if;

      if v_utility_bill_document_filename is not null and v_utility_bill_document_filename != '' then

        insert into flow.attachment(attachment_type_id, company_id, filename, content_type, s3_key, size, archived,
                                    date_created, date_modified, created_by_id, modified_by_id, show, uuid,
                                    display_name)
        values (v_utility_bill_document_attachment_type_id, 3, v_utility_bill_document_filename,
                v_utility_bill_document_content_type, v_utility_bill_document_s3_key,
                v_utility_bill_document_size::integer, false,
                now(), now(), 2384850, 2384850, false, uuid_generate_v4(),
                v_utility_bill_document_displayname)
        returning id into v_utility_bill_document_attachment_id;

        insert into flow.project_attachment(attachment_id, project_id, date_created, date_modified, created_by_id,
                                            modified_by_id, linked, archived)
        values (v_utility_bill_document_attachment_id, v_project_id, now(), now(), 2384850, 2384850, false, false);

      end if;

      if v_site_survey_photos_filename is not null and v_site_survey_photos_filename != '' then
        insert into flow.attachment(attachment_type_id, company_id, filename, content_type, s3_key, size, archived,
                                    date_created, date_modified, created_by_id, modified_by_id, show, uuid,
                                    display_name)
        values (v_site_survey_photos_attachment_type_id, 3, v_site_survey_photos_filename,
                v_site_survey_photos_content_type,
                v_site_survey_photos_s3_key, v_site_survey_photos_size::integer, false, now(), now(), 2384850, 2384850,
                false,
                uuid_generate_v4(),
                v_site_survey_photos_displayname)
        returning id into v_site_survey_photos_attachment_id;

        insert into flow.project_attachment(attachment_id, project_id, date_created, date_modified, created_by_id,
                                            modified_by_id, linked, archived)
        values (v_site_survey_photos_attachment_id, v_project_id, now(), now(), 2384850, 2384850, false, false);
      end if;


      if v_final_design_filename is not null and v_final_design_filename != '' then

        insert into flow.attachment(attachment_type_id, company_id, filename, content_type, s3_key, size, archived,
                                    date_created, date_modified, created_by_id, modified_by_id, show, uuid,
                                    display_name)
        values (v_final_design_attachment_type_id, 3, v_final_design_filename, v_final_design_content_type,
                v_final_design_s3_key, v_final_design_size::integer, false, now(), now(), 2384850, 2384850, false,
                uuid_generate_v4(),
                v_final_design_displayname)
        returning id into v_final_design_attachment_id;

        insert into flow.project_attachment(attachment_id, project_id, date_created, date_modified, created_by_id,
                                            modified_by_id, linked, archived)
        values (v_final_design_attachment_id, v_project_id, now(), now(), 2384850, 2384850, false, false);
      end if;


      if v_permit_pack_filename is not null and v_permit_pack_filename != '' then

        insert into flow.attachment(attachment_type_id, company_id, filename, content_type, s3_key, size, archived,
                                    date_created, date_modified, created_by_id, modified_by_id, show, uuid,
                                    display_name)
        values (v_permit_pack_attachment_type_id, 3, v_permit_pack_filename, v_permit_pack_content_type,
                v_permit_pack_s3_key,
                v_permit_pack_size::integer, false, now(), now(), 2384850, 2384850, false, uuid_generate_v4(),
                v_permit_pack_displayname)
        returning id into v_permit_pack_attachment_id;

        insert into flow.project_attachment(attachment_id, project_id, date_created, date_modified, created_by_id,
                                            modified_by_id, linked, archived)
        values (v_permit_pack_attachment_id, v_project_id, now(), now(), 2384850, 2384850, false, false);
      end if;

      if v_shade_report_filename is not null and v_shade_report_filename != '' then

        insert into flow.attachment(attachment_type_id, company_id, filename, content_type, s3_key, size, archived,
                                    date_created, date_modified, created_by_id, modified_by_id, show, uuid,
                                    display_name)
        values (v_shade_report_attachment_type_id, 3, v_shade_report_filename, v_shade_report_content_type,
                v_shade_report_s3_key, v_shade_report_size::integer, false, now(), now(), 2384850, 2384850, false,
                uuid_generate_v4(),
                v_shade_report_displayname)
        returning id into v_shade_report_attachment_id;

        insert into flow.project_attachment(attachment_id, project_id, date_created, date_modified, created_by_id,
                                            modified_by_id, linked, archived)
        values (v_shade_report_attachment_id, v_project_id, now(), now(), 2384850, 2384850, false, false);
      end if;


      if v_approved_permit_pack_filename is not null and v_approved_permit_pack_filename != '' then

        insert into flow.attachment(attachment_type_id, company_id, filename, content_type, s3_key, size, archived,
                                    date_created, date_modified, created_by_id, modified_by_id, show, uuid,
                                    display_name)
        values (v_approved_permit_pack_attachment_type_id, 3, v_approved_permit_pack_filename,
                v_approved_permit_pack_content_type, v_approved_permit_pack_s3_key,
                v_approved_permit_pack_size::integer, false,
                now(),
                now(), 2384850, 2384850, false, uuid_generate_v4(),
                v_approved_permit_pack_displayname)
        returning id into v_approved_permit_pack_attachment_id;

        insert into flow.project_attachment(attachment_id, project_id, date_created, date_modified, created_by_id,
                                            modified_by_id, linked, archived)
        values (v_approved_permit_pack_attachment_id, v_project_id, now(), now(), 2384850, 2384850, false, false);
      end if;

      if v_chatter_file_filename is not null and v_chatter_file_filename != '' then

        insert into flow.attachment(attachment_type_id, company_id, filename, content_type, s3_key, size, archived,
                                    date_created, date_modified, created_by_id, modified_by_id, show, uuid,
                                    display_name)
        values (v_chatter_file_attachment_type_id, 3, v_chatter_file_filename,
                v_chatter_file_content_type, v_chatter_file_s3_key, v_chatter_file_size::integer, false,
                now(),
                now(), 2384850, 2384850, false, uuid_generate_v4(),
                v_chatter_file_displayname)
        returning id into v_chatter_file_attachment_id;

        insert into flow.project_attachment(attachment_id, project_id, date_created, date_modified, created_by_id,
                                            modified_by_id, linked, archived)
        values (v_chatter_file_attachment_id, v_project_id, now(), now(), 2384850, 2384850, false, false);
      end if;

      v_project_activity_id = null;

      if v_battery_topic is not null and v_battery_topic != '' then

        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_battery_topic, now(), 2384850, 2384850, false, false, null, false, null, null,
                null,
                2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 68, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;

      if v_change_order_topic is not null and v_change_order_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_change_order_topic, now(), 2384850, 2384850, false, false, null, false, null,
                null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 75, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_design_rework_topic is not null and v_design_rework_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_design_rework_topic, now(), 2384850, 2384850, false, false, null, false, null,
                null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 7, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_electrical_review_topic is not null and v_electrical_review_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_electrical_review_topic, now(), 2384850, 2384850, false, false, null, false,
                null,
                null, null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 9, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_final_design_topic is not null and v_final_design_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_final_design_topic, now(), 2384850, 2384850, false, false, null, false, null,
                null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 9, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_financing_topic is not null and v_financing_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_financing_topic, now(), 2384850, 2384850, false, false, null, false, null, null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 55, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_hic_topic is not null and v_hic_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_hic_topic, now(), 2384850, 2384850, false, false, null, false, null, null, null,
                2,
                104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 49, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_hoa_topic is not null and v_hoa_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_hoa_topic, now(), 2384850, 2384850, false, false, null, false, null, null, null,
                2,
                104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 5, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_installation_topic is not null and v_installation_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_installation_topic, now(), 2384850, 2384850, false, false, null, false, null,
                null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 23, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_interconnection_topic is not null and v_interconnection_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_interconnection_topic, now(), 2384850, 2384850, false, false, null, false, null,
                null, null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 52, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_intro_call_topic is not null and v_intro_call_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_intro_call_topic, now(), 2384850, 2384850, false, false, null, false, null, null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 62, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_mpu_topic is not null and v_mpu_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_mpu_topic, now(), 2384850, 2384850, false, false, null, false, null, null, null,
                2,
                104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 26, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_permit_pack_topic is not null and v_permit_pack_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_permit_pack_topic, now(), 2384850, 2384850, false, false, null, false, null,
                null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 11, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_permit_rework_topic is not null and v_permit_rework_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_permit_rework_topic, now(), 2384850, 2384850, false, false, null, false, null,
                null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 12, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;


      v_project_activity_id = null;
      if v_permitting_topic is not null and v_permitting_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_permitting_topic, now(), 2384850, 2384850, false, false, null, false, null, null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 31, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_proposals_topic is not null and v_proposals_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_proposals_topic, now(), 2384850, 2384850, false, false, null, false, null, null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 33, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_rebate_topic is not null and v_rebate_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_rebate_topic, now(), 2384850, 2384850, false, false, null, false, null, null,
                null,
                2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 64, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_reroof_topic is not null and v_reroof_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_reroof_topic, now(), 2384850, 2384850, false, false, null, false, null, null,
                null,
                2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 27, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_resurvey_topic is not null and v_resurvey_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_resurvey_topic, now(), 2384850, 2384850, false, false, null, false, null, null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 14, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_site_survey_topic is not null and v_site_survey_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_site_survey_topic, now(), 2384850, 2384850, false, false, null, false, null,
                null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 18, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_structural_review_topic is not null and v_structural_review_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_structural_review_topic, now(), 2384850, 2384850, false, false, null, false,
                null,
                null, null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 19, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_trenching_topic is not null and v_trenching_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_trenching_topic, now(), 2384850, 2384850, false, false, null, false, null, null,
                null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 30, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_tree_trimming_or_removal_topic is not null and v_tree_trimming_or_removal_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_tree_trimming_or_removal_topic, now(), 2384850, 2384850, false, false, null,
                false,
                null, null, null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 29, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_utility_bill_verification_topic is not null and v_utility_bill_verification_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_utility_bill_verification_topic, now(), 2384850, 2384850, false, false, null,
                false,
                null, null, null, 2, 104055)
        returning id into v_project_activity_id;

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 61, now(), now(), 2384850, 2384850, null, false);

        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;

      v_project_activity_id = null;
      if v_other_topic is not null and v_other_topic != '' then
        insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id,
                                          archived, pinned, pinned_by_id, linked,
                                          linked_pps_id, date_pinned, linked_ppse_id, activity_type_id,
                                          created_by_user_position_id)
        values (v_project_id, now(), v_other_topic, now(), 2384850, 2384850, false, false, null, false, null, null,
                null,
                2, 104055)
        returning id into v_project_activity_id;


        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified,
                                                  created_by_id, modified_by_id, temp_parent_id, archived)
        values (v_project_activity_id, 58, now(), now(), 2384850, 2384850, null, false);
      end if;


    EXCEPTION
      WHEN OTHERS THEN
        v_error_message = 'An error occurred:' || SQLERRM || ' SQLSTATE: ' || SQLSTATE;
    END;

    if v_error_message is null then
      insert into flow.import_sp_project(project_id, sp_project_id, sp_project_data, date_created, file_name)
      values (v_project_id, v_sp_project_id, p_record, now(), p_file_name);
    end if;

    --   raise notice 'v_project_id %',v_project_id;
--   raise notice 'v_sp_project_id %',v_sp_project_id;
--   raise notice 'now()::timestamp %',now()::timestamp;
--   raise notice 'coalesce(v_error_message, ''Success'') %',v_project_id;

    return query
      select v_project_id, v_sp_project_id, now()::timestamp, coalesce(v_error_message, 'Success'), v_pps_id;
  else
    return query select null, v_sp_project_id, now()::timestamp, 'Duplicate Project', null;
  end if;
end;
$$
