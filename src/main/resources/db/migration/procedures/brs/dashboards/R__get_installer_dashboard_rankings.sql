drop function if exists brs.get_installer_dashboard_rankings(p_start_date DATE, p_end_date DATE, p_company_id bigint,
                                                             p_parent_company_id bigint, p_is_parent boolean);
CREATE OR REPLACE FUNCTION brs.get_installer_dashboard_rankings(p_start_date DATE, p_end_date DATE, p_company_id bigint,
                                                                    p_parent_company_id bigint, p_is_parent boolean)
    RETURNS SETOF JSON AS
$BODY$
BEGIN

RETURN QUERY SELECT array_to_json(array_agg(row_to_json(sub_rows)))
    FROM (
        select rank() over (order by c.score desc nulls last) rnk, c.full_name as crewName, c.substantialCompletions,
            c.inspectionApproval * 100 ::numeric(10, 2) as inspectionApproval, c.score ::numeric(10, 0)
            from (
             select b.full_name,
                    substantialCompletions,
                    inspectionApproval,
                    coalesce((inspectionApproval * substantialCompletions),0)  ::numeric(10, 0) as score
             from (
                    select o.id                                  as positionId,
                           o.org_name                            AS full_name,

                           (select coalesce((select sum(system_size)
                                    from brs.project_details pd
                                    where substantial_completion_date between p_start_date and p_end_date
                                      AND pd.installation_resource = o.id
                                   ),0) as substantialCompletions) ::numeric(10, 2),

                           (select coalesce((select count(*) from brs.project_details pd
                            where
                                (
                                  pd.ahj_inspection_start_time::date between p_start_date and p_end_date
                                  AND
                                  (pd.ahj_inspection_outcome_name = 'Pass' OR
                                   pd.ahj_inspection_outcome_name = 'Fail' AND (

                                       (select string_agg(lov.name, ', ')
                                        from flow.list_of_value lov
                                        where lov.id = any ((
                                            select int_array_value as inspection_fail_feedback  from flow.project_process_step_custom_field_value
                                            where custom_field_group_assignment_id = (select id from flow.custom_field_group_assignment where archived is false and custom_field_id = (select id from flow.custom_field
                                                                                                                                                                                       where field_name = 'AHJ Inspection Fail Reason' and company_id = pd.company_id and archived is false)
                                                                                                                                          and custom_field_group_id = (select cfg.id
                                                                                                                                                                       from flow.custom_field_group cfg
                                                                                                                                                                                inner join flow.project_process_step pps on pps.process_step_id = cfg.process_step_id
                                                                                                                                                                       where  cfg.archived is not true
                                                                                                                                                                         and pps.id = (select id from flow.project_process_step where project_id = pd.project_id
                                                                                                                                                                                                                                  and process_step_id =
                                                                                                                                                                                                                                      (select id from flow.process_step
                                                                                                                                                                                                                                       where process_step_name = 'Disposition Inspection Failure' and company_id = pd.company_id and archived is false) and main is true))) and
                                                    project_process_step_id = (select id from flow.project_process_step where project_id = pd.project_id
                                                                                                                          and process_step_id =
                                                                                                                              (select id from flow.process_step
                                                                                                                               where process_step_name = 'Disposition Inspection Failure' and company_id = pd.company_id and archived is false) and main is true))::bigint[]))


                                       ) not ILIKE ALL(ARRAY['%crew%','%Crew%','%electrician%','%Electrician%','%rim%']))
                                )
                            AND
                            pd.installation_resource = o.id) ::numeric(10,2)
                                        /
                            NULLIF(((select count(*) from brs.project_details pd
                                where pd.ahj_inspection_start_time::date between p_start_date and p_end_date
                                AND
                                pd.ahj_inspection_outcome is not null
                                AND
                                pd.installation_resource = o.id) ::numeric(10,2)),0),0)) ::numeric(10, 2) as inspectionApproval
                      from flow.org o
                      where org_type_id = 6
                        and archived = false
                        and active_flag = true
                        and case
                                when (p_is_parent)
                                    then company_id = p_parent_company_id
                                else company_id = p_company_id
                          end
                  ) b
         ) c
    ) as sub_rows;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
