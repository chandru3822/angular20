/**
  Logs adding/removing from message queue
 */
-- todo: may make actions (enqueue/dequeue) and topic_ids enums (or described in another table)

drop function if exists flow.message_queue_log_audit() cascade;
create or replace function flow.message_queue_log_audit()
  returns trigger as
$$
begin

  if TG_OP = 'INSERT' then
    insert into flow.message_queue_log(message_id, status, action, topic_id, attempt, payload, created_by)
    values(new.message_id, new.status, 'enqueue', new.topic_id, new.attempt, to_jsonb(new.payload), new.created_by);

    perform pg_notify(new.topic_id::text, to_jsonb(new.payload)::text);

  elseif TG_OP = 'UPDATE' then
    insert into flow.message_queue_log(message_id, status, action, topic_id, attempt, payload, created_by)
    values(new.message_id, new.status, 'modify', new.topic_id, new.attempt, to_jsonb(new.payload), new.created_by);

  elseif TG_OP = 'DELETE' then
    insert into flow.message_queue_log(message_id, status, action, topic_id, attempt, payload, created_by)
    values(old.message_id, 'complete', 'dequeue', old.topic_id, old.attempt, to_jsonb(old.payload), old.created_by);
  end if;

  return null;
end
$$
  language plpgsql;


-- add actual trigger
drop trigger if exists message_queue_log_trg on flow.message_queue;
create trigger message_queue_log_trg
  after insert or update or delete
  on flow.message_queue
  for each row
execute procedure flow.message_queue_log_audit();