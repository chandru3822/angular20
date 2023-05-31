DROP FUNCTION IF EXISTS flow.set_sms_user_owner_history(bigint, bigint,bigint[],bigint,boolean,boolean);
CREATE OR REPLACE FUNCTION flow.set_sms_user_owner_history(p_user_id bigint, p_sms_team_id bigint,
                                                          p_user_ids bigint[],
                                                          p_current_user_id bigint,
                                                          p_add boolean default false,
                                                          p_remove_team boolean default false)
  RETURNS void as
$BODY$
declare
v_team_count bigint;
  v_user_message_owner_history_id bigint;
BEGIN

  if p_add is true then

    select count(1)
    into v_team_count
    from flow.user_message_owner_history
    where owner_user_id = p_user_id
      and sms_team_id = p_sms_team_id
      and date_created is not null
      and date_removed is null
      and user_id is null;

    if v_team_count < 1 then
      insert into flow.user_message_owner_history(owner_user_id, sms_team_id, user_id,
                                                     date_removed, date_created, date_modified, created_by_id)
      values (p_user_id, p_sms_team_id, null, null, now(), now(), p_current_user_id);
    end if;

    if p_user_ids is not null then

      with my_data as (
        select unnest(p_user_ids) as user_id
      )
      insert
      into flow.user_message_owner_history(owner_user_id, sms_team_id, user_id,
                                              date_removed, date_created, date_modified, created_by_id)
        (
          select p_user_id,
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
        into v_user_message_owner_history_id
        from flow.user_message_owner_history
        where owner_user_id = p_user_id
          and sms_team_id = p_sms_team_id
          and date_created is not null
          and date_removed is null
          and user_id is null;
        update flow.user_message_owner_history
        set date_removed = now(),
            date_modified = now(),
            modified_by_id = p_current_user_id
        where id = v_user_message_owner_history_id;

        update flow.user_message_owner_history umoh
        set date_removed = now(),
            date_modified = now(),
            modified_by_id = p_current_user_id
        where umoh.sms_team_id = p_sms_team_id and
              umoh.owner_user_id = p_user_id and
              umoh.date_removed is null;

    else
        with update_data as (
          select unnest(p_user_ids)::bigint as user_id
        )
        update flow.user_message_owner_history umoh
        set date_removed = now(),
            date_modified = now(),
            modified_by_id = p_current_user_id
            from update_data ud
        where ud.user_id = umoh.user_id and
            umoh.sms_team_id = p_sms_team_id and
            umoh.owner_user_id = p_user_id and
            date_removed is null;
    end if;
end if;

END
$BODY$
LANGUAGE plpgsql VOLATILE
                   COST 100;
