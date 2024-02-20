drop function if exists brs.rpt_company_dashboard_drilldown(date, date, bigint, bigint, boolean, bigint);
drop function if exists brs.rpt_company_dashboard_drilldown(p_custom_start_date date, p_custom_end_date date,
                                                            p_milestone_type_id bigint);
CREATE OR REPLACE FUNCTION brs.rpt_company_dashboard_drilldown(p_custom_start_date date, p_custom_end_date date,
                                                               p_milestone_type_id bigint)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_company_ids  bigint[];
  v_sql          text;
  x              record;
  v_compare_date text;
  v_value        integer;
  v_data_value   text;
  v_first_row    boolean default true;
BEGIN

case
    when p_milestone_type_id = 22
      then RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                        from (with results as (SELECT p.id                                                                              as project_id,
                                                      p.contact_id,
                                                      min((wqc.date_entered_queue AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::date as date_entered_queue
                                               FROM flow.work_queue_cycle wqc
                                                      inner join flow.project_process_step pps ON wqc.project_process_step_id = pps.id
                                                      inner join flow.company_process_step_status_type cpsst
                                                                 ON wqc.company_process_step_status_type_id = cpsst.id
                                                      inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                                                                 ON
                                                                   wqc.process_step_work_queue_type_process_step_status_type_id =
                                                                   pswqtpsst.id
                                                      inner join flow.process_step_work_queue_type pswqt
                                                                 ON pswqtpsst.process_step_work_queue_type_id = pswqt.id
                                                      inner join flow.user u on u.id = pps.created_by_id
                                                      JOIN flow.work_queue_type wqt ON pswqt.work_queue_type_id = wqt.id
                                                      inner join flow.project p ON pps.project_id = p.id and p.archived is false
                                               WHERE pps.process_step_id = 3365
                                                 AND work_queue_type_id = 93
                                               group by p.id)
                              select concat(pd.contact_first_name, ' ', pd.contact_last_name) customer_name,
                                     pd.project_id,
                                     pd.project_state_abbreviation                            state,
                                     pd.source_name,
                                     json_build_array(
                                       json_build_object('label','Ready to Schedule Installation Date','value',date_entered_queue,
                                                         'data_type_id',1,'data_type','date')
                                     ) as additional_columns
                              from results r
                                     inner join brs.project_details pd on pd.project_id = r.project_id
                              where date_entered_queue between p_custom_start_date and p_custom_end_date
                                and company_id = 3) as funnel_rows;
    else

    v_value = 1;
    v_sql = $$ select coalesce(coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), $$ || quote_literal('[]') ||
            $$), $$ || quote_literal('[]') ||
            $$) from (
                        select concat(pd.contact_first_name,$$ || quote_literal(' ') || $$, pd.contact_last_name) customer_name,
                               pd.project_id,
                               pd.project_state_abbreviation                         state,
                               $$;
    v_sql = v_sql || $$ jsonb_build_array( $$;
    for x in select dmc.display_value, dt.id as data_type_id,dt.data_type, dmc.title, dmc.use_date_in_where_clause,
                    use_greatest,
                    lead(dmc.id) OVER (order by dmc.display_order) IS NULL::boolean AS is_last_row
             from brs.dashboard_milestone_column dmc
                    inner join flow.data_type dt on dt.id = dmc.data_type_id
             where dashboard_milestone_id = p_milestone_type_id
            order by dmc.display_order
      loop
        v_data_value = concat('pd.', x.display_value);
        if p_milestone_type_id = 3 and x.use_date_in_where_clause is false then
          v_data_value = 'lov.name';
        end if;
        if x.use_date_in_where_clause is true then
            if x.use_greatest is not null and x.use_greatest is true and v_first_row is true then
              v_compare_date = $$greatest($$;
              if x.data_type_id = 2 then
                v_compare_date = coalesce(v_compare_date, '') || $$((pd.$$ || x.display_value || $$ at time zone $$ ||
                                 quote_literal('UTC') || $$) at time zone $$ || quote_literal('US/Mountain') ||
                                 $$) :: date$$;
              elsif x.data_type_id = 1 then
                v_compare_date = coalesce(v_compare_date, '') || $$pd.$$ || x.display_value || $$ :: date $$;
              end if;
            elsif x.use_greatest is not null and x.use_greatest is true and v_first_row is false then
              if x.data_type_id = 2 then
                v_compare_date = coalesce(v_compare_date, '') || $$, ((pd.$$ || x.display_value || $$ at time zone $$ ||
                                 quote_literal('UTC') || $$) at time zone $$ || quote_literal('US/Mountain') ||
                                 $$) :: date$$;
              elsif x.data_type_id = 1 then
                v_compare_date = coalesce(v_compare_date, '') || $$, pd.$$ || x.display_value || $$ :: date $$;
              end if;

            elsif x.use_greatest is not null and x.use_greatest is false and v_first_row is true then
              v_compare_date = $$least($$;
              if x.data_type_id = 2 then
                v_compare_date = coalesce(v_compare_date, '') || $$((pd.$$ || x.display_value || $$ at time zone $$ ||
                                 quote_literal('UTC') || $$) at time zone $$ || quote_literal('US/Mountain') ||
                                 $$) :: date$$;
              elsif x.data_type_id = 1 then
                v_compare_date = coalesce(v_compare_date, '') || $$pd.$$ || x.display_value || $$ :: date $$;
              end if;
            elsif x.use_greatest is not null and x.use_greatest is false and v_first_row is false then
              if x.data_type_id = 2 then
                v_compare_date = coalesce(v_compare_date, '') || $$,((pd.$$ || x.display_value || $$ at time zone $$ ||
                                 quote_literal('UTC') || $$) at time zone $$ || quote_literal('US/Mountain') ||
                                 $$) :: date$$;
              elsif x.data_type_id = 1 then
                v_compare_date = coalesce(v_compare_date, '') || $$,pd.$$ || x.display_value || $$ :: date $$;
              end if;
            end if;

            if x.use_greatest is not null and v_first_row is false then
              v_compare_date = coalesce(v_compare_date, '') || $$) between$$ || quote_literal(p_custom_start_date) || $$ and $$ ||
                quote_literal(p_custom_end_date);
            end if;

          if x.data_type_id = 2 and x.use_greatest is null then
          v_compare_date = coalesce(v_compare_date, '') || $$((pd.$$ || x.display_value || $$ at time zone $$ ||
                           quote_literal('UTC') || $$) at time zone $$ || quote_literal('US/Mountain') ||
                           $$) :: date between$$ || quote_literal(p_custom_start_date) || $$ and $$ ||
                           quote_literal(p_custom_end_date);
          elsif x.data_type_id = 1 and x.use_greatest is null then
            v_compare_date = coalesce(v_compare_date, '') || $$pd.$$ || x.display_value || $$ :: date between$$ || quote_literal(p_custom_start_date) || $$ and $$ ||
                             quote_literal(p_custom_end_date);
          end if;
        end if;
        v_sql = v_sql || $$jsonb_build_object($$||quote_literal('value')||$$,$$||v_data_value||$$,$$||
                          quote_literal('data_type_id')||$$,$$||quote_literal(x.data_type_id)||
                        $$,$$||quote_literal('data_type')||$$,$$||quote_literal(x.data_type)||
                        $$,$$||quote_literal('label')||$$,$$||quote_literal(x.title)||$$)$$;
        if x.is_last_row is false then
          v_sql = v_sql ||$$,$$;
        end if;
        v_value = v_value + 1;
        v_first_row = false;
      end loop;
    v_sql = v_sql || $$) as additional_columns,$$;
    v_sql = v_sql || $$ pd.source_name from brs.project_details pd
                               left join flow.list_of_value lov on lov.id = pd.first_appointment_pitched_id
                        where $$ || v_compare_date ||
            $$  and pd.archived is false
                         and pd.company_id = 3
                               ) as funnel_rows;$$;
    raise notice 'v_sql %',v_sql;
    return query execute v_sql;
    end case;

END
$function$



