CREATE OR REPLACE FUNCTION brs.get_day_of_week(p_date timestamp)
    returns integer AS
$BODY$
declare
    v_dow integer;
BEGIN
    select extract(dow from p_date)
    into v_dow;
    return v_dow;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
