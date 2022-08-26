drop function if exists flow.get_system_list_option_value(bigint, bigint);
create or replace function flow.get_system_list_option_value(p_company_system_list_id bigint, p_int_value bigint)

  returns table
          (
            id   bigint,
            name text
          )
as

$$
declare
  v_system_list_id bigint;
begin

  SELECT csl.system_list_id
  INTO v_system_list_id
  FROM flow.company_system_list csl
  WHERE csl.id = p_company_system_list_id;

  case
    when v_system_list_id = 1 or v_system_list_id = 2 then -- query off user_position
    return query
      select up.id::bigint,
             concat(u.first_name, ' ', u.last_name::text) as name
      from flow.user_position up
             inner join flow.user u on u.id = up.user_id
      where up.id = p_int_value;
    when v_system_list_id = 3 then -- query off org
    return query
      select o.id::bigint,
             o.org_name::text as name
      from flow.org o
      where o.id = p_int_value;
    when v_system_list_id = 4 then -- query off user
    return query
      select u.id::bigint,
             concat(u.first_name, ' ', u.last_name::text) as name
      from flow.user u
      where u.id = p_int_value;
    end case;
end;
$$
  language plpgsql;
