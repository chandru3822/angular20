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
      select cpssst.id, cpssst.process_step_status_type as name
      from flow.company_process_step_status_type cpssst
      where
        cpssst.company_id = p_company_id and
        cpssst.archived is not true
      order by cpssst.process_step_status_type;
  end case;
end;
$$
language plpgsql
volatile;