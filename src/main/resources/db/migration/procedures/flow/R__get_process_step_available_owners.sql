-- drop function if exists flow.get_process_step_available_owners(int, int, boolean);

create or replace function flow.get_process_step_available_owners(p_process_step_id int, p_company_id int, p_in_parent_company boolean)

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
with positions as (
 select array(
    select pspop.position_id
    from flow.process_step_process_owning_position pspop
    inner join flow.position p1 on p1.id = pspop.position_id
    inner join flow.process_step_process psp on psp.id = pspop.process_step_process_id
    where psp.process_step_id = p_process_step_id and
          pspop.archived is not true and
          case when p_in_parent_company
             then p1.company_id = any(select id from flow.company c where (c.id = p_company_id or c.parent_company_id = p_company_id) and c.archived is not true)
             else p1.company_id = p_company_id
          end
    ) as position_ids
)
select u.id as user_id,
      u.first_name,
      u.last_name,
      concat(u.first_name, ' ', u.last_name) as full_name,
      up.id as user_position_id,
      p.position
from positions
inner join flow.user_position up on array[up.position_id] <@ positions.position_ids
inner join flow.user u on u.id = up.user_id
inner join flow.position p on p.id = up.position_id
inner join flow.user_status_type ust on ust.company_id = p.company_id
inner join flow.company_user_status cus on cus.user_id = u.id and cus.user_status_type_id = ust.id
where ust.has_access is true and
     up.start_date <= now() and
     (up.end_date is null or up.end_date >= now()) and
     p.archived is not true
order by u.last_name, u.first_name;
END
$$
language plpgsql;