drop function if exists brs.get_day_of_week(p_date timestamp);
CREATE OR REPLACE FUNCTION brs.get_day_of_week(p_date timestamp)
    returns bigint AS
$BODY$
declare
    v_dow bigint;
BEGIN
    select extract(dow from p_date)
    into v_dow;
    return v_dow;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
