 drop function if exists flow.get_smartlist_system_list_options(bigint, bigint);

create or replace function flow.get_smartlist_system_list_options(p_smartlist_system_list_id bigint, p_company_id bigint)

  returns table(id bigint, name varchar) as

$$
begin
  case when p_smartlist_system_list_id = 1 then
    -- company states
    return query
      select cs.id,
             s.abbreviation as name
      from flow.company_state cs
             inner join flow.state s on s.id = cs.state_id
      where cs.active is true
      and cs.company_id = p_company_id
      order by s.state;
    when p_smartlist_system_list_id = 2 then
      -- company process step status
      return query
        select cpsst.id,
               cpsst.process_step_status_type as name
        from flow.company_process_step_status_type cpsst
        where cpsst.company_id = p_company_id and
              cpsst.archived is not true
        order by name;
    when p_smartlist_system_list_id = 3 then
      -- project status
      return query
        select pst.id,
               pst.project_status_type as name
        from flow.project_status_type pst
        where pst.archived is not true
        order by name;
    when p_smartlist_system_list_id = 4 then
      -- process step status (category)
      return query
        select psst.id,
               psst.process_step_status_type as name
        from flow.process_step_status_type psst
        where psst.archived is not true
        order by name;
    when p_smartlist_system_list_id = 5 then
      -- company project status (stage)
      return query
        select cpst.id,
               cpst.project_status_type as name
        from flow.company_project_status_type cpst
        where cpst.company_id = p_company_id and
              cpst.archived is not true
        order by name;
    when p_smartlist_system_list_id = 6 then
      -- org levels
      return query
        select ol.id,
               ol.level_name as name
        from flow.org_level ol
        where ol.company_id = p_company_id
      order by level;
    when p_smartlist_system_list_id = 7 then
      -- org types
      return query
        select ot.id,
               ot.org_type as name
        from flow.org_type ot
        inner join flow.org_level ol on ol.id = ot.org_level_id
        where ot.company_id = 3 and
              ot.archived is not true
        order by ol.level, ot.org_type;
    when p_smartlist_system_list_id = 8 then
      --user statuses
      return query
        select ust.id,
               ust.user_status_type as name
        from flow.user_status_type ust
        where ust.company_id = p_company_id and
              ust.archived is not true
        order by ust.user_status_type;
    when p_smartlist_system_list_id = 9 then
      -- positions
      return query
        select p.id,
               p.position as name
        from flow.position p
        where p.company_id = p_company_id and
              p.archived is not true
        order by p.position;
    end case;
end;
$$
  language plpgsql
  volatile;
