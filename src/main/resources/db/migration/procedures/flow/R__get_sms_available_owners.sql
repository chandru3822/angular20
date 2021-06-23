-- drop function if exists flow.get_sms_available_owners(int, int, bool);

create or replace function flow.get_sms_available_owners(p_company_id int, p_parent_company_id int, p_is_parent bool)

  returns table (
                  user_id bigint,
                  first_name varchar,
                  last_name varchar,
                  full_name text,
                  user_position_id int,
                  "position" varchar,
                  position_id int
                ) as

$$
BEGIN
  return query
    select u.id as user_id,
           u.first_name,
           u.last_name,
           concat(u.first_name, ' ', u.last_name) as full_name,
           up.id as user_position_id,
           p.position,
           up.position_id
    from flow.user_position up
           inner join flow.position p on up.position_id = p.id
           inner join flow."user" u on up.user_id = u.id
           inner join flow.company_user_status cust on cust.user_id = u.id
           inner join flow.user_status_type ust on ust.id = cust.user_status_type_id and ust.company_id = p.company_id
    where up.archived is not true
    and ust.has_access is true
    and case when p_is_parent then
                 p.company_id = any (select id from flow.company_hierarchy_filter_down(p_parent_company_id::int))
             else p.company_id = p_company_id end
    and up.start_date <= now()
    and (up.end_date is null or up.end_date >= now())
    and p.sms_owner is true
    order by u.first_name, u.last_name;
END
$$
  language plpgsql;
