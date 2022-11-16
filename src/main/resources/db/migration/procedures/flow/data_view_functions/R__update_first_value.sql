drop function if exists flow.update_first_value(p_field_to_update character varying,
                                                p_update_first_value_only_id character varying,
                                                p_secondary_field_to_update text,
                                                p_secondary_value text,
                                                p_where_clause_condition_ids text);
CREATE OR REPLACE FUNCTION flow.update_first_value(p_field_to_update character varying,
                                                   p_update_first_value_only_id character varying,
                                                   p_secondary_field_to_update text,
                                                   p_secondary_value text,
                                                   p_where_clause_condition_ids text)
  RETURNS void
AS
$BODY$
declare
  v_project_process_step_custom_field_value       boolean;
  v_pps_dt_id                                     bigint;
  v_pps_id                                        bigint;
  v_pps_value                                     text;
  v_prepared_value                                text;
  v_project_process_step_event_custom_field_value boolean;
  v_ppse_dt_id                                    bigint;
  v_ppse_value                                    text;
  v_project_id                                    bigint;
  v_sql                                           text;
  v_where_clause_condition_ids                    text;
  v_pps_cfga_ids                                  bigint[];
  v_ppse_cfga_ids                                 bigint[];
BEGIN
  select replace(p_where_clause_condition_ids, $$'$$, '')
  into v_where_clause_condition_ids;

  select true, dt.id, array_agg(cfga.id)
  into v_project_process_step_custom_field_value,v_pps_dt_id,v_pps_cfga_ids
  from flow.data_view_field_config dvfc
         inner join flow.custom_field_group_assignment cfga on cfga.id = dvfc.custom_field_group_assignment_id
         inner join flow.custom_field cf on cf.id = cfga.custom_field_id
         inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
         inner join flow.data_type dt on dt.id = cdt.data_type_id
  where dvfc.field_to_update = p_field_to_update
    and dvfc.custom_field_group_assignment_id is not null
    and dvfc.process_step_id is not null
  group by 1, 2;

  select true, dt.id, array_agg(cfga.id)
  into v_project_process_step_event_custom_field_value,v_ppse_dt_id,v_ppse_cfga_ids
  from flow.data_view_field_config dvfc
         inner join flow.custom_field_group_assignment cfga on cfga.id = dvfc.custom_field_group_assignment_id
         inner join flow.custom_field cf on cf.id = cfga.custom_field_id
         inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
         inner join flow.data_type dt on dt.id = cdt.data_type_id
  where dvfc.field_to_update = p_field_to_update
    and dvfc.custom_field_group_assignment_id is not null
    and dvfc.process_step_event_id is not null
  group by 1, 2;


  if v_project_process_step_custom_field_value is true then
    select distinct on (project_id) project_id,
                                    ppscfv.id,
                                    case
                                      when v_pps_dt_id = 1 then
                                        ppscfv.date_value::text
                                      when v_pps_dt_id = 2 then
                                        ppscfv.timestamp_value::text
                                      when v_pps_dt_id = 3 then
                                        ppscfv.boolean_value::text
                                      when v_pps_dt_id = 4 then
                                        ppscfv.numeric_value::text
                                      when v_pps_dt_id = 5 then
                                        ppscfv.text_value::text
                                      when v_pps_dt_id in (6, 8, 9) then
                                        ppscfv.int_value::text
                                      when v_pps_dt_id in (7, 10) then
                                        ppscfv.int_array_value::text end
    into v_project_id,v_pps_id,v_pps_value
    from flow.project_process_step_custom_field_value ppscfv
           inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id
    where pps.project_id = any (v_where_clause_condition_ids::bigint[])
      and ppscfv.custom_field_group_assignment_id = any (v_pps_cfga_ids)
      and case
            when v_pps_dt_id = 1 then
              ppscfv.date_value is not null
            when v_pps_dt_id = 2 then
              ppscfv.timestamp_value is not null
            when v_pps_dt_id = 3 then
              ppscfv.boolean_value is not null
            when v_pps_dt_id = 4 then
              ppscfv.numeric_value is not null
            when v_pps_dt_id = 5 then
              ppscfv.text_value is not null
            when v_pps_dt_id in (6, 8, 9) then
              ppscfv.int_value is not null
            when v_pps_dt_id in (7, 10) then
              ppscfv.int_array_value is not null
      end
    order by project_id, ppscfv.date_created asc
    limit 1;
    if v_pps_value is not null then
      select flow.get_prepared_value(v_pps_dt_id, v_pps_value)
      into v_prepared_value;

      if p_secondary_field_to_update is null and p_secondary_value is null then
        v_sql = $$update brs.project_details pd
              set $$ || p_field_to_update || $$ = $$ || v_prepared_value || $$,$$ ||
                p_update_first_value_only_id || $$ = $$ || v_pps_id || $$
                 where pd.project_id = any($$ || p_where_clause_condition_ids::text || $$);$$;
      else
        v_sql = $$update brs.project_details pd
              set $$ || p_field_to_update || $$ = $$ || v_prepared_value || $$,$$ ||
                p_update_first_value_only_id || $$ = $$ || v_pps_id || $$,$$ ||
                p_secondary_field_to_update || $$ = $$ || p_secondary_value || $$
                 where pd.project_id = any($$ || p_where_clause_condition_ids::text || $$);$$;
      end if;
      begin
        execute v_sql;
      exception
        when others then
          insert into flow.trigger_error(project_process_step_custom_value_id, error)
          values (v_pps_id, SQLERRM);
      end;
    end if;
  elsif v_project_process_step_event_custom_field_value is true then
    select distinct on (project_id) project_id,
                                    ppsecfv.id,
                                    case
                                      when v_ppse_dt_id = 1 then
                                        ppsecfv.date_value::text
                                      when v_ppse_dt_id = 2 then
                                        ppsecfv.timestamp_value::text
                                      when v_ppse_dt_id = 3 then
                                        ppsecfv.boolean_value::text
                                      when v_ppse_dt_id = 4 then
                                        ppsecfv.numeric_value::text
                                      when v_ppse_dt_id = 5 then
                                        ppsecfv.text_value::text
                                      when v_ppse_dt_id in (6, 8, 9) then
                                        ppsecfv.int_value::text
                                      when v_ppse_dt_id in (7, 10) then
                                        ppsecfv.int_array_value::text end
    into v_project_id,v_pps_id,v_ppse_value
    from flow.project_process_step_event_custom_field_value ppsecfv
           inner join flow.project_process_step_event ppse on ppse.id = ppsecfv.project_process_step_event_id
           inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
    where pps.project_id = any (v_where_clause_condition_ids::bigint[])
      and ppsecfv.custom_field_group_assignment_id = any (v_ppse_cfga_ids)
      and case
            when v_ppse_dt_id = 1 then
              ppsecfv.date_value is not null
            when v_ppse_dt_id = 2 then
              ppsecfv.timestamp_value is not null
            when v_ppse_dt_id = 3 then
              ppsecfv.boolean_value is not null
            when v_ppse_dt_id = 4 then
              ppsecfv.numeric_value is not null
            when v_ppse_dt_id = 5 then
              ppsecfv.text_value is not null
            when v_ppse_dt_id in (6, 8, 9) then
              ppsecfv.int_value is not null
            when v_ppse_dt_id in (7, 10) then
              ppsecfv.int_array_value is not null
      end
    order by project_id, ppsecfv.date_created asc
    limit 1;

    if v_ppse_value is not null then
      select flow.get_prepared_value(v_ppse_dt_id, v_ppse_value)
      into v_prepared_value;


      if p_secondary_field_to_update is null and p_secondary_value is null then
        v_sql = $$update brs.project_details pd
            set $$ || p_field_to_update || $$ = $$ || v_prepared_value || $$,$$ ||
                p_update_first_value_only_id || $$ = $$ || v_pps_id || $$
               where pd.project_id = any($$ || p_where_clause_condition_ids::text || $$);$$;
      else
        v_sql = $$update brs.project_details pd
            set $$ || p_field_to_update || $$ = $$ || v_prepared_value || $$,$$ ||
                p_update_first_value_only_id || $$ = $$ || v_pps_id || $$,$$ ||
                p_secondary_field_to_update || $$ = $$ || p_secondary_value || $$
               where pd.project_id = any($$ || p_where_clause_condition_ids::text || $$);$$;
      end if;
      begin
        execute v_sql;
      exception
        when others then
          insert into flow.trigger_error(project_process_step_event_custom_field_value_id, error)
          values (v_pps_id, SQLERRM);
      end;
    end if;
  end if;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

