-- drop function flow.set_closer_appointment(integer, integer, timestamp, int[])
CREATE OR REPLACE FUNCTION flow.set_closer_appointment(p_project_id integer,
                                                       p_current_user_id integer,
                                                       p_project_process_step_id integer,
                                                       p_appointment_start_time timestamp,
                                                       p_users integer array)
    RETURNS table
            (
                success                boolean,
                user_id                integer,
                appointment_start_time timestamp,
                appointment_end_time   timestamp,
                user_full_name         text,
                user_email             text
            )
AS
$BODY$
declare
    v_user_id                                    integer;
    v_project_process_step_id                    integer;
    v_project_process_step_custom_field_value_id integer;
    v_default_appointment_length                 integer;
    v_user_already_assigned                      bigint;
    v_user_full_name                             text;
    v_user_email                                 text;
    v_user_position_id                           integer;
BEGIN

    if array_length(p_users, 1) < 2 then
        select p_users[1]
        into v_user_id;
        insert into brs.set_closer_appointment_audit(project_id, user_id, project_process_step_id,
                                                     distance_from_actual_to_target, appointment_start_date,is_only_user_available,
                                                     created_date,available_users,created_by_id)
        values(p_project_id,v_user_id,p_project_process_step_id,0,p_appointment_start_time,true,now(),p_users,p_current_user_id);
    else

     --   select p_users[1]
     --   into v_user_id;
        insert into brs.set_closer_appointment_audit(project_id, user_id, project_process_step_id,
                                                      distance_from_actual_to_target, appointment_start_date,
                                                      total_lead_allocation, actual_lead_allocation, score,
                                                      lead_gen_num, lead_gen_den, self_gen, total_avail,
                                                      appointment_count_with_interval, appointment_count,created_date,
                                                      available_users,created_by_id
                                                      )
        (with round_robin_users as (
            select up.user_id, pcz.distribution_time_frame_days
            from flow.project p
                     inner join flow.postal_code pc on pc.postal_code = p.postal_code and pc.archived is false
                     inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id and pcz.archived is false
                     inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id and pczu.postal_code_zone_user_type_id = 1 and pczu.archived is false
                     inner join flow.user_position up on up.id = pczu.user_position_id and up.primary_flag is true
            where p.id = p_project_id),
             lead_gen_num as (
                 select rru.user_id, count(pd.id) as lead_gen_num
                 from round_robin_users rru
                     left join brs.project_details pd on rru.user_id = pd.closer_user_id and
                                                         closer_appointment_start >= now() - interval '90 days'
                     and pd.source not in (523,524,530)
                     and final_design_signed_date is not null
                     and pd.financial_agreement_signed_date is not null
                     and pd.utility_bill_verified_date is not null
                     and (pd.proof_of_homeowners_insurance_obtained_date is not null or
                          proof_of_homeowners_insurance_required = 306)
                     and case
                             when pd.primary_financier = 721 then
                                     pd.first_cash_payment_paid_date is not null and
                                     greatest(final_design_signed_date, financial_agreement_signed_date,
                                              first_cash_payment_paid_date, utility_bill_verified_date,
                                              proof_of_homeowners_insurance_obtained_date)
                                         between now() - interval '90 days' and now()
                             else
                                 greatest(final_design_signed_date, financial_agreement_signed_date,
                                          proof_of_homeowners_insurance_obtained_date, utility_bill_verified_date)
                                     between now() - interval '90 days' and now()
                                                             end
                     AND ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date > now()))
                          left join flow.project p on p.id = pd.project_id
                          left join flow.project_status_type pst on pst.id = p.company_project_status_type_id and pst.id != 3
                 group by rru.user_id),
             lead_gen_den as (
                 select rru.user_id, count(pd.id) as lead_gen_den
                 from round_robin_users rru
                    left join brs.project_details pd on rru.user_id = pd.closer_user_id and
                                                        closer_appointment_start >= now() - interval '90 days'
                     and pd.source not in (523,524,530)
                          left  join flow.project p on p.id = pd.project_id
                 group by rru.user_id),
             self_gen as (
                 select rru.user_id, count(pd.id) * 2 as self_gen
                 from round_robin_users rru
                      left join brs.project_details pd on rru.user_id = pd.closer_user_id and
                                                          greatest(final_design_signed_date, financial_agreement_signed_date, first_cash_payment_paid_date,
                                                                   utility_bill_verified_date, proof_of_homeowners_insurance_obtained_date) >=
                                                          now() - interval '90 days'
                     and pd.source in (523,524,530)
                     and final_design_signed_date is not null
                     and pd.financial_agreement_signed_date is not null
                     and pd.utility_bill_verified_date is not null
                     and (pd.proof_of_homeowners_insurance_obtained_date is not null or
                          proof_of_homeowners_insurance_required = 306)
                     and case
                             when pd.primary_financier = 721 then
                                 pd.first_cash_payment_paid_date is not null
                             else
                                     1 = 1
                                                              end
                     AND ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date > now()))
                          left join flow.project p on p.id = pd.project_id
                          left join flow.project_status_type pst on pst.id = p.company_project_status_type_id and pst.id != 3
                 group by rru.user_id),
             appointment_count as (
                 select rru.user_id, count(pd2.id) as appointment_count
                 from round_robin_users rru
                      left join brs.project_details pd2 on rru.user_id = pd2.closer_user_id
                 and  closer_appointment_start between now() - interval '21 days' and now() + interval '100 days'
                 group by rru.user_id),
             appointment_count_with_interval as (
                 select rru.user_id, count(pd2.id) as appointment_count_with_interval
                 from round_robin_users rru
                 left join brs.project_details pd2 on rru.user_id = pd2.closer_user_id
                 and closer_appointment_start between now() - (rru.distribution_time_frame_days || 'days')::interval and now() + interval '100 days'
                 and pd2.source not in (523, 524, 530)
                 group by rru.user_id),
             total_avail as (
                 select coalesce(ca.appointment_count,0) as avail, rru.user_id
                 from round_robin_users rru
                 left join brs.cached_appointment ca  on rru.user_id = ca.user_id
                )
        select p_project_id,foo3.user_id,p_project_process_step_id,
               foo3.distance_from_actual_to_target,p_appointment_start_time,
               foo3.total_lead_allocation,foo3.acutal_lead_allocation,foo3.score,
               foo3.lead_gen_num,foo3.lead_gen_den,foo3.self_gen,foo3.avail,
               foo3.appointment_count_with_interval,foo3.appointment_count,now(),p_users,p_current_user_id
        from (
                 select foo2.user_id, acutal_lead_allocation - total_lead_allocation as distance_from_actual_to_target,
                        foo2.total_lead_allocation,foo2.acutal_lead_allocation,foo2.score,
                        foo2.lead_gen_num,
                        foo2.lead_gen_den,
                        foo2.self_gen,
                        foo2.avail,
                        foo2.appointment_count_with_interval,
                        foo2.appointment_count
                 from (
                          select foo1.user_id,
                                 case when sum(score) over () = 0 then
                                     0
                                     else
                                 round(score / sum(score) over (), 2) end as total_lead_allocation,
                                 round(acutal_lead_allocation, 2)     as acutal_lead_allocation,
                                 case when foo1.position_id =2 then
                                     foo1.score * 1.5
                                     else
                                         foo1.score end as score,
                                 foo1.lead_gen_num,
                                 foo1.lead_gen_den,
                                 foo1.self_gen,
                                 foo1.avail,
                                 foo1.appointment_count_with_interval,
                                 foo1.appointment_count

                          from (
                                   select foo.user_id,
                                          case when lead_gen_den is null or lead_gen_den = 0 then
                                                       self_gen +
                                                       ((appointment_count + avail) / 3) + ((lead_gen_num + self_gen) * 15)
                                          else
                                            ((lead_gen_num / lead_gen_den) * 10000) + self_gen + ((appointment_count + avail) / 3) + ((lead_gen_num + self_gen) * 15)  end  as score,
                                          case
                                              when sum(appointment_count_with_interval) over () = 0 then
                                                  0
                                              else appointment_count_with_interval /
                                                   sum(appointment_count_with_interval) over () end as acutal_lead_allocation,
                                          foo.lead_gen_num,
                                          foo.lead_gen_den,
                                          foo.self_gen,
                                          foo.avail,
                                          foo.appointment_count_with_interval,
                                          foo.appointment_count,
                                          foo.position_id
                                   from (
                                            select up2.user_id,
                                                   coalesce(lgn.lead_gen_num, 0)                     as lead_gen_num,
                                                   coalesce(lgd.lead_gen_den, 0)                     as lead_gen_den,
                                                   coalesce(sg.self_gen, 0)                          as self_gen,
                                                   ac.appointment_count,
                                                   coalesce(ta.avail, 0)                             as avail,
                                                   coalesce(acwi.appointment_count_with_interval, 0) as appointment_count_with_interval,
                                                   up2.position_id
                                            from flow.project p
                                                     inner join flow.postal_code pc on pc.postal_code = p.postal_code and pc.archived is false
                                                     inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id and pcz.archived is false
                                                     inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id and pczu.postal_code_zone_user_type_id = 1 and pczu.archived is false
                                                     inner join flow.user_position up2 on up2.id = pczu.user_position_id and up2.primary_flag is true
                                                     left join lead_gen_num lgn on lgn.user_id = up2.user_id
                                                     left join lead_gen_den lgd on lgd.user_id = up2.user_id
                                                     left join self_gen sg on sg.user_id = up2.user_id
                                                     left join appointment_count ac on ac.user_id = up2.user_id
                                                     left join total_avail ta on ta.user_id = up2.user_id
                                                     left join appointment_count_with_interval acwi on acwi.user_id = up2.user_id
                                            where p.id = p_project_id
                                            group by up2.user_id, lgn.lead_gen_num, lgd.lead_gen_den, sg.self_gen,
                                                     ac.appointment_count,
                                                     pcz.distribution_time_frame_days, ta.avail,
                                                     acwi.appointment_count_with_interval,
                                                     up2.position_id) as foo
                                   group by foo.user_id, foo.lead_gen_num, foo.lead_gen_den, foo.self_gen,
                                            foo.appointment_count,
                                            foo.avail, foo.appointment_count_with_interval,
                                            foo.position_id) as foo1) as foo2
                 group by foo2.user_id, foo2.acutal_lead_allocation, foo2.total_lead_allocation,
                          foo2.total_lead_allocation,foo2.acutal_lead_allocation,foo2.score,
                          foo2.lead_gen_num,
                          foo2.lead_gen_den,
                          foo2.self_gen,
                          foo2.avail,
                          foo2.appointment_count_with_interval,
                          foo2.appointment_count) as foo3);

        select scau.user_id
        into v_user_id
        from brs.set_closer_appointment_audit scau
        where project_process_step_id = p_project_process_step_id
        and scau.user_id = any(p_users)
        order by distance_from_actual_to_target
        limit 1;
    end if;

    if v_user_id is not null then

        select first_name || ' ' || last_name,
                email
        into v_user_full_name, v_user_email
        from flow."user"
        where id = v_user_id;

        select id
        into v_user_position_id
        from flow.user_position up
        where up.user_id = v_user_id
          and up.primary_flag is true
          and up.position_id in (1,2,3);

        select count(1)
        into v_user_already_assigned
        from flow.project_process_step_custom_field_value ppscfv2
        where ppscfv2.project_process_step_id = p_project_process_step_id
          and ppscfv2.custom_field_group_assignment_id = 7
          and int_value is not null;

        if v_user_already_assigned < 1 then


            select uc.default_appointment_length
            into v_default_appointment_length
            from flow.project p
                     inner join flow.company_process cp on cp.id = p.company_process_id
                     inner join flow.user_company uc on uc.company_id = cp.company_id
            where p.id = p_project_id
              and uc.user_id = v_user_id;

            select ppscfv.project_process_step_id, ppscfv.id
            into v_project_process_step_id,v_project_process_step_custom_field_value_id
            from flow.project_process_step_custom_field_value ppscfv
            where ppscfv.project_process_step_id = p_project_process_step_id
              and ppscfv.custom_field_group_assignment_id = 7
            limit 1;
            --         raise notice 'this is v_project_process_step_id %',v_project_process_step_id;
