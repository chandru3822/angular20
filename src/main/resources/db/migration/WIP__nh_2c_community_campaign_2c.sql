SET session_replication_role = replica;
DO
$do$
  declare
    u record;
    v_project_process_step_campaign_id     bigint;
    v_total bigint;
  BEGIN
    raise notice 'NH Community Campaign START = %',clock_timestamp();
    v_total = 0;
    for u in select
               c3.id as campaign_id,
               c3.owner_id,
               lov1.id as lov1_sales_status_c_id,
               c3.end_date,
               c3.short_description_c,
               c3.description,
               c3.solar_cut_off_c,
               p.id     as project_id,
               co.id    as community_id,
               case when c3.campaign_owner_id is null and c3.owner_id is not null then
                      2495780::bigint
                    else
                      c3.campaign_owner_id end as campaign_owner_id,
               concat(su.first_name,' ',su.email) as owner_name
             from brs.campaign c3
               left join brs.sp_user su on su.id = c3.owner_id
               inner join brs.NH_COMMUNITY_C co on co.campaign_c = c3.id
               inner join flow.project p on p.nw_migration_id = co.id
                    left join flow.list_of_value lov1 on lov1.name = c3.sales_status_c and lov1.parent_id = 25309
             where c3.is_deleted = false
             order by c3.nh_community_c, c3.created_date

      loop
        v_total = v_total + 1;

            v_project_process_step_campaign_id = null;
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id,nw_migration_id)
            values (u.project_id, 3758, null,1, null, now(), now(), 2384850, 2384850, false,
                   true, null, null, null,u.campaign_id)
            returning id into v_project_process_step_campaign_id;
            perform flow.set_pps_cfv_no_checks(v_project_process_step_campaign_id, 2384850, 28116, u.lov1_sales_status_c_id::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_campaign_id, 2384850, 28117, u.campaign_owner_id::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_campaign_id, 2384850, 29880, u.owner_name::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_campaign_id, 2384850, 28118, u.end_date::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_campaign_id, 2384850, 28119, u.short_description_c::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_campaign_id, 2384850, 28120, u.description::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_campaign_id, 2384850, 28121, u.solar_cut_off_c::text, true);
         end loop;
    raise notice 'NH Community Campaign END = %',clock_timestamp();
    raise notice 'NH Community Campaign Total = %',v_total;
  end
$do$;
