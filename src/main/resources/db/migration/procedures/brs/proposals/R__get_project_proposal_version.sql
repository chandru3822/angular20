drop function if exists brs.get_project_proposal_version(bigint, bigint);
create or replace function brs.get_project_proposal_version(p_pps_id bigint, p_current_user_id bigint)
  returns bigint
as
$$
declare
  v_project_id          bigint;
  v_proposal_version_id bigint;
  v_company_id          bigint;
begin
  select pps.project_id, pppv.proposal_version_id, ps.company_id
  into v_project_id, v_proposal_version_id, v_company_id
  from flow.project_process_step pps
         inner join flow.process_step ps on pps.process_step_id = ps.id
         left join brs.proposal_project_proposal_version pppv on pppv.project_id = pps.project_id
  where pps.id = p_pps_id;

--     if we've found a version tied to a project just return it
  if v_proposal_version_id is not null then
    return v_proposal_version_id;
  end if;

--     get the current published version
  select proposal_version_id
  into v_proposal_version_id
  from brs.primary_company_proposal_version
  where company_id = v_company_id;

--     associate the current version with the project
  insert into brs.proposal_project_proposal_version (project_id, proposal_version_id, created_by_id, modified_by_id)
  values (v_project_id, v_proposal_version_id, p_current_user_id, p_current_user_id)
  on conflict (project_id) do nothing;

  return v_proposal_version_id;
end ;
$$
  language plpgsql
  volatile
  cost 100;
