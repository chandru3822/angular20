CREATE OR REPLACE FUNCTION flow.get_value_for_custom_field(p_object_type_id integer,
                                                           p_custom_field_id integer,
                                                           p_id integer,
                                                            -- p_id = the primary key for the object type record you are using, so contact_id, project_id, user_id, etc
                                                           p_process_step_id integer default 0,
                                                            -- if using object_type_id = 4 then p_process_step_id is required
                                                           p_get_id boolean default false
                                                           )
    RETURNS setof text AS
$BODY$
declare
BEGIN
    case when p_object_type_id = 4 then
        return query
            select case
                       when cdt.id = 7 and p_get_id is false then (select lov.name
                                             from flow.list_of_value lov
                                             where lov.id = pscfv.int_value::integer)::text
                       when dt.id = 1 then pscfv.date_value::text
                       when dt.id = 2 then pscfv.timestamp_value::text
                       when dt.id = 3 then pscfv.boolean_value::text
                       when dt.id = 4 then pscfv.numeric_value::text
                       when dt.id = 5 or dt.id = 13 then pscfv.text_value
                       when dt.id = 6 then pscfv.int_value::text
                       when dt.id = 7 then pscfv.int_array_value::text
                       when dt.id = 8 then pscfv.int_value::text
                       when dt.id = 9 then pscfv.int_value::text
                       end
            from flow.project p
                     inner join flow.project_process_step pps
                                on pps.project_id = p.id and pps.process_step_id = p_process_step_id
                     inner join flow.project_process_step_custom_field_value pscfv
                                on pps.id = pscfv.project_process_step_id
                     inner join flow.custom_field_group_assignment cfga
                                on cfga.id = pscfv.custom_field_group_assignment_id
                     inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                     inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                     inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
                     inner join flow.data_type dt on dt.id = cdt.data_type_id
            where cfga.custom_field_id = p_custom_field_id
              and p.id = p_id;
        when p_object_type_id = 1 then
            return query
                select case
                           when cdt.id = 7 and p_get_id is false then (select lov.name
                                                 from flow.list_of_value lov
                                                 where lov.id = pcfv.int_value::integer)::text
                           when dt.id = 1 then pcfv.date_value::text
                           when dt.id = 2 then pcfv.timestamp_value::text
                           when dt.id = 3 then pcfv.boolean_value::text
                           when dt.id = 4 then pcfv.numeric_value::text
                           when dt.id = 5 or dt.id = 13 then pcfv.text_value
                           when dt.id = 6 then pcfv.int_value::text
                           when dt.id = 7 then pcfv.int_array_value::text
                           when dt.id = 8 then pcfv.int_value::text
                           when dt.id = 9 then pcfv.int_value::text
                           end
                from flow.project p
                         inner join flow.project_custom_field_value pcfv on p.id = pcfv.project_id
                         inner join flow.custom_field_group_assignment cfga
                                    on cfga.id = pcfv.custom_field_group_assignment_id
                         inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                         inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                         inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
                         inner join flow.data_type dt on dt.id = cdt.data_type_id
                where cfga.custom_field_id = p_custom_field_id
                  and p.id = p_id;
        when p_object_type_id = 2 then
            return query
                select case
                           when cdt.id = 7 and p_get_id is false then (select lov.name
                                                 from flow.list_of_value lov
                                                 where lov.id = ccfv.int_value::integer)::text
                           when dt.id = 1 then ccfv.date_value::text
                           when dt.id = 2 then ccfv.timestamp_value::text
                           when dt.id = 3 then ccfv.boolean_value::text
                           when dt.id = 4 then ccfv.numeric_value::text
                           when dt.id = 5 or dt.id = 13 then ccfv.text_value
                           when dt.id = 6 then ccfv.int_value::text
                           when dt.id = 7 then ccfv.int_array_value::text
                           when dt.id = 8 then ccfv.int_value::text
                           when dt.id = 9 then ccfv.int_value::text
                           end
                from flow.contact c
                         inner join flow.contact_custom_field_value ccfv on c.id = ccfv.contact_id
                         inner join flow.custom_field_group_assignment cfga
                                    on cfga.id = ccfv.custom_field_group_assignment_id
                         inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                         inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                         inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
                         inner join flow.data_type dt on dt.id = cdt.data_type_id
                where cfga.custom_field_id = p_custom_field_id
                  and c.id = p_id;
        when p_object_type_id = 3 then
            return query
                select case
                           when cdt.id = 7 and p_get_id is false then (select lov.name
                                                 from flow.list_of_value lov
                                                 where lov.id = ucfv.int_value::integer)::text
                           when dt.id = 1 then ucfv.date_value::text
                           when dt.id = 2 then ucfv.timestamp_value::text
                           when dt.id = 3 then ucfv.boolean_value::text
                           when dt.id = 4 then ucfv.numeric_value::text
                           when dt.id = 5 or dt.id = 13 then ucfv.text_value
                           when dt.id = 6 then ucfv.int_value::text
                           when dt.id = 7 then ucfv.int_array_value::text
                           when dt.id = 8 then ucfv.int_value::text
                           when dt.id = 9 then ucfv.int_value::text
                           end
                from flow.user u
                         inner join flow.user_custom_field_value ucfv on u.id = ucfv.user_id
                         inner join flow.custom_field_group_assignment cfga
                                    on cfga.id = ucfv.custom_field_group_assignment_id
                         inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                         inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                         inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
                         inner join flow.data_type dt on dt.id = cdt.data_type_id
                where cfga.custom_field_id = p_custom_field_id
                  and u.id = p_id;
        when p_object_type_id = 5 then
            return query
                select case
                           when cdt.id = 7 and p_get_id is false then (select lov.name
                                                 from flow.list_of_value lov
                                                 where lov.id = ocfv.int_value::integer)::text
                           when dt.id = 1 then ocfv.date_value::text
                           when dt.id = 2 then ocfv.timestamp_value::text
                           when dt.id = 3 then ocfv.boolean_value::text
                           when dt.id = 4 then ocfv.numeric_value::text
                           when dt.id = 5 or dt.id = 13 then ocfv.text_value
                           when dt.id = 6 then ocfv.int_value::text
                           when dt.id = 7 then ocfv.int_array_value::text
                           when dt.id = 8 then ocfv.int_value::text
                           when dt.id = 9 then ocfv.int_value::text
                           end
                from flow.org o
                         inner join flow.organization_custom_field_value ocfv on o.id = ocfv.org_id
                         inner join flow.custom_field_group_assignment cfga
                                    on cfga.id = ocfv.custom_field_group_assignment_id
                         inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                         inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                         inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
                         inner join flow.data_type dt on dt.id = cdt.data_type_id
                where cfga.custom_field_id = p_custom_field_id
                  and o.id = p_id;
        end case;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

