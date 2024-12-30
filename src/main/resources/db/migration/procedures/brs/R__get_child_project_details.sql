drop function if exists brs.get_child_project_details(p_parent_project_id bigint);
CREATE OR REPLACE FUNCTION brs.get_child_project_details(p_parent_project_id bigint)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
BEGIN


 RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(flatten_rows))), '[]')
                        from (
                            select p.id,
                                   p.project_name as "projectName",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28217) as "28217",
                                    (select boolean_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28222) as "28222",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28227) as "28227",
                                    (select int_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28232) as "28232",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28238) as "28238",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28241) as "28241",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28246) as "28246",
                                    (select boolean_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28248) as "28248",
                                    (select boolean_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28251) as "28251",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28254) as "28254",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28256) as "28256",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28261) as "28261",
                                    (select boolean_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28266) as "28266",
                                    (select boolean_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28290) as "28290",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28302) as "28302",
                                    (select int_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28306) as "28306",
                                    (select timestamp_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28307) as "28307",
                                    (select boolean_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28308) as "28308",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28310) as "28310",
                                    (select timestamp_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28312) as "28312",
                                    (select int_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28314) as "28314",
                                    (select boolean_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28316) as "28316",
                                    (select int_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28318) as "28318",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28320) as "28320",
                                    (select timestamp_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28322) as "28322",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28340) as "28340",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28341) as "28341",
                                    (select boolean_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28342) as "28342",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28343) as "28343",
                                    (select int_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28344) as "28344",
                                    (select timestamp_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28345) as "28345",
                                    (select boolean_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28346) as "28346",
                                    (select date_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28347) as "28347",
                                    (select int_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28348) as "28348",
                                    (select timestamp_value from flow.project_custom_field_value pcfv where pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 28349) as "28349"
                            from flow.project p
                            where p.parent_id = p_parent_project_id
                              and p.archived is false
                            order by p.id
                             ) as flatten_rows;


END
$function$



