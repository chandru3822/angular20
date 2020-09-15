ALTER TABLE flow.sms_queue
    DROP CONSTRAINT if exists sms_queue_user_id_fkey;

UPDATE flow.record_type
SET
    type = 'PROJECT'
where id = 2;
