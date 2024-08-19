drop function if exists flow.get_thread_id(bigint, bigint, text);
create or replace function flow.get_thread_id(p_project_id bigint, p_user_id bigint, p_from_phone_number text)
  returns bigint
  language plpgsql as
$$
declare
  v_thread_id     bigint;
  v_phone_number     text;
begin

    if(p_project_id is not null) then
        select search_phones into v_phone_number
            from flow.contact c
        inner join flow.project p on c.id = p.contact_id
        where c.archived is false
          and p.archived is false
        and p.id = p_project_id;
    else
        select u.search_phone into v_phone_number
            from flow.user u
        where u.archived is false
        and u.id = p_user_id;
    end if;

    select st.id into v_thread_id
        from flow.sms_thread st
    where st.id = st.parent_id
        and st.search_external_phone = v_phone_number;

    if(v_thread_id is null) then
        insert into flow.sms_thread(message, internal_phone, external_phone, recipient_type_id, message_sent_by_user_id, sent_to_user_id, sent_to_project_id, archived)
        select 'THREAD INITIALIZATION', p_from_phone_number, v_phone_number, case when p_project_id is not null then 2 else 1 end, 99999999, p_user_id, p_project_id, true;
    end if;

    return v_thread_id;
end;
$$;
