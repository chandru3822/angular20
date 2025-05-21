DROP FUNCTION IF EXISTS brs.get_brs_feat_db_value_for_copy(p_project_id bigint, p_brs_feat_db_table character varying, p_brs_feat_db_cfga_id bigint, p_cfga_data_type_id bigint, p_use_list_of_values boolean);
 --this is a very poorly named function...
CREATE OR REPLACE FUNCTION brs.get_brs_feat_db_value_for_copy(p_project_id bigint, p_brs_feat_db_table character varying, p_brs_feat_db_cfga_id bigint, p_cfga_data_type_id bigint, p_use_list_of_values boolean, p_company_process_id bigint)
returns table (value_as_text text, rich_text_value text)
AS
$BODY$

declare
  v_table_name       text;
  v_sql              text;

begin

  -- 1,date
  -- 2,timestamp
  -- 3,boolean
  -- 4,numeric
  -- 5,text
  -- 6,integer
  -- 7,integer array
  -- 8,system
  -- 9,System List
  -- 10,system multiselect
  -- 11,JSON
  -- 12,System Read-Only
  -- 13,Rich Text

 -- Dynamic assignment of data view table based on process id
  select dv.view_name into v_table_name
               from flow.data_view dv
                      inner join flow.company c on dv.company_id = c.id
               where p_company_process_id  = any (dv.company_process_ids);

  v_table_name := 'brs.' || v_table_name;

    case when lower(trim(p_brs_feat_db_table)) = 'design' then

        v_sql := format($$
          select
            case
              when %1$L = 1 then cfv.date_value::text
              when %1$L = 2 then cfv.timestamp_value::text
              when %1$L = 3 then cfv.boolean_value::text
              when %1$L = 4 then cfv.numeric_value::text
              when %1$L = 5 or %1$L = 13 then cfv.text_value
              when %1$L = 6 and %2$L is true  then
                (select lov.name from brs.list_of_value lov where lov.id = cfv.int_value)
              when %1$L = 6 and %2$L is false then cfv.int_value::text
              when %1$L = 7 then
                (select array_agg(l.name)::text from brs.list_of_value l where l.id = any(cfv.int_array_value))
              when %1$L = 9 then cfv.int_value::text
            end,
            cfv.rich_text_value
          from brs.feat_db_ahj_design ad
          inner join brs.feat_db_ahj_design_custom_field_value cfv on cfv.ahj_design_id = ad.id
          where ad.ahj_id = (
            select ahj
            from %3$s
            where project_id = %4$L
          )
          and cfv.custom_field_group_assignment_id = %5$L
        $$,
           p_cfga_data_type_id,
           p_use_list_of_values,
           v_table_name,
           p_project_id,
           p_brs_feat_db_cfga_id
        );

    when lower(trim(p_brs_feat_db_table)) = 'permit' then

      v_sql := format($$
        select
          case
            when %1$L = 1 then cfv.date_value::text
            when %1$L = 2 then cfv.timestamp_value::text
            when %1$L = 3 then cfv.boolean_value::text
            when %1$L = 4 then cfv.numeric_value::text
            when %1$L = 5 or %1$L = 13 then cfv.text_value
            when %1$L = 6 and %2$L is true then
              (select lov.name from brs.list_of_value lov where lov.id = cfv.int_value)
            when %1$L = 6 and %2$L is false then
              cfv.int_value::text
            when %1$L = 7 then
              (select array_agg(l.name)::text from brs.list_of_value l where l.id = any(cfv.int_array_value))
            when %1$L = 9 then cfv.int_value::text
          end,
          cfv.rich_text_value
        from brs.feat_db_ahj_permit ad
             inner join brs.feat_db_ahj_permit_custom_field_value cfv on cfv.ahj_permit_id = ad.id
        where ad.ahj_id = (
          select ahj
          from %3$s
          where project_id = %4$L
        )
        and cfv.custom_field_group_assignment_id = %5$L
      $$,
      p_cfga_data_type_id,
      p_use_list_of_values,
        v_table_name,
        p_project_id,
        p_brs_feat_db_cfga_id
      );

    when lower(trim(p_brs_feat_db_table)) = 'inspection' then

      v_sql := format($$
        select
          case
            when %1$L = 1 then cfv.date_value::text
            when %1$L = 2 then cfv.timestamp_value::text
            when %1$L = 3 then cfv.boolean_value::text
            when %1$L = 4 then cfv.numeric_value::text
            when %1$L = 5 or %1$L = 13 then cfv.text_value
            when %1$L = 6 and %2$L is true then
              (select lov.name from brs.list_of_value lov where lov.id = cfv.int_value)
            when %1$L = 6 and %2$L is false then
              cfv.int_value::text
            when %1$L = 7 then
              (select array_agg(l.name)::text from brs.list_of_value l where l.id = any(cfv.int_array_value))
            when %1$L = 9 then cfv.int_value::text
          end,
          cfv.rich_text_value
        from brs.feat_db_ahj_inspection ad
               inner join brs.feat_db_ahj_inspection_custom_field_value cfv on cfv.ahj_inspection_id = ad.id
        where ad.ahj_id = (
          select ahj
          from %3$s
          where project_id = %4$L
        )
        and cfv.custom_field_group_assignment_id = %5$L
      $$,
        p_cfga_data_type_id,
        p_use_list_of_values,
        v_table_name,
        p_project_id,
        p_brs_feat_db_cfga_id
      );

   when lower(trim(p_brs_feat_db_table)) = 'utility' then

     v_sql := format($$
           select
             case
               when %1$L = 1 then cfv.date_value::text
               when %1$L = 2 then cfv.timestamp_value::text
               when %1$L = 3 then cfv.boolean_value::text
               when %1$L = 4 then cfv.numeric_value::text
               when %1$L = 5 or %1$L = 13 then cfv.text_value
               when %1$L = 6 and %2$L is true then
                 (select lov.name from brs.list_of_value lov where lov.id = cfv.int_value)
               when %1$L = 6 and %2$L is false then
                 cfv.int_value::text
               when %1$L = 7 then
                 (select array_agg(l.name)::text from brs.list_of_value l where l.id = any(cfv.int_array_value))
               when %1$L = 9 then cfv.int_value::text
             end,
             cfv.rich_text_value
           from brs.feat_db_utility ad
                inner join brs.feat_db_utility_custom_field_value cfv on cfv.utility_id = ad.id
           where ad.id = (
             select utility_company
             from %3$s
             where project_id = %4$L
           )
           and cfv.custom_field_group_assignment_id = %5$L
         $$,
          p_cfga_data_type_id,
           p_use_list_of_values,
           v_table_name,
           p_project_id,
    		p_brs_feat_db_cfga_id
         );

    return query execute v_sql;
  end case;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
