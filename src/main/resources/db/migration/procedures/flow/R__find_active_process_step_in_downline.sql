drop function if exists flow.find_active_process_step_in_downline(
  p_project_process_step_id bigint,
  p_process_step_ids bigint[]);
  CREATE OR REPLACE FUNCTION flow.find_active_process_step_in_downline(
    p_project_process_step_id bigint,
    p_process_step_ids bigint[])
  RETURNS TABLE(project_process_step_id bigint,process_step_name character varying(100),
                parent_project_process_step_id bigint,process_step_id bigint,
                completed_date timestamp,row_number bigint,
                process_status_id bigint,main boolean,user_position_id bigint,date_created timestamp) AS
$BODY$
BEGIN
    return query

        WITH RECURSIVE subordinates(id,process_step_name,parent_project_process_step_id,process_step_id,completed_date,row_number1,process_status_id,main) AS (
            select pps.id,ps2.process_step_name,pps.parent_project_process_step_id,ps2.id,pps.process_step_complete_date,1 as row_number1,psst.id,pps.main,
                   pps.user_position_id,pps.date_created
            from flow.project_process_step pps
                     inner join flow.process_step ps2 on ps2.id = pps.process_step_id
                     inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
                     inner join flow.process_step_status_type psst on psst.id = cpsst.process_step_status_type_id
            where pps.id = p_project_process_step_id
            UNION
            select pps.id,ps.process_step_name,pps.parent_project_process_step_id,ps.id,pps.process_step_complete_date,row_number1 + 1 as row_number1,psst.id,pps.main,
            pps.user_position_id,pps.date_created
            from flow.project_process_step pps
                     inner join flow.process_step ps on ps.id = pps.process_step_id
                     inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
                     inner join flow.process_step_status_type psst on psst.id = cpsst.process_step_status_type_id
                     INNER JOIN subordinates s ON s.id = pps.parent_project_process_step_id
          where ps.id = any (p_process_step_ids)
        ) SELECT
            s1.id::bigint,s1.process_step_name,s1.parent_project_process_step_id::bigint,
            s1.process_step_id::bigint,s1.completed_date,s1.row_number1::bigint,
            s1.process_status_id::bigint,s1.main,s1.user_position_id::bigint,
            s1.date_created
        FROM
            subordinates s1
        where
          s1.process_step_id =  any(p_process_step_ids);
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

