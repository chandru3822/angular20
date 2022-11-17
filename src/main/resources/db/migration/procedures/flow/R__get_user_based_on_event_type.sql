drop function if exists flow.get_user_based_on_event_type(p_project_id bigint);
  CREATE OR REPLACE FUNCTION flow.get_user_based_on_event_type(p_project_id bigint)
    RETURNS bigint AS
$BODY$
declare
    v_user_id bigint;
BEGIN
        select pv.int_value
        into v_user_id
        from flow.project_process_step pps
                 inner join flow.project_process_step_custom_field_value pv on pv.project_process_step_id = pps.id
                 inner join flow.custom_field_group_assignment cfga on cfga.id = pv.custom_field_group_assignment_id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                 inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
        where pps.project_id = p_project_id
--           and cfg.event_type_id = p_event_type_id
          and cfg.archived is false
          and pps.archived is false
          and pv.archived is false
          and cf.archived is false
          and cfga.archived is false
          and cdt.data_type_id = 9
        limit 1;
        return v_user_id;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

