-- drop function flow.pps_parent_hierarchy(bigint, bigint);
-- allow self reference currently only used by proposals who know their originating pps.id
--     but they also need ancillary data off of their originating id.
CREATE OR REPLACE FUNCTION flow.pps_parent_hierarchy_up(
p_project_process_step_id bigint,
p_main boolean)
  RETURNS TABLE(id bigint,process_step_id bigint,main boolean,status_id bigint) AS
$BODY$
BEGIN
    return query
        WITH RECURSIVE subordinates(id) AS (
            select pps.id,pps.parent_project_process_step_id,pps.process_step_id,pps.main,pps.date_created,psst.id as status_id
            from flow.project_process_step pps
            inner join flow.company_process_step_status_type cppst on pps.company_process_step_status_type_id = cppst.id
            inner join flow.process_step_status_type psst on cppst.process_step_status_type_id = psst.id
            where pps.id = p_project_process_step_id
            --and pps.main = p_main
            UNION
            select pps.id,pps.parent_project_process_step_id,pps.process_step_id,pps.main,pps.date_created,psst.id as status_id
            from flow.project_process_step pps
                   inner join flow.company_process_step_status_type cppst on pps.company_process_step_status_type_id = cppst.id
                   inner join flow.process_step_status_type psst on cppst.process_step_status_type_id = psst.id
                     INNER JOIN subordinates s ON  pps.id =s.parent_project_process_step_id
           --   and pps.main = p_main
        ) SELECT
              s1.id::bigint,s1.process_step_id::bigint,s1.main,s1.status_id::bigint
        FROM
            subordinates s1
            inner join flow.project_process_step pps2 on pps2.id = s1.id
    where s1.main = p_main and s1.process_step_id = 3365
    order by s1.date_created desc
    limit 1;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

