drop function if exists flow.get_project_available_owners(bigint, bigint, bool);

create or replace function flow.get_project_available_owners(p_company_id bigint, p_parent_company_id bigint, p_is_parent bool)

  returns table (
                  user_id bigint,
                  first_name varchar,
                  last_name varchar,
                  full_name text,
                  has_access boolean,
                  user_position_id bigint,
                  "position" varchar,
                  position_id bigint,
                  phone_number varchar
                ) as

$$
BEGIN
  return query
    select  DISTINCT ON (u.first_name, u.last_name, u.id)
           u.id as user_id,
           u.first_name,
           u.last_name,
           concat(u.first_name, ' ', u.last_name) as full_name,
           ust.has_access,
           up.id as user_position_id,
           p.position,
           up.position_id,
           u.phone_number
    from flow.user_position up
           inner join flow.position p on up.position_id = p.id
           inner join flow."user" u on up.user_id = u.id
           inner join flow.company_user_status cust on cust.user_id = u.id
           inner join flow.user_status_type ust on ust.id = cust.user_status_type_id and ust.company_id = p.company_id
    where up.archived is not true
    and ust.has_access is true
    and case when p_is_parent then
                 p.company_id = any (select id from flow.company_hierarchy_filter_down(p_parent_company_id::bigint))
             else p.company_id = p_company_id end
    and up.start_date <= now()
    and (up.end_date is null or up.end_date >= now())
    and p.project_owner is true
      --ordering by u.id is silly but required by the distinct on thing
    order by u.first_name, u.last_name, u.id, up.primary_flag desc;
END
$$
  language plpgsql;
