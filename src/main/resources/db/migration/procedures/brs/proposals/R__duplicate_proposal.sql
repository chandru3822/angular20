drop function if exists brs.proposal_duplicate(bigint, bigint);
create or replace function brs.proposal_duplicate(p_proposal_id bigint, p_user_id bigint)
  returns int
  language plpgsql as
$$
declare
  new_proposal_id     int;
  new_revision_number int;
begin

  insert into brs.proposal_revision_number as p (proposal_id, revision_number)
  select coalesce(p.original_proposal_id, p.id), 1
  from brs.proposal p
  where p.id = p_proposal_id
  on conflict (proposal_id) do update
    set revision_number = p.revision_number + 1
  returning p.revision_number into new_revision_number;

  --create new proposal
  insert into brs.proposal(project_process_step_id, proposal_version_id, name,
                           original_proposal_id, revision_number,
                           date_created, date_modified,
                           created_by_id, modified_by_id)
  select p.project_process_step_id,
         p.proposal_version_id,
         p.name,
         coalesce(p.original_proposal_id, p.id),
         new_revision_number,
         now(),
         now(),
         p_user_id,
         p_user_id
  from brs.proposal p
  where id = p_proposal_id
  returning id into new_proposal_id;

  --copy custom field values to new proposal
  insert into brs.proposal_custom_field_value(proposal_id, custom_field_group_assignment_id,
                                              date_value, timestamp_value, boolean_value,
                                              text_value, numeric_value, int_value, int_array_value,
                                              date_created, date_modified, created_by_id, modified_by_id)
  select new_proposal_id,
         pcfv.custom_field_group_assignment_id,
         pcfv.date_value,
         pcfv.timestamp_value,
         pcfv.boolean_value,
         pcfv.text_value,
         pcfv.numeric_value,
         pcfv.int_value,
         pcfv.int_array_value,
         now(),
         now(),
         p_user_id,
         p_user_id
  from brs.proposal_custom_field_value pcfv
  where pcfv.proposal_id = p_proposal_id;

  return new_proposal_id;
end;
$$;
