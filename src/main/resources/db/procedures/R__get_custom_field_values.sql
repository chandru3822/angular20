-- DROP FUNCTION IF EXISTS blueraven.get_custom_field_values(integer, integer, integer);

CREATE OR REPLACE FUNCTION flow.get_custom_field_values(p_company_id INTEGER, p_primary_id INTEGER, p_object_type_id INTEGER)

RETURNS SETOF JSON AS

$BODY$
DECLARE
BEGIN

    --select * from flow.get_custom_field_values(1, 111112, 2);
    case when p_object_type_id = 1 then
        RETURN QUERY select array_to_json(array_agg(row_to_json(fieldGroups)))
             from (
                select *
                from flow.project
             ) fieldGroups;
    when p_object_type_id = 2 then
        RETURN QUERY select array_to_json(array_agg(row_to_json(fieldGroups)))
               from (
                    select cfg.id,
                           cfg.group_name as "groupName",
                           cfg.group_order as "groupOrder",
                           coalesce((
                                        SELECT array_to_json(array_agg(row_to_json(fields)))
                                        FROM (
                                                 select ccv.id,
                                                        ccv.customer_id as "customerId",
                                                        ccv.date_value as "dateValue",
                                                        ccv.custom_field_group_assignment_id as "customFieldGroupAssignmentId",
                                                        ccv.timestamp_value as "timestampValue",
                                                        ccv.boolean_value as "booleanValue",
                                                        ccv.text_value as "textValue",
                                                        ccv.numeric_value as "numericValue",
                                                        ccv.int_value as "intValue",
                                                        ccv.int_array_value as "intArrayValue",
                                                        cfga.custom_field_group_id as "customFieldGroupId",
                                                        cfga.custom_field_id as "customFieldId",
                                                        cfga.field_order as "fieldOrder",
                                                        cf.list_of_value_id as "listOfValueId",
                                                        cf.field_name as "fieldName",
                                                        cf.company_data_type_id as "companyDataTypeId",
                                                        dt.id as "dataTypeId"
                                                 from flow.custom_field_group_assignment cfga
                                                          inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                                                          inner join flow.data_type dt on dt.id = cf.company_data_type_id
                                                          left join flow.customer_custom_field_value ccv on ccv.custom_field_group_assignment_id = cfga.id and ccv.customer_id = p_primary_id
                                                          left join flow.list_of_value lv on lv.id = cf.list_of_value_id
                                                 where cfga.custom_field_group_id = cfg.id
                                                   and cfga.archived is not true
                                                 order by cfga.field_order
                                             ) fields), '[]') AS "customFieldValues"
                    from flow.custom_field_group cfg
                             inner join flow.object_type ot on ot.id = cfg.object_type_id
                    where cfg.object_type_id = p_object_type_id
                      and cfg.archived is not true
                      and ot.company_id = p_company_id
                    order by cfg.group_order
                ) fieldGroups;

    when p_object_type_id = 3 then
        RETURN QUERY select array_to_json(array_agg(row_to_json(fieldGroups)))
             from (
                      select *
                      from flow.user
                  ) fieldGroups;

    when p_object_type_id = 4 then
        RETURN QUERY select array_to_json(array_agg(row_to_json(fieldGroups)))
             from (
                      select *
                      from flow.process_step
                  ) fieldGroups;
    end case;

END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100
                     ROWS 1000;
