drop function if exists flow.get_one_cfv(bigint, bigint, bigint);
CREATE OR REPLACE FUNCTION flow.get_one_cfv(p_object_type_id bigint,
                                            p_cfga_id bigint,
                                            p_primary_id bigint)
  RETURNS TABLE
          (
            custom_field_group_assignment_id bigint,
            data_type_id                     bigint,
            field_name                       VARCHAR,
            date_value                       date,
            timestamp_value                  timestamp,
            boolean_value                    boolean,
            text_value                       text,
            numeric_value                    numeric,
            int_value                        bigint,
            int_array_value                  bigint[],
            rich_text_value                  text,
            int_value_as_text                varchar,
            int_array_value_as_text          text
          )
AS
$BODY$
-- declare
--   v_field_saved             boolean;
BEGIN

  --todo: write for other object types as needed

  -- 6 = events.
  if p_object_type_id = 6 then
    --events dont allow ancillary or fields from data view. so this one is easier
    return query
    select ppsecfv.custom_field_group_assignment_id,
           cdt.data_type_id,
           cf.field_name,
           ppsecfv.date_value,
           ppsecfv.timestamp_value,
           ppsecfv.boolean_value,
           ppsecfv.text_value,
           ppsecfv.numeric_value,
           ppsecfv.int_value,
           ppsecfv.int_array_value,
           ppsecfv.rich_text_value,
           case when ppsecfv.int_value is not null and cf.list_of_value_id is not null then
                  (select lov.name from flow.list_of_value lov
                   where lov.parent_id = cf.list_of_value_id
                     and lov.id = ppsecfv.int_value)
                when sl.system_list_type_id = 1 then
                  ( select o.org_name
                    from flow.org o
                    where o.id = ppsecfv.int_value)
                when sl.system_list_type_id = 2 then
                  (select concat(u.first_name, ' ', u.last_name)
                   from flow.user_position up
                          inner join flow.user u on u.id = up.user_id
                   where up.id = ppsecfv.int_value)
             end as int_value_as_text,
           case when ppsecfv.int_array_value is not null and cf.list_of_value_id is not null then
                  (select string_agg(name, ',')
                   from flow.list_of_value lov
                   where lov.parent_id = cf.list_of_value_id
                     and lov.id = any(ppsecfv.int_array_value))
             end as int_array_value_as_text
    from flow.project_process_step_event_custom_field_value ppsecfv
           inner join flow.custom_field_group_assignment cfga on cfga.id = ppsecfv.custom_field_group_assignment_id
           inner join flow.custom_field cf on cf.id = cfga.custom_field_id
           inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
           left join flow.company_system_list csl on csl.id = cf.company_system_list_id
           left join flow.system_list sl on sl.id = csl.system_list_id
    where ppsecfv.project_process_step_event_id = p_primary_id
      and ppsecfv.custom_field_group_assignment_id = p_cfga_id;

  end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
