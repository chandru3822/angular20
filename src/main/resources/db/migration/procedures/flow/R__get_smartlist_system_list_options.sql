-- drop function if exists flow.get_smartlist_system_list_options(int, int);

create or replace function flow.get_smartlist_system_list_options(p_smartlist_system_list_id int, p_company_id int)

returns table(id int, name varchar) as

$$
begin
  case when p_smartlist_system_list_id = 1 then
    return query
      select cs.id,
             s.abbreviation as name
      from flow.company_state cs
      inner join flow.state s on s.id = cs.state_id
      where cs.active is true
        and cs.company_id = p_company_id
      order by s.state;
  when p_smartlist_system_list_id = 2 then
    return query
      select psst.id, psst.process_step_status_type as name
      from flow.process_step_status_type psst
      order by psst.id;
  when p_smartlist_system_list_id = 3 then
    return query
      select cpst.id, cpst.project_status_type as name
      from flow.company_project_status_type cpst
      where cpst.company_id = p_company_id and
            cpst.archived is not true
      order by cpst.project_status_type;
  end case;
end;
$$
language plpgsql
volatile;