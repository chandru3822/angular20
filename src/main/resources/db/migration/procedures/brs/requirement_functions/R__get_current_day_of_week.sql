drop function if exists brs.get_current_day_of_week()
CREATE OR REPLACE FUNCTION brs.get_current_day_of_week()
    returns bigint AS
$BODY$
declare
    v_dow bigint;
BEGIN
    select brs.get_day_of_week((now() at time zone 'US/Mountain')::timestamp)
    into v_dow;
    return v_dow;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
