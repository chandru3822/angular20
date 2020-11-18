-- drop function if exists flow.get_contact_available_owners(int, boolean);

create or replace function flow.get_contact_available_owners(p_company_id int, p_in_parent_company boolean)

returns table (
    user_id bigint,
    first_name varchar,
    last_name varchar,
    full_name text,
    user_position_id int,
    "position" varchar
) as

$$
BEGIN
return query
select u.id as user_id,
       u.first_name,
       u.last_name,
       concat(u.first_name, ' ', u.last_name) as full_name,
       up.id as user_position_id,
       p.position
from flow.position p
       inner join flow.user_position up on up.position_id = p.id
       inner join flow."user" u on u.id = up.user_id
       inner join flow.company_user_status cus on cus.user_id = u.id
       inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = p.company_id
where
  case when p_in_parent_company
         then p.company_id = any(select id from flow.company c where (c.id = p_company_id or c.parent_company_id = p_company_id) and c.archived is not true)
       else p.company_id = p_company_id
    end
  and p.contact_owner is true
  and ust.has_access is true
  and up.start_date <= now()
  and (up.end_date is null or up.end_date >= now())
order by u.last_name, u.first_name;
END
$$
language plpgsql;