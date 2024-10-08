/**
  Adds project milestone message to queue.
  Runs on flow.project row update.
  Verifies project has attached partner.
 */


drop function if exists brs.webhook_project_milestone() cascade;
create or replace function brs.webhook_project_milestone()
returns trigger as
$$
declare
  v_company_id bigint;
  v_is_milestone bool;
  v_partner_ids bigint[];
  v_status_type text;
  v_message_payload jsonb;
  v_webhook_payload jsonb;
begin

select
  cpst.company_id,
  cpst.is_milestone,
  pcfv.int_array_value,
  cpst.project_status_type
into
  v_company_id,
  v_is_milestone,
  v_partner_ids,
  v_status_type
from flow.project p
inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
inner join flow.project_custom_field_value pcfv on pcfv.project_id = p.id and
                                                   pcfv.custom_field_group_assignment_id = 27972
where
  p.id = new.id and
  pcfv.int_array_value is not null;

if v_partner_ids is not null and v_company_id = 3 and v_is_milestone then

  v_webhook_payload := jsonb_build_object(
    'id', new.id,
    'milestone', v_status_type,
    'type', 'timestamp',
    'value', now()
  );

  v_message_payload := jsonb_build_object(
    'project_id', new.id,
    'partner_ids', v_partner_ids,
    'data', v_webhook_payload
  );

  insert into flow.message_queue(topic, payload, created_by)
  values ('webhook:project_milestone', v_message_payload, new.modified_by_id);
end if;

return null;
end
$$
language plpgsql;

drop trigger if exists webhook_project_milestone_trg on flow.project;
create trigger webhook_project_milestone_trg
  after update
  on flow.project
  for each row
  when (
    old.archived is false and
    new.archived is false and
    old.company_project_status_type_id != new.company_project_status_type_id
  )
execute procedure brs.webhook_project_milestone();
