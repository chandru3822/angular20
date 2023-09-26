drop function if exists brs.get_closer_manager(bigint, bigint);
CREATE OR REPLACE FUNCTION brs.get_closer_manager(p_closer_user_id bigint default null,
                                                  p_closer_user_position_id bigint default null)
  RETURNS TABLE
          (
            user_position_id bigint,
            user_id          bigint,
            full_name        text,
            phone_number     varchar,
            s3_key           varchar
          )
  LANGUAGE plpgsql
AS
$function$

declare
  v_position_id         bigint;
  v_org_id              bigint;
  v_parent_org_id       bigint;
  v_org_id_to_use       bigint;
  v_manager_position_id bigint;
BEGIN

  --1 = closer
  --2 = closer manager
  --3 = closer regional

  --133 = inside sales
  --574 = inside sales manager


  --get the position (1,2,3
  --if they sent in the closer's user id
  if (p_closer_user_id is not null) then
    select up.position_id, up.org_id, o.parent_org_id
    into v_position_id, v_org_id, v_parent_org_id
    from flow.user_position up
           inner join flow.org o on up.org_id = o.id
    where up.user_id = p_closer_user_id
      and up.primary_flag is true
      and up.archived is false
      and up.start_date < now()
      and (up.end_date is null or up.end_date > now());
  else
    select up.position_id, up.org_id, o.parent_org_id
    into v_position_id, v_org_id, v_parent_org_id
    from flow.user_position up
           inner join flow.org o on up.org_id = o.id
    where up.id = p_closer_user_position_id;
  end if;

  RAISE NOTICE 'value %', v_position_id;
  RAISE NOTICE 'value %', v_org_id;
  RAISE NOTICE 'value %', v_parent_org_id;


  --if it is a closer manager, then the regional is in the parent org
  select case when v_position_id = 2 then v_parent_org_id else v_org_id end into v_org_id_to_use;

  --get the position id of the manager type we are looking for
  select case
           when v_position_id = 1 then 2
           when v_position_id = 2 then 3
           when v_position_id = 133 then 574 end
  into v_manager_position_id;

  if (v_manager_position_id is not null) then
    RETURN QUERY
      select up.id                                  as user_position_id,
             up.user_id,
             concat(u.first_name, ' ', u.last_name) AS full_name,
             u.phone_number,
             (select a.s3_key   FROM flow.attachment a
                     INNER JOIN flow.attachment_source src ON src.attachment_id = a.id
              where src.source_id = u.id
                and a.attachment_type_id = 9
                and a.archived is false) as s3_key
      from flow.user_position up
             INNER JOIN flow.position p on up.position_id = p.id
             INNER JOIN flow."user" u on up.user_id = u.id
             INNER JOIN flow.company_user_status cus on cus.user_id = u.id
             INNER JOIN flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = p.company_id
      where up.org_id = v_org_id_to_use
        and up.position_id = v_manager_position_id
        and up.archived is false
        and up.start_date < now()
        and ust.has_access is true
        and (up.end_date is null or up.end_date > now())
      limit 1;
  end if;


END
$function$
