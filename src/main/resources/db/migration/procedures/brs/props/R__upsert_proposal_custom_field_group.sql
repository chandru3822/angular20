drop function if exists brs.upsert_proposal_custom_field_group(bigint, uuid, bigint);
create or replace function brs.upsert_proposal_custom_field_group(p_proposal_version bigint, p_group_uuid uuid, p_current_user bigint)
  returns int as
$$
declare
  ret int;
begin

  select id
  into ret
  from brs.proposal_version_custom_field_group
  where proposal_version_id = p_proposal_version
    and proposal_group_uuid = p_group_uuid
    and archived is null;

  if ret is null then
    insert into brs.proposal_version_custom_field_group
      (proposal_version_id, proposal_group_uuid, date_created, date_modified, created_by_id, modified_by_id)
      values (p_proposal_version, p_group_uuid, now(), now(), p_current_user, p_current_user)
    returning id into ret;
  end if;

  return ret;
end;
$$ language plpgsql;
