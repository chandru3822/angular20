 DROP FUNCTION IF EXISTS brs.get_brs_feat_db_value_for_copy(p_project_id bigint, p_brs_feat_db_table character varying, p_brs_feat_db_cfga_id bigint, p_cfga_data_type_id bigint, p_use_list_of_values boolean);
CREATE OR REPLACE FUNCTION brs.get_brs_feat_db_value_for_copy(p_project_id bigint, p_brs_feat_db_table character varying, p_brs_feat_db_cfga_id bigint, p_cfga_data_type_id bigint, p_use_list_of_values boolean)
--this is a very poorly named function...
returns table (value_as_text text, rich_text_value text)
AS
$BODY$

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
    case when lower(trim(p_brs_feat_db_table)) = 'design' then
        -- gets the selected value for the ahj custom field
        return query select
                       case when p_cfga_data_type_id = 1 then cfv.date_value::text
                            when p_cfga_data_type_id = 2 then cfv.timestamp_value::text
                            when p_cfga_data_type_id = 3 then cfv.boolean_value::text
                            when p_cfga_data_type_id = 4 then cfv.numeric_value::text
                            when p_cfga_data_type_id = 5 or p_cfga_data_type_id = 13 then cfv.text_value
                            when p_cfga_data_type_id = 6 and p_use_list_of_values is true then
                              (select lov.name from brs.list_of_value lov where lov.id = cfv.int_value)
                            when p_cfga_data_type_id = 6 and p_use_list_of_values is false then
                              cfv.int_value::text
                            when p_cfga_data_type_id = 7 then
                              (select array_agg(l.name)::text from brs.list_of_value l where l.id = any(cfv.int_array_value))
                        end,
                        cfv.rich_text_value
                from brs.feat_db_ahj_design ad
                 inner join brs.feat_db_ahj_design_custom_field_value cfv on cfv.ahj_design_id = ad.id
        where ad.ahj_id = (select ahj from brs.project_details pd where pd.project_id = p_project_id )
          and cfv.custom_field_group_assignment_id = p_brs_feat_db_cfga_id;

    when lower(trim(p_brs_feat_db_table)) = 'permit' then
      return query select
                case when p_cfga_data_type_id = 1 then cfv.date_value::text
                     when p_cfga_data_type_id = 2 then cfv.timestamp_value::text
                     when p_cfga_data_type_id = 3 then cfv.boolean_value::text
                     when p_cfga_data_type_id = 4 then cfv.numeric_value::text
                     when p_cfga_data_type_id = 5 or p_cfga_data_type_id = 13 then cfv.text_value
                     when p_cfga_data_type_id = 6 and p_use_list_of_values is true then
                       (select lov.name from brs.list_of_value lov where lov.id = cfv.int_value)
                     when p_cfga_data_type_id = 6 and p_use_list_of_values is false then
                       cfv.int_value::text
                     when p_cfga_data_type_id = 7 then
                       (select array_agg(l.name)::text from brs.list_of_value l where l.id = any(cfv.int_array_value))
                  end,
                cfv.rich_text_value
              from brs.feat_db_ahj_permit ad
                     inner join brs.feat_db_ahj_permit_custom_field_value cfv on cfv.ahj_permit_id = ad.id
              where ad.ahj_id = (select ahj from brs.project_details pd where pd.project_id = p_project_id )
                and cfv.custom_field_group_assignment_id = p_brs_feat_db_cfga_id;
    when lower(trim(p_brs_feat_db_table)) = 'inspection' then
      return query select
                case when p_cfga_data_type_id = 1 then cfv.date_value::text
                     when p_cfga_data_type_id = 2 then cfv.timestamp_value::text
                     when p_cfga_data_type_id = 3 then cfv.boolean_value::text
                     when p_cfga_data_type_id = 4 then cfv.numeric_value::text
                     when p_cfga_data_type_id = 5 or p_cfga_data_type_id = 13 then cfv.text_value
                     when p_cfga_data_type_id = 6 and p_use_list_of_values is true then
                       (select lov.name from brs.list_of_value lov where lov.id = cfv.int_value)
                     when p_cfga_data_type_id = 6 and p_use_list_of_values is false then
                       cfv.int_value::text
                     when p_cfga_data_type_id = 7 then
                       (select array_agg(l.name)::text from brs.list_of_value l where l.id = any(cfv.int_array_value))
                  end,
                cfv.rich_text_value
              from brs.feat_db_ahj_inspection ad
                     inner join brs.feat_db_ahj_inspection_custom_field_value cfv on cfv.ahj_inspection_id = ad.id
              where ad.ahj_id = (select ahj from brs.project_details pd where pd.project_id = p_project_id )
                and cfv.custom_field_group_assignment_id = p_brs_feat_db_cfga_id;
        when lower(trim(p_brs_feat_db_table)) = 'utility' then
          return query select
                    case when p_cfga_data_type_id = 1 then cfv.date_value::text
                         when p_cfga_data_type_id = 2 then cfv.timestamp_value::text
                         when p_cfga_data_type_id = 3 then cfv.boolean_value::text
                         when p_cfga_data_type_id = 4 then cfv.numeric_value::text
                         when p_cfga_data_type_id = 5 or p_cfga_data_type_id = 13 then cfv.text_value
                         when p_cfga_data_type_id = 6 and p_use_list_of_values is true then
                           (select lov.name from brs.list_of_value lov where lov.id = cfv.int_value)
                         when p_cfga_data_type_id = 6 and p_use_list_of_values is false then
                           cfv.int_value::text
                         when p_cfga_data_type_id = 7 then
                           (select array_agg(l.name)::text from brs.list_of_value l where l.id = any(cfv.int_array_value))
                      end,
                    cfv.rich_text_value
                  from brs.feat_db_utility ad
                         inner join brs.feat_db_utility_custom_field_value cfv on cfv.utility_id = ad.id
                  where ad.id = (select utility_company from brs.project_details pd where pd.project_id = p_project_id )
                    and cfv.custom_field_group_assignment_id = p_brs_feat_db_cfga_id;
    end case;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