--         raise notice 'this is v_project_process_step_custom_field_value_id %',v_project_process_step_custom_field_value_id;
--         raise notice 'this is v_user_idd %',v_user_id;
            if v_project_process_step_id is not null and v_project_process_step_custom_field_value_id is not null then
                update flow.project_process_step_custom_field_value
                set int_value = v_user_position_id
                where id = v_project_process_step_custom_field_value_id;
            else
                INSERT INTO flow.project_process_step_custom_field_value (project_process_step_id,
                                                                          custom_field_group_assignment_id, int_value,
                                                                          date_created, created_by_id, archived)
                VALUES (p_project_process_step_id, 7, v_user_position_id, now(), p_current_user_id, false);
            end if;

            v_project_process_step_id = null;
            v_project_process_step_custom_field_value_id = null;
            select ppscfv.project_process_step_id, ppscfv.id
            into v_project_process_step_id,v_project_process_step_custom_field_value_id
            from flow.project_process_step_custom_field_value ppscfv
            where ppscfv.project_process_step_id = p_project_process_step_id
              and ppscfv.custom_field_group_assignment_id = 5
            limit 1;

            if v_project_process_step_id is not null and v_project_process_step_custom_field_value_id is not null then
                update flow.project_process_step_custom_field_value
                set timestamp_value = p_appointment_start_time
                where id = v_project_process_step_custom_field_value_id;
            else
                INSERT INTO flow.project_process_step_custom_field_value (project_process_step_id,
                                                                          custom_field_group_assignment_id,
                                                                          timestamp_value,
                                                                          date_created, created_by_id, archived)
                VALUES (p_project_process_step_id, 5, p_appointment_start_time, now(), p_current_user_id, false);
            end if;

            v_project_process_step_id = null;
            v_project_process_step_custom_field_value_id = null;
            select ppscfv.project_process_step_id, ppscfv.id
            into v_project_process_step_id,v_project_process_step_custom_field_value_id
            from flow.project_process_step_custom_field_value ppscfv
            where ppscfv.project_process_step_id = p_project_process_step_id
              and ppscfv.custom_field_group_assignment_id = 6
            limit 1;

            if v_project_process_step_id is not null and v_project_process_step_custom_field_value_id is not null then
                update flow.project_process_step_custom_field_value
                set timestamp_value = p_appointment_start_time + (v_default_appointment_length || 'minutes')::interval
                where id = v_project_process_step_custom_field_value_id;
            else
                INSERT INTO flow.project_process_step_custom_field_value (project_process_step_id,
                                                                          custom_field_group_assignment_id,
                                                                          timestamp_value,
                                                                          date_created, created_by_id, archived)
                VALUES (p_project_process_step_id, 6, p_appointment_start_time +
                                                      (v_default_appointment_length || 'minutes')::interval, now(),
                        p_current_user_id, false);
            end if;
            -- raise notice 'user id %',v_user_id;
            -- raise notice 'p_appointment_start_time %',p_appointment_start_time;
            -- raise notice 'v_default_appointment_length %',v_default_appointment_length;
            -- raise notice 'end %',(p_appointment_start_time +
            --                     (v_default_appointment_length || 'minutes')::interval)::timestamp;
            return query select true::boolean,
                                v_user_id::integer,
                                p_appointment_start_time::timestamp,
                                (p_appointment_start_time +
                                 (v_default_appointment_length || 'minutes')::interval)::timestamp,
                                v_user_full_name,
                                v_user_email;
        elsif v_user_already_assigned > 1 and array_length(p_users, 1) > 1 then
            p_users = array_remove(p_users, v_user_id);
           -- raise notice 'i am here';
            return query select *
                         from flow.set_closer_appointment(p_project_id,
                                                          p_current_user_id,
                                                          p_project_process_step_id,
                                                          p_appointment_start_time,
                                                          p_users);
        else
            return query select false::boolean, null::integer, null::timestamp, null::timestamp, null::text, null::text;
        end if;

    else
        return query select false::boolean, null::integer, null::timestamp, null::timestamp, null::text, null::text;
    end if;


END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
