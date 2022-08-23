drop function if exists flow.project_count_by_company_status(p_company_id bigint);
  CREATE OR REPLACE FUNCTION flow.project_count_by_company_status(p_company_id bigint)
    RETURNS TABLE
            (
                company_project_status_type_id bigint,
                company_project_status         character varying,
                project_status_count           bigint
            )
    LANGUAGE plpgsql
AS
$function$

BEGIN

        RETURN QUERY
            SELECT limited_projects.company_project_status_type_id,
                   limited_projects.company_project_status,
                   limited_projects.project_status_count
            FROM (
                     select
                        cpst.id as company_project_status_type_id,
                        cpst.project_status_type as company_project_status,
                        count(p.id) as project_status_count
                     from flow.company_project_status_type cpst
                              left join flow.project p
                                         on cpst.id = p.company_project_status_type_id
                                        and  p.archived is not true
                              left join flow.company_process cp on cp.id = p.company_process_id
                                    and cp.company_id = p_company_id
                     where cpst.company_id =  p_company_id
                        and cpst.archived is false
                     group by cpst.id,cpst.project_status_type
                     order by cpst.display_order
                 ) as limited_projects;
END;
$function$
