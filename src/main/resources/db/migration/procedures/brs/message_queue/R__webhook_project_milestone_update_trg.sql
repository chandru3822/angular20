/**
  Adds project milestone message to queue.
  Runs on brs.milestones row update.
  Verifies project has attached partner.
 */


drop function if exists brs.webhook_project_milestone() cascade;
create or replace function brs.webhook_project_milestone()
returns trigger as
$$
declare
  v_partner_ids bigint[];
  v_label text;
  v_field_key text;
  v_value date;
  v_external_id text;
  v_message_payload jsonb;
  v_webhook_payload jsonb;
begin

select
  pcfv.int_array_value,
  pcfv2.text_value
into
  v_partner_ids,
  v_external_id
from brs.milestones m
inner join flow.project p on p.id = m.project_id
inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
inner join flow.project_custom_field_value pcfv on pcfv.project_id = m.project_id and
                                                   pcfv.custom_field_group_assignment_id = 27972
inner join flow.project_custom_field_value pcfv2 on pcfv2.project_id = m.project_id and
                                                    pcfv2.custom_field_group_assignment_id = 28736

where
  m.project_id = new.project_id and
  pcfv.int_array_value is not null;

if v_partner_ids is not null and new.company_id = 3 then

  if old.site_survey_scheduled is null and new.site_survey_scheduled is not null then
    v_label = 'Site Survey Schedule';
    v_field_key = 'site_survey_schedule';
    v_value = new.site_survey_scheduled;

  elseif old.final_design_created is null and new.final_design_created is not null then
    v_label = 'Design Start';
    v_field_key = 'design_start';
    v_value = new.final_design_created;

  elseif old.permit_submitted_to_jurisdiction is null and new.permit_submitted_to_jurisdiction is not null then
    v_label = 'Permit Request';
    v_field_key = 'permit_request';
    v_value = new.permit_submitted_to_jurisdiction;

  elseif old.permit_approved_by_jurisdiction is null and new.permit_approved_by_jurisdiction is not null then
    v_label = 'Permit Receive';
    v_field_key = 'permit_receive';
    v_value = new.permit_approved_by_jurisdiction;

  elseif old.installation_date is null and new.installation_date is not null then
    v_label = 'Install Start Date';
    v_field_key = 'install_start_date';
    v_value = new.installation_date;

  elseif old.inspection_scheduled_with_jurisdiction is null and new.inspection_scheduled_with_jurisdiction is not null then
    v_label = 'Inspection Scheduled Date';
    v_field_key = 'inspection_scheduled_date';
    v_value = new.inspection_scheduled_with_jurisdiction;

  elseif old.inspection_passed is null and new.inspection_passed is not null then
    v_label = 'Final Inspection Passed';
    v_field_key = 'final_inspection_passed';
    v_value = new.inspection_passed;

  elseif old.net_meter_installed is null and new.net_meter_installed is not null then
    v_label = 'PTO Receive';
    v_field_key = 'pto_receive';
    v_value = new.net_meter_installed;
  end if;

  if v_value is not null then
    v_webhook_payload := jsonb_build_object(
      'external_id', v_external_id,
      'stages', jsonb_build_array(jsonb_build_object(
        'field_key', v_field_key,
        'label', v_label,
        'value', v_value
      ))
    );

    v_message_payload := jsonb_build_object(
      'project_id', new.project_id,
      'partner_ids', v_partner_ids,
      'data', v_webhook_payload
    );

    insert into flow.message_queue(topic_id, payload, created_by)
    values (1, v_message_payload, 99999999);
  end if;
end if;

return null;
end
$$
language plpgsql;

drop trigger if exists webhook_project_milestone_trg on flow.project;
drop trigger if exists webhook_project_milestone_trg on brs.milestones;
create trigger webhook_project_milestone_trg
  after update
  on brs.milestones
  for each row
  when (old is distinct from new)
execute procedure brs.webhook_project_milestone();
