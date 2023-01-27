drop function if exists flow.get_cfgs_with_values(bigint, bigint, bigint, bigint, boolean, bigint[], boolean, boolean);
CREATE OR REPLACE FUNCTION flow.get_cfgs_with_values(p_object_type_id bigint,
                                           p_source_id bigint,
                                           p_secondary_id bigint,
                                           p_company_id bigint,
                                           p_is_system_admin boolean,
                                           p_user_position_ids bigint[],
                                           p_return_cfvs boolean,
                                           p_boolean_for_random_stuff boolean)
  RETURNS json as
$$
DECLARE
  v_json json;
BEGIN
--todo: figure out what to do with attachment type ancillary custom fields
--todo: would be nice if this could return cfgs with cfvs OR just cfvs (could replace getUserProfileFields if it could do that...and maybe more)

  drop table if exists cfvs;
  create temp table cfvs
  (
    id                                         bigint, --this is the id from the corresponding custom_field_value table(unless it is from the data view then it is the dvfc.id)
    project_id                                 bigint,
    contact_id                                 bigint,
    custom_field_group_assignment_id           bigint,
    custom_field_group_id                      bigint,
    custom_field_group_assignment_read_only    boolean,
    required                                   boolean,
    show_on_user_profile                       boolean,
    custom_field_group_assignment_hidden       boolean,
    ancillary_custom_field_group_assignment_id bigint,
    data_view_field_config_id                  bigint,
    custom_field_id                            bigint,
    field_order                                int,
    object_type_id                             int,
    use_parent_data                            boolean,
    ancillary_process_step_id                  bigint,
    ancillary_object_type_id                   bigint,
    ancillary_custom_field_hint                text,
    list_of_value_id                           bigint,
    field_name                                 text,
    allow_now                                  boolean,
    allow_select_self                          boolean,
    readonly                                   boolean,
    system_readonly                            boolean,
    sort_list_values_alphabetically            boolean,
    custom_field_sql                           text,
    custom_field_sql_key                       text,
    custom_field_sql_smartlist                 text,
    company_system_list_id                     bigint,
    system_list_option_ids                     bigint[],
    company_data_type_id                       bigint,
    data_type_id                               bigint,
    has_list_values                            boolean,
    list_of_values                             json,
    date_value                                 date,
    timestamp_value                            timestamp,
    boolean_value                              boolean,
    text_value                                 text,
    rich_text_value                            text,
    numeric_value                              numeric,
    int_value                                  bigint,
    int_array_value                            bigint[]
  );

  create index cfvs_cfga_id on cfvs (custom_field_group_assignment_id);
  create index cfvs_cfg_id on cfvs (custom_field_group_id);
  create index cfvs_cf_id on cfvs (custom_field_id);
  create index cfvs_dvfc_id on cfvs (data_view_field_config_id);
  create index cfvs_dt_id on cfvs (data_type_id);
  create index cfvs_cdt_id on cfvs (company_data_type_id);
  create index cfvs_csl_id on cfvs (company_system_list_id);
  create index cfvs_lov_id on cfvs (list_of_value_id);
  create index cfvs_project_id on cfvs (project_id);
  create index cfvs_contact_id on cfvs (contact_id);
  create index cfvs_cf_sql on cfvs (custom_field_sql);
  create index cfvs_ancillary_cfga_id on cfvs (ancillary_custom_field_group_assignment_id);

  --insert some basic info
  insert into cfvs(project_id, contact_id, custom_field_group_assignment_id, custom_field_group_id,
                   custom_field_group_assignment_read_only, required,
                   custom_field_group_assignment_hidden, ancillary_custom_field_group_assignment_id,
                   data_view_field_config_id,
                   custom_field_id, field_order, object_type_id, show_on_user_profile, use_parent_data, ancillary_process_step_id, ancillary_object_type_id,
                   ancillary_custom_field_hint, list_of_value_id, field_name, allow_now,
                   allow_select_self, readonly, system_readonly, sort_list_values_alphabetically, custom_field_sql,
                   custom_field_sql_key,
                   custom_field_sql_smartlist,
                   company_system_list_id, system_list_option_ids, company_data_type_id, data_type_id, has_list_values)
  select case
          when native_cot.object_type_id = 1 then p_source_id
          when native_cot.object_type_id = 4 then (select pps.project_id
                                                    from flow.project_process_step pps
                                                    where pps.id = p_source_id)
           when native_cot.object_type_id = 6 then (select pps.project_id
                                                    from flow.project_process_step_event ppse
                                                           inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
                                                    where ppse.id = p_source_id) end as project_id,
         case
           when native_cot.object_type_id = 1 then (select p.contact_id from flow.project p where p.id = p_source_id)
           when native_cot.object_type_id = 2 then p_source_id
           when native_cot.object_type_id = 4 then (select p.contact_id
                                                    from flow.project_process_step pps
                                                           inner join flow.project p on p.id = pps.project_id
                                                    where pps.id = p_source_id)
           when native_cot.object_type_id = 6 then (select p.contact_id
                                                    from flow.project_process_step_event ppse
                                                           inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
                                                           inner join flow.project p on p.id = pps.project_id
                                                    where ppse.id = p_source_id) end as contact_id,
         native_cfga.id                                                              as custom_field_group_assignment_id,
         native_cfga.custom_field_group_id,
         native_cfga.read_only                                                       as custom_field_group_assignment_read_only,
         native_cfga.required,
         native_cfga.hidden                                                          as custom_field_group_assignment_hidden,
         native_cfga.ancillary_custom_field_group_assignment_id,
         native_cfga.data_view_field_config_id,
         native_cfga.custom_field_id,
         native_cfga.field_order,
         native_cot.object_type_id,
         native_cfga.show_on_user_profile,
         native_cfga.use_parent_data,
         ancillary_cfg.process_step_id                                               as ancillary_process_step_id,
         ancillary_cot.object_type_id                                                as ancillary_object_type_id,
         case
           when ancillary_cot.object_type_id = 1 then '(Project)'
           when ancillary_cot.object_type_id = 2 then '(Contact)'
           when ancillary_cot.object_type_id = 4 and native_cfga.use_parent_data is false then '(Primary)'
           when ancillary_cot.object_type_id = 4 and native_cfga.use_parent_data is true then '(Parent)'
           else '' end
                                                                                     as ancillary_custom_field_hint,
         coalesce(native_cf.list_of_value_id, ancillary_cf.list_of_value_id)         as list_of_value_id,
         coalesce(native_cf.field_name, ancillary_cf.field_name)                     as field_name,
         coalesce(native_cf.allow_now, ancillary_cf.allow_now, false)                as allow_now,
         coalesce(native_cf.allow_select_self, ancillary_cf.allow_select_self,
                  false)                                                             as allow_select_self,
         case
           when coalesce(native_cf.system_readonly, ancillary_cf.system_readonly, false) is true
             then true
           else coalesce(native_cf.readonly, ancillary_cf.readonly, false) end       as readonly,
         coalesce(native_cf.system_readonly, ancillary_cf.system_readonly,
                  false)                                                             as system_readonly,
         coalesce(native_cf.sort_list_values_alphabetically, ancillary_cf.sort_list_values_alphabetically,
                  false)                                                             as sort_list_values_alphabetically,
         coalesce(native_cf.custom_field_sql, ancillary_cf.custom_field_sql)         as custom_field_sql,
         coalesce(native_cf.custom_field_sql_key, ancillary_cf.custom_field_sql_key) as custom_field_sql_key,
         coalesce(native_cf.custom_field_sql_smartlist,
                  ancillary_cf.custom_field_sql_smartlist)                           as custom_field_sql_smartlist,
         coalesce(native_cf.company_system_list_id,
                  ancillary_cf.company_system_list_id)                               as company_system_list_id,
         coalesce(native_cf.system_list_option_ids,
                  ancillary_cf.system_list_option_ids)                               as system_list_option_ids,
         coalesce(native_cf.company_data_type_id,
                  ancillary_cf.company_data_type_id)                                 as company_data_type_id,
         coalesce(native_cdt.data_type_id, ancillary_cdt.data_type_id)               as data_type_id,
         coalesce(native_cdt.has_list_values, ancillary_cdt.has_list_values, false)  as has_list_values

  from flow.custom_field_group_assignment native_cfga
         inner join flow.custom_field_group native_cfg
                    on native_cfg.id = native_cfga.custom_field_group_id and native_cfg.archived is false
         inner join flow.company_object_type native_cot on native_cot.id = native_cfg.company_object_type_id
         left join flow.custom_field_group_assignment ancillary_cfga
                   on ancillary_cfga.id = native_cfga.ancillary_custom_field_group_assignment_id and
                      ancillary_cfga.archived is false
         left join flow.custom_field native_cf
                   on native_cf.id = native_cfga.custom_field_id and native_cf.archived is false
         left join flow.company_data_type native_cdt on native_cdt.id = native_cf.company_data_type_id
         left join flow.custom_field ancillary_cf
                   on ancillary_cf.id = ancillary_cfga.custom_field_id and ancillary_cf.archived is false
         left join flow.company_data_type ancillary_cdt on ancillary_cdt.id = ancillary_cf.company_data_type_id
         left join flow.custom_field_group ancillary_cfg on ancillary_cfg.id = ancillary_cfga.custom_field_group_id
         left join flow.company_object_type ancillary_cot on ancillary_cot.id = ancillary_cfg.company_object_type_id
  where native_cfga.archived is false
    and native_cot.company_id = p_company_id
    and case
          when p_object_type_id = 1 then native_cot.object_type_id = 1
          when p_object_type_id = 2 then native_cot.object_type_id = 2
          when p_object_type_id = 3 then native_cot.object_type_id = 3
          when p_object_type_id = 4 then (native_cot.object_type_id = 4 and native_cfg.process_step_id =
                                                                            (select process_step_id
                                                                             from flow.project_process_step p
                                                                             where id = p_source_id))
          when p_object_type_id = 5 then native_cot.object_type_id = 5
          when p_object_type_id = 6 then (native_cot.object_type_id = 6 and native_cfg.event_id = (select pse.event_id
                                                                                                   from flow.project_process_step_event ppse
                                                                                                          inner join flow.process_step_event pse on pse.id = ppse.process_step_event_id
                                                                                                   where ppse.id = p_source_id))
          when p_object_type_id = 7 then native_cot.object_type_id = 7 and native_cfg.attachment_type_id = p_source_id end;

  if p_object_type_id = 1 then --project
    --update the native rows
    update cfvs new_data
    set id              = pcfv.id,
        date_value      = pcfv.date_value,
        timestamp_value = pcfv.timestamp_value,
        boolean_value   = pcfv.boolean_value,
        text_value      = pcfv.text_value,
        rich_text_value = pcfv.rich_text_value,
        numeric_value   = pcfv.numeric_value,
        int_value       = pcfv.int_value,
        int_array_value = pcfv.int_array_value
    from flow.project_custom_field_value pcfv
    where pcfv.custom_field_group_assignment_id = new_data.custom_field_group_assignment_id
      and pcfv.project_id = p_source_id
      and (new_data.custom_field_id is not null and new_data.ancillary_custom_field_group_assignment_id is null);

    --update the ancillary rows
    update cfvs new_data
    set id              = ancillary_ppscfv.id,
        date_value      = ancillary_ppscfv.date_value,
        timestamp_value = ancillary_ppscfv.timestamp_value,
        boolean_value   = ancillary_ppscfv.boolean_value,
        text_value      = ancillary_ppscfv.text_value,
        rich_text_value = ancillary_ppscfv.rich_text_value,
        numeric_value   = ancillary_ppscfv.numeric_value,
        int_value       = ancillary_ppscfv.int_value,
        int_array_value = ancillary_ppscfv.int_array_value
    from cfvs original_rows
           inner join flow.project_process_step ancillary_process_step on ancillary_process_step.process_step_id = original_rows.ancillary_process_step_id and ancillary_process_step.project_id = p_source_id and ancillary_process_step.main is true
           inner join flow.project_process_step_custom_field_value ancillary_ppscfv on ancillary_ppscfv.project_process_step_id = ancillary_process_step.id and ancillary_ppscfv.custom_field_group_assignment_id = original_rows.ancillary_custom_field_group_assignment_id
    where original_rows.custom_field_group_assignment_id = new_data.custom_field_group_assignment_id
      and original_rows.ancillary_custom_field_group_assignment_id is not null;
  elseif p_object_type_id = 2 then --contact
     --update the native rows (contacts dont have ancillary
    update cfvs new_data
    set id              = ccfv.id,
        date_value      = ccfv.date_value,
        timestamp_value = ccfv.timestamp_value,
        boolean_value   = ccfv.boolean_value,
        text_value      = ccfv.text_value,
        rich_text_value = ccfv.rich_text_value,
        numeric_value   = ccfv.numeric_value,
        int_value       = ccfv.int_value,
        int_array_value = ccfv.int_array_value
    from flow.contact_custom_field_value ccfv
    where ccfv.custom_field_group_assignment_id = new_data.custom_field_group_assignment_id
      and ccfv.contact_id = p_source_id
      and (new_data.custom_field_id is not null and new_data.ancillary_custom_field_group_assignment_id is null);
  elseif p_object_type_id = 3 then --user
  --update the native rows (users dont have ancillary
    update cfvs new_data
    set id              = ucfv.id,
        date_value      = ucfv.date_value,
        timestamp_value = ucfv.timestamp_value,
        boolean_value   = ucfv.boolean_value,
        text_value      = ucfv.text_value,
        rich_text_value = ucfv.rich_text_value,
        numeric_value   = ucfv.numeric_value,
        int_value       = ucfv.int_value,
        int_array_value = ucfv.int_array_value
    from flow.user_custom_field_value ucfv
    where ucfv.custom_field_group_assignment_id = new_data.custom_field_group_assignment_id
      and ucfv.user_id = p_source_id
      and (new_data.custom_field_id is not null and new_data.ancillary_custom_field_group_assignment_id is null);
  elseif p_object_type_id = 5 then --org
  --update the native rows (users dont have ancillary
    update cfvs new_data
    set id              = ocfv.id,
        date_value      = ocfv.date_value,
        timestamp_value = ocfv.timestamp_value,
        boolean_value   = ocfv.boolean_value,
        text_value      = ocfv.text_value,
        rich_text_value = ocfv.rich_text_value,
        numeric_value   = ocfv.numeric_value,
        int_value       = ocfv.int_value,
        int_array_value = ocfv.int_array_value
    from flow.organization_custom_field_value ocfv
    where ocfv.custom_field_group_assignment_id = new_data.custom_field_group_assignment_id
      and ocfv.org_id = p_source_id
      and (new_data.custom_field_id is not null and new_data.ancillary_custom_field_group_assignment_id is null);
  elseif p_object_type_id = 4 then --project_process_step
--     --update the native rows
    update cfvs new_data
    set id              = ppscfv.id,
        date_value      = ppscfv.date_value,
        timestamp_value = ppscfv.timestamp_value,
        boolean_value   = ppscfv.boolean_value,
        text_value      = ppscfv.text_value,
        rich_text_value = ppscfv.rich_text_value,
        numeric_value   = ppscfv.numeric_value,
        int_value       = ppscfv.int_value,
        int_array_value = ppscfv.int_array_value
    from flow.project_process_step_custom_field_value ppscfv
    where ppscfv.custom_field_group_assignment_id = new_data.custom_field_group_assignment_id
      and ppscfv.project_process_step_id = p_source_id
      and (new_data.custom_field_id is not null and new_data.ancillary_custom_field_group_assignment_id is null);

--     --update the ancillary rows
    update cfvs new_data
    set id              = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.id
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.id
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.id end,
        date_value      = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.date_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.date_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.date_value end,
        timestamp_value = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.timestamp_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.timestamp_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.timestamp_value end,
        boolean_value   = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.boolean_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.boolean_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.boolean_value end,
        text_value      = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.text_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.text_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.text_value end,
        rich_text_value = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.rich_text_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.rich_text_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.rich_text_value end,
        numeric_value   = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.numeric_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.numeric_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.numeric_value end,
        int_value       = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.int_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.int_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.int_value end,
        int_array_value = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.int_array_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.int_array_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.int_array_value end
    from cfvs original_rows
           left join flow.project_process_step ancillary_pps on ancillary_pps.project_id = original_rows.project_id and
                                                                ancillary_pps.process_step_id =
                                                                original_rows.ancillary_process_step_id and
                                                                ancillary_pps.archived is false
      and case
            when original_rows.use_parent_data is true then ancillary_pps.id = (select id
                                                                                from flow.pps_parent_hierarchy(
                                                                                  p_source_id,
                                                                                  original_rows.ancillary_custom_field_group_assignment_id))
            else ancillary_pps.main is true end
           left join flow.project_process_step_custom_field_value ancillary_ppscfv
                     on ancillary_ppscfv.custom_field_group_assignment_id =
                        original_rows.ancillary_custom_field_group_assignment_id and
                        ancillary_ppscfv.project_process_step_id = ancillary_pps.id
           left join flow.project_custom_field_value ancillary_project_cfv
                     on ancillary_project_cfv.custom_field_group_assignment_id =
                        original_rows.ancillary_custom_field_group_assignment_id and
                        ancillary_project_cfv.project_id = original_rows.project_id
           left join flow.contact_custom_field_value ancillary_contact_cfv
                     on ancillary_contact_cfv.custom_field_group_assignment_id =
                        original_rows.ancillary_custom_field_group_assignment_id and
                        ancillary_contact_cfv.contact_id = original_rows.contact_id
    where original_rows.custom_field_group_assignment_id = new_data.custom_field_group_assignment_id
      and original_rows.ancillary_custom_field_group_assignment_id is not null;
  elseif p_object_type_id = 6 then --project_process_step_event
--     --update the native rows
    update cfvs new_data
    set id              = ppsecfv.id,
        date_value      = ppsecfv.date_value,
        timestamp_value = ppsecfv.timestamp_value,
        boolean_value   = ppsecfv.boolean_value,
        text_value      = ppsecfv.text_value,
        rich_text_value = ppsecfv.rich_text_value,
        numeric_value   = ppsecfv.numeric_value,
        int_value       = ppsecfv.int_value,
        int_array_value = ppsecfv.int_array_value
    from flow.project_process_step_event_custom_field_value ppsecfv
    where ppsecfv.custom_field_group_assignment_id = new_data.custom_field_group_assignment_id
      and ppsecfv.project_process_step_event_id = p_source_id
      and (new_data.custom_field_id is not null and new_data.ancillary_custom_field_group_assignment_id is null);

--     --update the ancillary rows
    update cfvs new_data
    set id              = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.id
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.id
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.id end,
        date_value      = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.date_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.date_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.date_value end,
        timestamp_value = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.timestamp_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.timestamp_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.timestamp_value end,
        boolean_value   = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.boolean_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.boolean_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.boolean_value end,
        text_value      = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.text_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.text_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.text_value end,
        rich_text_value = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.rich_text_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.rich_text_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.rich_text_value end,
        numeric_value   = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.numeric_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.numeric_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.numeric_value end,
        int_value       = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.int_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.int_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.int_value end,
        int_array_value = case
                            when original_rows.ancillary_object_type_id = 1 then ancillary_project_cfv.int_array_value
                            when original_rows.ancillary_object_type_id = 2 then ancillary_contact_cfv.int_array_value
                            when original_rows.ancillary_object_type_id = 4 then ancillary_ppscfv.int_array_value end
    from cfvs original_rows
           left join flow.project_process_step ancillary_pps on ancillary_pps.process_step_id = original_rows.ancillary_process_step_id and ancillary_pps.project_id = original_rows.project_id
           left join flow.project_process_step_custom_field_value ancillary_ppscfv on ancillary_ppscfv.custom_field_group_assignment_id = original_rows.ancillary_custom_field_group_assignment_id and ancillary_ppscfv.project_process_step_id = ancillary_pps.id
           left join flow.project_custom_field_value ancillary_project_cfv on ancillary_project_cfv.custom_field_group_assignment_id = original_rows.ancillary_custom_field_group_assignment_id and ancillary_project_cfv.project_id = original_rows.project_id
           left join flow.contact_custom_field_value ancillary_contact_cfv on ancillary_contact_cfv.custom_field_group_assignment_id = original_rows.ancillary_custom_field_group_assignment_id and ancillary_contact_cfv.contact_id = original_rows.contact_id
    where original_rows.custom_field_group_assignment_id = new_data.custom_field_group_assignment_id
      and original_rows.ancillary_custom_field_group_assignment_id is not null;
  elseif p_object_type_id = 7 then --attachments
  --update the native rows
    update cfvs new_data
    set id              = acfv.id,
        date_value      = acfv.date_value,
        timestamp_value = acfv.timestamp_value,
        boolean_value   = acfv.boolean_value,
        text_value      = acfv.text_value,
        rich_text_value = acfv.rich_text_value,
        numeric_value   = acfv.numeric_value,
        int_value       = acfv.int_value,
        int_array_value = acfv.int_array_value
    from flow.attachment_custom_field_value acfv
    where acfv.custom_field_group_assignment_id = new_data.custom_field_group_assignment_id
      and acfv.attachment_id = p_secondary_id
      and (new_data.custom_field_id is not null and new_data.ancillary_custom_field_group_assignment_id is null);
  end if;

  if (p_object_type_id = 4 or p_object_type_id = 6 or p_object_type_id = 1) then
    --update the data view rows
    --these can all be handled the same way for any object type that knows its "project_id", (pps 4, ppsEvent 6, project 1)
    update cfvs new_data
    set id = dvfc.id,
        --this is dumb but if i don't do this then i think mobile will break
        ancillary_custom_field_group_assignment_id = dvfc.id,
        readonly = true,
        system_readonly = true,
        company_data_type_id = cf.company_data_type_id,
        data_type_id = coalesce(df.data_type_id, cdt.data_type_id),
        field_name = dvfc.display_name,
        date_value      = case
                            when coalesce(df.data_type_id, cdt.data_type_id) = 1 then (select *
                                                                                       from flow.get_value_for_data_view_field(dvfc.id, new_data.project_id))::date
                            else null::date end,
        timestamp_value = case
                            when coalesce(df.data_type_id, cdt.data_type_id) = 2 then (select *
                                                                                       from flow.get_value_for_data_view_field(dvfc.id, new_data.project_id))::timestamp
                            else null::timestamp end,
        boolean_value   = case
                            when coalesce(df.data_type_id, cdt.data_type_id) = 3 then (select *
                                                                                       from flow.get_value_for_data_view_field(dvfc.id, new_data.project_id))::boolean
                            else null::boolean end,
        text_value      = case
                            when coalesce(df.data_type_id, cdt.data_type_id) = 5 then (select *
                                                                                       from flow.get_value_for_data_view_field(dvfc.id, new_data.project_id))::text
                            else null::text end,
        rich_text_value = case
                            when coalesce(df.data_type_id, cdt.data_type_id) = 13 then (select *
                                                                                        from flow.get_value_for_data_view_field(dvfc.id, new_data.project_id))::text
                            else null::text end,
        numeric_value   = case
                            when coalesce(df.data_type_id, cdt.data_type_id) = 4 then (select *
                                                                                       from flow.get_value_for_data_view_field(dvfc.id, new_data.project_id))::numeric
                            else null::numeric end,
        int_value       = case
                            when coalesce(df.data_type_id, cdt.data_type_id) = 6 then (select *
                                                                                       from flow.get_value_for_data_view_field(dvfc.id, new_data.project_id))::int
                            else null::int end,
        int_array_value = case
                            when coalesce(df.data_type_id, cdt.data_type_id) = 7 then (select *
                                                                                       from flow.get_value_for_data_view_field(dvfc.id, new_data.project_id))::int[]
                            else null::int[] end
    from flow.data_view_field_config dvfc
           left join flow.default_field df on df.id = dvfc.default_field_id
           left join flow.custom_field_group_assignment cfga_dv on cfga_dv.id = dvfc.custom_field_group_assignment_id
           left join flow.custom_field cf on cf.id = cfga_dv.custom_field_id
           left join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
    where dvfc.id = new_data.data_view_field_config_id
      and new_data.data_view_field_config_id is not null;
  end if;

  --this has to be done after the values are populated because company system lists include the selected value even if it would otherwise be excluded
  --handle custom sql or list of values
  update cfvs
    --set list of values to true if a system list or if it is a non-id 12 custom field sql
  set has_list_values = case
                          when has_list_values is false then (cfvs.company_system_list_id is not null or
                                                              (cfvs.custom_field_sql is not null and cfvs.data_type_id != 12))
                          else has_list_values end,
      text_value      = case
                          when cfvs.custom_field_sql is not null and (cfvs.system_readonly OR cfvs.data_type_id = 12)
                            then
                            (select *
                             from flow.get_custom_sql_text_value(cfvs.custom_field_sql::text, false, p_company_id,cfvs.project_id::bigint, case when p_object_type_id = 4 then p_source_id else null end))
                          else text_value end,
      list_of_values  = case
                          when ((cfvs.company_system_list_id is not null) OR (cfvs.custom_field_sql is not null and cfvs.system_readonly is not true and cfvs.data_type_id != 12)) then
                            (select flow.get_custom_list_json(cfvs.custom_field_sql::text, p_company_id,
                                                              cfvs.company_system_list_id,
                                                              cfvs.system_list_option_ids, cfvs.int_value,
                                                              cfvs.project_id::bigint)::json)
                          else list_of_values end
  where (cfvs.company_system_list_id is not null or cfvs.custom_field_sql is not null);

  if(p_return_cfvs) then
    SELECT array_to_json(array_agg(row_to_json(sub_rows)))
    INTO v_json
    FROM (
           select cfvs.id,
                  cfvs.ancillary_custom_field_hint                as "ancillaryCustomFieldHint",
                  cfvs.date_value                                 as "dateValue",
                  cfvs.timestamp_value                            as "timestampValue",
                  cfvs.boolean_value                              as "booleanValue",
                  cfvs.text_value                                 as "textValue",
                  cfvs.rich_text_value                            as "richTextValue",
                  cfvs.numeric_value                              as "numericValue",
                  cfvs.int_value                                  as "intValue",
                  cfvs.int_array_value                            as "intArrayValue",
                  cfvs.custom_field_group_id                      as "customFieldGroupId",
                  cfvs.custom_field_group_assignment_id           as "customFieldGroupAssignmentId",
                  cfvs.custom_field_group_assignment_read_only    as "customFieldGroupAssignmentReadOnly",
                  cfvs.required,
                  cfvs.custom_field_group_assignment_hidden       as "customFieldGroupAssignmentHidden",
                  cfvs.ancillary_custom_field_group_assignment_id as "ancillaryCustomFieldGroupAssignmentId",
                  cfvs.data_view_field_config_id                  as "dataViewFieldConfigId",
                  cfvs.custom_field_id                            as "customFieldId",
                  cfvs.field_order                                as "fieldOrder",
                  cfvs.use_parent_data                            as "useParentData",
                  cfvs.list_of_value_id                           as "listOfValueId",
                  cfvs.field_name                                 as "fieldName",
                  cfvs.allow_now                                  as "allowNow",
                  cfvs.allow_select_self                          as "allowSelectSelf",
                  cfvs.readonly,
                  cfvs.system_readonly                            as "systemReadonly",
                  cfvs.sort_list_values_alphabetically            as "sortListValuesAlphabetically",
                  cfvs.custom_field_sql                           as "customFieldSql",
                  cfvs.custom_field_sql_key                       as "customFieldSqlKey",
                  cfvs.custom_field_sql_smartlist                 as "customFieldSqlSmartlist",
                  cfvs.company_system_list_id                     as "companySystemListId",
                  cfvs.system_list_option_ids                     as "systemListOptionIds",
                  cfvs.company_data_type_id                       as "companyDataTypeId",
                  cfvs.data_type_id                               as "dataTypeId",
                  cfvs.has_list_values                            as "hasListValues",
                  case
                    when cfvs.has_list_values and cfvs.list_of_values is null then
                      coalesce((SELECT array_to_json(array_agg(row_to_json(listOfValues)))
                                FROM (select lov.id,
                                             lov.name,
                                             lov.code,
                                             lov.parent_id as "parentId",
                                             lov.display_order as "displayOrder",
                                             lov.archived
                                      from flow.list_of_value lov
                                      where lov.parent_id is not null
                                        and lov.parent_id = cfvs.list_of_value_id
                                        and (lov.archived is not true OR
                                             (lov.archived is true AND (lov.id = cfvs.int_value
                                               OR lov.id = any (cfvs.int_array_value))))
                                      order by case when cfvs.sort_list_values_alphabetically is true then lov.name end,
                                               case
                                                 when cfvs.sort_list_values_alphabetically is false
                                                   then lov.display_order end) listOfValues),
                               '[]')
                    else cfvs.list_of_values end                  AS "listOfValues",
                  coalesce((SELECT array_to_json(array_agg(row_to_json(wlp)))
                            FROM (SELECT wlp.id,
                                         wlp.position_id                      as "positionId",
                                         wlp.custom_field_group_assignment_id as "custom_field_group_assignment_id",
                                         wlp.created_by_id                    as "createdById",
                                         wlp.modified_by_id                   as "modifiedById",
                                         wlp.archived
                                  FROM flow.white_listed_position wlp
                                  WHERE wlp.custom_field_group_assignment_id =
                                        cfvs.custom_field_group_assignment_id
                                    AND wlp.white_list_type_id = 1
                                    AND wlp.archived is not true) wlp),
                           '[]')                                  AS "whiteListedPositions"
           from cfvs
           where cfvs.object_type_id = p_object_type_id::bigint
             and case when p_object_type_id::bigint = 3 and p_boolean_for_random_stuff::boolean is true
                              then cfvs.show_on_user_profile is true else true end
             and case
                   when cfvs.custom_field_group_assignment_hidden and
                        p_is_system_admin::boolean is false
                     then cfvs.custom_field_group_assignment_id =
                          (select wlp2.custom_field_group_assignment_id
                           from flow.white_listed_position wlp2
                           where wlp2.custom_field_group_assignment_id =
                                 cfvs.custom_field_group_assignment_id
                             and wlp2.white_list_type_id = 2
                             and wlp2.archived is not true
                             and wlp2.position_id = any (p_user_position_ids::bigint[])
                           limit 1)
                   else 1 = 1 end
           order by field_order, field_name
         ) as sub_rows;
  else
  SELECT array_to_json(array_agg(row_to_json(sub_rows)))
  INTO v_json
  FROM (select cfg.id,
               cfg.group_name                                                   as "groupName",
               cfg.company_object_type_tab_id                                   as "companyObjectTypeTabId",
               cfg.group_order                                                  as "groupOrder",
               cfg.event_id                                                     as "eventId",
               cfg.unique_behavior_type_id                                      as "uniqueBehaviorTypeId",
               cfg.process_step_id,
--                pps.parent_project_process_step_id,  --todo: are these needed. they came from process step query
               coalesce((SELECT array_to_json(array_agg(row_to_json(fields)))
                         FROM (select cfvs.id,
                                      cfvs.ancillary_custom_field_hint                as "ancillaryCustomFieldHint",
                                      cfvs.date_value                                 as "dateValue",
                                      cfvs.timestamp_value                            as "timestampValue",
                                      cfvs.boolean_value                              as "booleanValue",
                                      cfvs.text_value                                 as "textValue",
                                      cfvs.rich_text_value                            as "richTextValue",
                                      cfvs.numeric_value                              as "numericValue",
                                      cfvs.int_value                                  as "intValue",
                                      cfvs.int_array_value                            as "intArrayValue",
                                      cfvs.custom_field_group_id                      as "customFieldGroupId",
                                      cfvs.custom_field_group_assignment_id           as "customFieldGroupAssignmentId",
                                      cfvs.custom_field_group_assignment_read_only    as "customFieldGroupAssignmentReadOnly",
                                      cfvs.required,
                                      cfvs.custom_field_group_assignment_hidden       as "customFieldGroupAssignmentHidden",
                                      cfvs.ancillary_custom_field_group_assignment_id as "ancillaryCustomFieldGroupAssignmentId",
                                      cfvs.data_view_field_config_id                  as "dataViewFieldConfigId",
                                      cfvs.custom_field_id                            as "customFieldId",
                                      cfvs.field_order                                as "fieldOrder",
                                      cfvs.use_parent_data                            as "useParentData",
                                      cfvs.list_of_value_id                           as "listOfValueId",
                                      cfvs.field_name                                 as "fieldName",
                                      cfvs.allow_now                                  as "allowNow",
                                      cfvs.allow_select_self                          as "allowSelectSelf",
                                      cfvs.readonly,
                                      cfvs.system_readonly                            as "systemReadonly",
                                      cfvs.sort_list_values_alphabetically            as "sortListValuesAlphabetically",
                                      cfvs.custom_field_sql                           as "customFieldSql",
                                      cfvs.custom_field_sql_key                       as "customFieldSqlKey",
                                      cfvs.custom_field_sql_smartlist                 as "customFieldSqlSmartlist",
                                      cfvs.company_system_list_id                     as "companySystemListId",
                                      cfvs.system_list_option_ids                     as "systemListOptionIds",
                                      cfvs.company_data_type_id                       as "companyDataTypeId",
                                      cfvs.data_type_id                               as "dataTypeId",
                                      cfvs.has_list_values                            as "hasListValues",
                                      case
                                        when cfvs.has_list_values and cfvs.list_of_values is null then
                                          coalesce((SELECT array_to_json(array_agg(row_to_json(listOfValues)))
                                                    FROM (select lov.id,
                                                                 lov.name,
                                                                 lov.code,
                                                                 lov.parent_id,
                                                                 lov.display_order,
                                                                 lov.archived
                                                          from flow.list_of_value lov
                                                          where lov.parent_id is not null
                                                            and lov.parent_id = cfvs.list_of_value_id
                                                            and (lov.archived is not true OR
                                                                 (lov.archived is true AND (lov.id = cfvs.int_value
                                                                   OR lov.id = any (cfvs.int_array_value))))
                                                          order by case when cfvs.sort_list_values_alphabetically is true then lov.name end,
                                                                   case
                                                                     when cfvs.sort_list_values_alphabetically is false
                                                                       then lov.display_order end) listOfValues),
                                                   '[]')
                                        else cfvs.list_of_values end                  AS "listOfValues",
                                      coalesce((SELECT array_to_json(array_agg(row_to_json(wlp)))
                                                FROM (SELECT wlp.id,
                                                             wlp.position_id                      as "positionId",
                                                             wlp.custom_field_group_assignment_id as "custom_field_group_assignment_id",
                                                             wlp.created_by_id                    as "createdById",
                                                             wlp.modified_by_id                   as "modifiedById",
                                                             wlp.archived
                                                      FROM flow.white_listed_position wlp
                                                      WHERE wlp.custom_field_group_assignment_id =
                                                            cfvs.custom_field_group_assignment_id
                                                        AND wlp.white_list_type_id = 1
                                                        AND wlp.archived is not true) wlp),
                                               '[]')                                  AS "whiteListedPositions"
                               from cfvs
                               where cfvs.custom_field_group_id = cfg.id
                                 and case
                                       when cfvs.custom_field_group_assignment_hidden and
                                            p_is_system_admin::boolean is false
                                         then cfvs.custom_field_group_assignment_id =
                                              (select wlp2.custom_field_group_assignment_id
                                               from flow.white_listed_position wlp2
                                               where wlp2.custom_field_group_assignment_id =
                                                     cfvs.custom_field_group_assignment_id
                                                 and wlp2.white_list_type_id = 2
                                                 and wlp2.archived is not true
                                                 and wlp2.position_id = any (p_user_position_ids::bigint[])
                                               limit 1)
                                       else 1 = 1 end
                               order by field_order, field_name) fields), '[]') AS "customFieldValues"
        from flow.custom_field_group cfg
               inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
        where cot.object_type_id = p_object_type_id
          and cfg.archived is false
          and case
                when p_object_type_id = 4 then cfg.process_step_id = (select pps.process_step_id
                                                                      from flow.project_process_step pps
                                                                      where pps.id = p_source_id)
                when p_object_type_id = 6 then cfg.event_id = (select pse.event_id
                                                               from flow.project_process_step_event ppse
                                                                      inner join flow.process_step_event pse on pse.id = ppse.process_step_event_id
                                                               where ppse.id = p_source_id)
                when p_object_type_id = 7 then cfg.attachment_type_id = p_source_id
            else true
            end
          and cot.company_id = p_company_id
        order by cfg.group_order) as sub_rows;
end if;

  drop table if exists cfvs;
  return v_json;

END;

$$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
