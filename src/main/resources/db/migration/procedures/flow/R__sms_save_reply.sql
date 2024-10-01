drop function if exists flow.sms_save_reply(p_message_sid text,
                                            p_account_sid text,
                                            p_messaging_service_sid text,
                                            p_from text,
                                            p_to text,
                                            p_body text,
                                            p_num_media int,
                                            p_media_urls  text[],
                                            p_recipient_type_id int);
create or replace function flow.sms_save_reply(
    p_message_sid text,
    p_account_sid text,
    p_messaging_service_sid text,
    p_from text,
    p_to text,
    p_body text,
    p_num_media int,
    p_media_urls  text[],
    p_recipient_type_id int
)
  returns void
  language plpgsql as
$$
declare
  v_thread_id     bigint;
  v_inserted_row_id     bigint;
  v_clean_from_phone text;
begin

    select
        ("right"(
    translate((COALESCE(p_from, ''::character varying))::text, '+-() '::text, ''::text), 10)) into v_clean_from_phone;

    select st.id into v_thread_id
        from flow.sms_thread st
    where st.search_external_phone = v_clean_from_phone
    and st.id = st.parent_id
    and st.recipient_type_id = p_recipient_type_id;

    insert into flow.sms_thread(message, external_phone, internal_phone, recipient_type_id,
                                message_sid, account_sid, messaging_service_sid,
                                num_media, media_urls, message_status, date_modified,
                                twilio_received, inbound, parent_id)
    values (p_body, p_from, p_to, p_recipient_type_id, p_message_sid, p_account_sid, p_messaging_service_sid,
           p_num_media, p_media_urls, 'received', now(), now(), true, v_thread_id)
    returning id into v_inserted_row_id;

--     todo: seems dumb, ask keller how to be smarter
    if(v_thread_id is null) then
        update flow.sms_thread
        set parent_id = v_inserted_row_id
        where id = v_inserted_row_id;
    end if;

end
$$;
