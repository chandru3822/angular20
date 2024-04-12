drop function if exists brs.copy_contact_owner_to_project(p_project_id bigint, p_override_existing boolean, p_user_id bigint);
CREATE OR REPLACE FUNCTION brs.copy_contact_owner_to_project(p_project_id bigint, p_override_existing boolean, p_user_id bigint)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
  v_contact_owner_id bigint;
  v_project_owner_id bigint;
BEGIN
  select c.owner_user_position_id,p.user_position_id
  into v_contact_owner_id,v_project_owner_id
  from flow.project p
    inner join flow.contact c on c.id = p.contact_id
  where p.id = p_project_id;

  if (p_override_existing is true and v_contact_owner_id is not null) or
     (p_override_existing is false and  v_project_owner_id is null and v_contact_owner_id is not null) then
    update flow.project p2
    set user_position_id = v_contact_owner_id,
        date_modified = now(),
        modified_by_id = p_user_id
    where p2.id = p_project_id;
  end if;


END;
$function$
