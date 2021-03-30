CREATE OR REPLACE FUNCTION brs.get_day_of_week(p_custom_field_group_assignment_id integer, p_project_process_step_id integer)
    returns integer AS
$BODY$
declare
    v_dow integer;
    v_date timestamp;
BEGIN

    select coalesce(ppscfv.date_value,((ppscfv.timestamp_value at time zone 'UTC') at time zone 'US/Mountain'))
    into v_date
    from flow.project_process_step pps
    inner join flow.project_process_step_custom_field_value ppscfv on pps.id = ppscfv.project_process_step_id
    where ppscfv.custom_field_group_assignment_id = p_custom_field_group_assignment_id and
          pps.id = p_project_process_step_id;

    select brs.get_day_of_week(v_date)
    into v_dow;
    return v_dow;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
