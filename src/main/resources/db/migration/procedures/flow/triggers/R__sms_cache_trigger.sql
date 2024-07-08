drop function if exists flow.update_cache_sms_queue() cascade;
CREATE OR REPLACE FUNCTION flow.update_cache_sms_queue()
  RETURNS TRIGGER AS
$body$
declare
BEGIN
  if new.recipient_type_id = 1 then --user

    insert into flow.sms_cache (user_id, message_text, created_by_id, modified_by_id, outbound_message)
    values (new.user_id, new.message, coalesce(new.message_sent_by_user_id, new.user_id),
            coalesce(new.message_sent_by_user_id, new.user_id), true)
    on conflict (user_id) do update
      set message_text   = new.message,
          outbound_message = excluded.outbound_message,
          date_modified = now(),
          created_by_id  = coalesce(new.message_sent_by_user_id, new.user_id),
          modified_by_id = coalesce(new.message_sent_by_user_id, new.user_id);

  elsif new.recipient_type_id = 2 then -- project
    insert into flow.project_conversation (phone_number, last_message_text, outbound_message)
    values (phone_number, new.message, true)
    on conflict (phone_number) do update
      set last_message_text = new.message,
          outbound_message = excluded.outbound_message,
          date_modified = now();
  end if;

  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_sms_cache_trg on flow.sms_queue;
CREATE TRIGGER update_sms_cache_trg
  after INSERT
  ON flow.sms_queue
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_cache_sms_queue();


drop function if exists flow.update_cache_sms_reply() cascade;
CREATE OR REPLACE FUNCTION flow.update_cache_sms_reply()
  RETURNS TRIGGER AS
$body$
declare
  v_project_id bigint;
  v_user_id    bigint;
BEGIN

  if new.to_phone != '+18014480212' then --user

    select u.id
    into v_user_id
    from flow."user" u
    where u.search_phone = new.search_from_phone;

    insert into flow.sms_cache (user_id, message_text, outbound_message)
    values (v_user_id,
            case when length(new.body) > 0 then new.body when new.num_media > 0 then 'Customer sent Image' else '' end,
            false)
    on conflict (user_id) do update
      set message_text     = excluded.message_text,
          outbound_message = excluded.outbound_message,
          date_modified    = now();

  elsif new.to_phone = '+18014480212' then -- project

    insert into flow.project_conversation (phone_number, last_message_text, outbound_message)
    values (new.search_from_phone,
            case
              when length(new.body) > 0
                then new.body
              when new.num_media > 0
                then 'Customer sent Image'
              else '' end,
            false)
    on conflict (phone_number) do update
      set last_message_text     = excluded.last_message_text,
          outbound_message = excluded.outbound_message,
          date_modified    = now();
  end if;

  return null;

exception
  when others then
    -- don't do anything just return so the insert works
    raise notice 'unable to find a project or a user';
    RETURN old;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_sms_reply_trg on flow.sms_reply;
CREATE TRIGGER update_sms_reply_trg
  after INSERT
  ON flow.sms_reply
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_cache_sms_reply();
