CREATE OR REPLACE FUNCTION brs.get_current_day_of_week()
    returns integer AS
$BODY$
declare
    v_dow integer;
BEGIN
    select brs.get_day_of_week((now() at time zone 'US/Mountain')::timestamp)
    into v_dow;
    return v_dow;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
