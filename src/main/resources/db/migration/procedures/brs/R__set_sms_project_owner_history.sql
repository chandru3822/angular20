DROP FUNCTION IF EXISTS flow.set_sms_project_owner_history(bigint, bigint,bigint[],bigint,boolean,boolean);
CREATE OR REPLACE FUNCTION flow.set_sms_project_owner_history(p_project_id bigint, p_sms_team_id bigint,
                                                          p_user_ids bigint[],
                                                          p_current_user_id bigint,
                                                          p_add boolean default false,
                                                          p_remove_team boolean default false)
  RETURNS void as
$BODY$
declare
v_team_count bigint;
  v_project_message_owner_history_id bigint;
BEGIN

  if p_add is true then

select count(1)
into v_team_count
from flow.project_message_owner_history
where project_id = p_project_id
  and sms_team_id = p_sms_team_id
  and date_created is not null
  and date_removed is null
  and user_id is null;

if v_team_count < 1 then
      insert into flow.project_message_owner_history(project_id, sms_team_id, user_id,
                                                     date_removed, date_created, date_modified, created_by_id)
      values (p_project_id, p_sms_team_id, null, null, now(), now(), p_current_user_id);
end if;

    if p_user_ids is not null then

      with my_data as (
        select unnest(p_user_ids) as user_id
      )
      insert
      into flow.project_message_owner_history(project_id, sms_team_id, user_id,
                                              date_removed, date_created, date_modified, created_by_id)
        (
          select p_project_id,
                 p_sms_team_id,
                 md.user_id,
                 null,
                 now(),
                 now(),
                 p_current_user_id
          from my_data md
          where md.user_id is not null);

end if;
else
    if p_remove_team is true then
select id
into v_project_message_owner_history_id
from flow.project_message_owner_history
where project_id = p_project_id
  and sms_team_id = p_sms_team_id
  and date_created is not null
  and user_id is null;
update flow.project_message_owner_history
set date_removed = now(),
    date_modified = now(),
    modified_by_id = p_current_user_id
where id = v_project_message_owner_history_id;

update flow.project_message_owner_history pmoh
set date_removed = now(),
    date_modified = now(),
    modified_by_id = p_current_user_id
where pmoh.sms_team_id = p_sms_team_id and
        pmoh.project_id = p_project_id;

else
      with update_data as (
        select unnest(p_user_ids)::bigint as user_id
      )
update flow.project_message_owner_history pmoh
set date_removed = now(),
    date_modified = now(),
    modified_by_id = p_current_user_id
    from update_data ud
where ud.user_id = pmoh.user_id and
    pmoh.sms_team_id = p_sms_team_id and
    pmoh.project_id = p_project_id;
end if;
end if;

END
$BODY$
LANGUAGE plpgsql VOLATILE
                   COST 100;
