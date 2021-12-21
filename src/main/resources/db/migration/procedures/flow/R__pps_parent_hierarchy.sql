-- drop function flow.pps_parent_hierarchy(int, int);
-- allow self reference currently only used by proposals who know their originating pps.id
--     but they also need ancillary data off of their originating id.
CREATE OR REPLACE FUNCTION flow.pps_parent_hierarchy(
p_project_process_step_id integer,
p_custom_field_group_assignment_id integer,
p_allow_self_reference boolean default false)
  RETURNS TABLE(id integer) AS
$BODY$
declare

BEGIN
    return query
        WITH RECURSIVE subordinates(id) AS (
            select pps.id,pps.parent_project_process_step_id
            from flow.project_process_step pps
            where pps.id = p_project_process_step_id
            UNION
            select pps.id,pps.parent_project_process_step_id
            from flow.project_process_step pps
                     INNER JOIN subordinates s ON s.parent_project_process_step_id = pps.id
        ) SELECT
              s1.id
        FROM
            subordinates s1
            inner join flow.project_process_step pps2 on pps2.id = s1.id
            inner join flow.project_process_step_custom_field_value ppscfv  on pps2.id = ppscfv.project_process_step_id
                and ppscfv.custom_field_group_assignment_id = p_custom_field_group_assignment_id
          where case when p_allow_self_reference is not true then s1.id != p_project_process_step_id else 1=1 end
    limit 1;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

