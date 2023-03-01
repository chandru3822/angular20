drop function if exists brs.call_group_phone_log_trigger();
CREATE OR REPLACE FUNCTION brs.call_group_phone_log_trigger()
    RETURNS TRIGGER AS
$$
declare

BEGIN
    update brs.call_group_phone_number
    set call_count = call_count+1, date_modified = now()
    where call_group_id = new.call_group_id and phone_number = new.phone_number
      and active is true and archived is false;

    RETURN null;
END
$$
    LANGUAGE plpgsql;

drop trigger if exists brs_call_group_phone_log_trg on brs.call_group_phone_log;
CREATE TRIGGER brs_call_group_phone_log_trg
    after INSERT
    ON brs.call_group_phone_log
    FOR EACH ROW
EXECUTE PROCEDURE brs.call_group_phone_log_trigger();
