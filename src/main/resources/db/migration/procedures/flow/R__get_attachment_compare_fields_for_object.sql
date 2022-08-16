-- DROP FUNCTION IF EXISTS flow.get_attachment_compare_fields_for_object(integer);
CREATE OR REPLACE FUNCTION flow.get_attachment_compare_fields_for_object(p_attachment_id INTEGER, p_source_id int, p_object_type_id integer)

  RETURNS TABLE
          (
            custom_field_id                  int,
            field_name                       character varying,
            default_field_id int,
            attachment_id                    int,
            custom_field_group_assignment_id int,
            text_value                       text,
            int_value                        int,
            date_value                       date,
            timestamp_value                  timestamp,
            boolean_value                    boolean,
            numeric_value                    numeric(10, 2),
            rich_text_value                  text
          )
AS

$BODY$
BEGIN

  case when p_object_type_id = 4 then
  return query
    select cf.id           as custom_field_id,
           cf.field_name,
           null::int as default_field_id,
           p_attachment_id as attachment_id,
           cfga.id         as custom_field_group_assignment_id,
           ppscfv.text_value,
           ppscfv.int_value,
           ppscfv.date_value,
           ppscfv.timestamp_value,
           ppscfv.boolean_value,
           ppscfv.numeric_value,
           ppscfv.rich_text_value
    from flow.project_process_step_custom_field_value ppscfv
           inner join flow.custom_field_group_assignment cfga on ppscfv.custom_field_group_assignment_id = cfga.id
           inner join flow.custom_field cf on cfga.custom_field_id = cf.id
    where ppscfv.project_process_step_id = p_source_id
      and cfga.archived is false;
  when p_object_type_id = 6 then
    return query
      select cf.id           as custom_field_id,
             cf.field_name,
             null::int as default_field_id,
             p_attachment_id as attachment_id,
             cfga.id         as custom_field_group_assignment_id,
             ppsecfv.text_value,
             ppsecfv.int_value,
             ppsecfv.date_value,
             ppsecfv.timestamp_value,
             ppsecfv.boolean_value,
             ppsecfv.numeric_value,
             ppsecfv.rich_text_value
      from flow.project_process_step_event_custom_field_value ppsecfv
             inner join flow.custom_field_group_assignment cfga on ppsecfv.custom_field_group_assignment_id = cfga.id
             inner join flow.custom_field cf on cfga.custom_field_id = cf.id
      where cfga.archived is false
        and ppsecfv.id = p_source_id
      union all
      select null::int as custom_field_id,
             df.field_name,
             cfga.default_field_id,
             p_attachment_id as attachment_id,
             cfga.id         as custom_field_group_assignment_id,
             null::text as text_value,
             case when df.id = 12 then (select resource_id from flow.project_process_step_event ppse where ppse.id = p_source_id)
                else null::int end as int_value,
             null::date as date_value,
             case when df.id = 10 then (select start_time from flow.project_process_step_event ppse where ppse.id = p_source_id)
                  when df.id = 11 then (select end_time from flow.project_process_step_event ppse where ppse.id = p_source_id) else null::timestamp end,
             null::boolean as boolean_value,
             null::numeric as numeric_value,
             null::text as rich_text_value
      from flow.custom_field_group_assignment cfga
             inner join flow.default_field df on cfga.default_field_id = df.id
             inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
             inner join flow.event_attachment_type eat on cfg.event_attachment_type_id = eat.id and eat.event_id = (
                select pse.event_id
                from flow.project_process_step_event ppse
                       inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
                where ppse.id = p_source_id
              )
      where cfga.archived is false
        and cfg.archived is false;
end case;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
