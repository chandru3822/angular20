-- DROP FUNCTION IF EXISTS flow.get_attachment_compare_fields(integer);
CREATE OR REPLACE FUNCTION flow.get_attachment_compare_fields(p_attachment_id INTEGER)

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
declare
  v_source_id      int;
  v_object_type_id int;
BEGIN

  select object_type_id, source_id
  into v_object_type_id, v_source_id
  from flow.get_attachment_origin(p_attachment_id);

  return query
    --native fields, always use this query
    select cf.id   as custom_field_id,
           cf.field_name,
           null::int as default_field_id,
           a.id    as attachment_id,
           cfga.id as custom_field_group_assignment_id,
           acfv.text_value,
           acfv.int_value,
           acfv.date_value,
           acfv.timestamp_value,
           acfv.boolean_value,
           acfv.numeric_value,
           acfv.rich_text_value
    from flow.attachment a
           inner join flow.custom_field_group cfg on cfg.attachment_type_id = a.attachment_type_id
           inner join flow.custom_field_group_assignment cfga on cfg.id = cfga.custom_field_group_id
           inner join flow.custom_field cf on cfga.custom_field_id = cf.id
           left join flow.attachment_custom_field_value acfv
                     on a.id = acfv.attachment_id and acfv.custom_field_group_assignment_id = cfga.id
    where a.id = p_attachment_id
      and cfg.archived is false
      and cfga.archived is false
    union all
      select *
      from flow.get_attachment_compare_fields_for_object(p_attachment_id, v_source_id, v_object_type_id)
    order by field_name;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
