drop function if exists brs.upsert_list_of_value(text, bigint, bigint);

create or replace function brs.upsert_list_of_value(p_name text, p_parent_id bigint, p_created_by_id bigint)
returns bigint
language plpgsql as
$$
declare
  v_id bigint;
begin

select lov.id, lov.name
into v_id
from brs.list_of_value lov
where
  lov.parent_id = p_parent_id and
  lov.archived is false and
  lov.name = trim(p_name);

if v_id is not null then
  return v_id;
end if;

insert into brs.list_of_value(
  name,
  parent_id,
  display_order,
  date_created,
  created_by_id,
  date_modified,
  modified_by_id
)
values (
  trim(p_name),
  p_parent_id,
  (
    select coalesce(max(display_order) + 1, 0)
    from brs.list_of_value
    where
      parent_id = p_parent_id and
      archived is not true
  ),
  now(),
  p_created_by_id,
  now(),
  p_created_by_id
)
on conflict do nothing
returning id
into v_id;

return v_id;
end;
$$