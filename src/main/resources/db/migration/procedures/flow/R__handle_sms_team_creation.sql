drop function if exists flow.handle_sms_team_creation(p_thread_id bigint,
                                             p_team_id bigint,
                                             p_current_user_id bigint,
                                             p_selected_user_ids bigint[]);
create or replace function flow.handle_sms_team_creation(
    p_thread_id bigint,
    p_team_id bigint,
    p_current_user_id bigint,
    p_selected_user_ids bigint[]
)
  returns table (
        clear_unassigned boolean,
        newly_selected_user_ids bigint[]
    )
  language plpgsql as
$$
declare
  v_existing_row_id     bigint;
  v_previously_selected_user_ids bigint[];
  v_newly_selected_user_ids bigint[];
begin

    select id into v_existing_row_id
    from flow.sms_thread_owner
        where sms_team_id = p_team_id
          and sms_thread_id = p_thread_id
        and archived is false
        and user_id is null;


    raise info 'selected ids = %', p_selected_user_ids;
    if(v_existing_row_id is null) then
        --if there isn't an existing row, then add it
        insert into flow.sms_thread_owner(sms_team_id, date_created, date_modified, created_by_id, modified_by_id, sms_thread_id)
        values(p_team_id, now(), now(), p_current_user_id, p_current_user_id, p_thread_id);

        --use the selected list later as the newly selected, since all of these will be new
        v_newly_selected_user_ids = p_selected_user_ids;
    elsif(p_selected_user_ids is not null and array_length(p_selected_user_ids, 1) > 0) then
        --get any previously selected user ids (i think the frontend can send in repeats so we have to check that)
        select array_agg(user_id) into v_previously_selected_user_ids
        from flow.sms_thread_owner
        where sms_team_id = p_team_id
            and sms_thread_id = p_thread_id
            and user_id is not null
            and archived is false;

        SELECT ARRAY(
                       SELECT unnest(p_selected_user_ids)
                       EXCEPT
                       SELECT unnest(v_previously_selected_user_ids)
                   ) into v_newly_selected_user_ids;

        raise notice 'newly selected = %', v_newly_selected_user_ids;
    end if;

    return query select coalesce(array_length(v_previously_selected_user_ids, 1) = 0, false),
                        v_newly_selected_user_ids;
end
$$;
