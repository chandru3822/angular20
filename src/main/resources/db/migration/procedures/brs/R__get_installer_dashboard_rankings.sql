-- DROP FUNCTION brs.get_installer_dashboard_rankings(DATE, DATE);

-- SELECT * FROM brs.get_installer_dashboard_rankings('01/01/2021', '05/01/2021');

CREATE OR REPLACE FUNCTION brs.get_installer_dashboard_rankings(p_start_date DATE, p_end_date DATE, p_company_id integer,
                                                                    p_parent_company_id integer, p_is_parent boolean)
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

                           (select coalesce((select count(*)
                                             from brs.project_details pd
                                             where (installation_start_time::date between p_start_date and p_end_date
                                                 AND
                                                    ((substantial_completion_date is not null AND
                                                     installation_start_time::date = substantial_completion_date::date)
                                                    OR
                                                    (substantial_completion_date is null AND
                                                     installation_start_time::date =
                                                     (now() at time zone 'US/Mountain')::date))
                                                 )
                                               AND pd.installation_resource = o.id) ::numeric(10, 2)
                                                /
                                            (NULLIF((select count(*)
                                                     from brs.project_details pd
                                                     where installation_start_time::date between p_start_date and p_end_date
                                                       AND pd.installation_resource = o.id), 0) ::numeric(10, 2)),
                                            0)) ::numeric(10, 2) as inspectionApproval
                      from flow.org o
                      where org_type_id = 6
                        and archived = false
                        and active_flag = true
                        and case
                                when (p_is_parent)
                                    then company_id = p_parent_company_id
                                else company_id = p_company_id
                          end
                      limit 9
                  ) b
         ) c
    ) as sub_rows;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
