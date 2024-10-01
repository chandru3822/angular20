-- drop function if exists flow.update_cache_sms_queue() cascade;
-- drop trigger if exists update_sms_cache_trg on flow.sms_queue;
-- drop function if exists flow.update_cache_sms_reply() cascade;
-- drop trigger if exists update_sms_reply_trg on flow.sms_reply;

drop function if exists flow.update_last_inserted() cascade;
CREATE OR REPLACE FUNCTION flow.update_last_inserted()
    RETURNS TRIGGER AS $$
BEGIN
    UPDATE flow.sms_thread
    SET is_last_inserted = FALSE
    WHERE parent_id = NEW.parent_id AND is_last_inserted = TRUE;

    NEW.is_last_inserted = TRUE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


drop trigger if exists set_last_inserted on flow.sms_thread;
CREATE TRIGGER set_last_inserted
    BEFORE INSERT ON flow.sms_thread
    FOR EACH ROW
EXECUTE FUNCTION flow.update_last_inserted();
