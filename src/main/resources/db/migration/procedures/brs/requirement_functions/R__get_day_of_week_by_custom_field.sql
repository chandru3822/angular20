drop function if exists brs.get_day_of_week_by_custom_field(p_custom_field_group_assignment_id bigint, p_project_process_step_id bigint);
CREATE OR REPLACE FUNCTION brs.get_day_of_week_by_custom_field(p_custom_field_group_assignment_id bigint, p_project_process_step_id bigint)
    returns bigint AS
$BODY$
declare
    v_dow bigint;
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
