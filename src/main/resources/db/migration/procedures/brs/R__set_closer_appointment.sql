-- drop function flow.set_closer_appointment(integer, integer, timestamp, int[])
CREATE OR REPLACE FUNCTION flow.set_closer_appointment(p_project_id integer,
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
    else

     --   select p_users[1]
     --   into v_user_id;
        with round_robin_users as (
            select pczu.user_id, pcz.distribution_time_frame_days
            from flow.project p
                     inner join flow.postal_code pc on pc.postal_code = p.postal_code
                     inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id
                     inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id
            where p.id = p_project_id),
             lead_gen_num as (
                 select rru.user_id, count(1) as lead_gen_num
                 from brs.project_details pd
                          inner join flow.project p on p.id = pd.project_id
                          inner join flow.project_status_type pst on pst.id = p.company_project_status_type_id
                          inner join round_robin_users rru on rru.user_id = pd.closer_user_id
                 where closer_appointment_start >= now() - interval '21 days'
                   and pd.source not in (7, 8, 484)
                   and final_design_signed_date is not null
                   and pd.financial_agreement_signed_date is not null
                   and pd.utility_bill_verified_date is not null
                   and (pd.proof_of_homeowners_insurance_obtained_date is not null or
                        proof_of_homeowners_insurance_required = 306)
                   and case
                           when pd.primary_financier = 119 then
                                   pd.first_cash_payment_paid_date is not null and
                                   greatest(final_design_signed_date, financial_agreement_signed_date,
                                            first_cash_payment_paid_date, utility_bill_verified_date,
                                            proof_of_homeowners_insurance_obtained_date)
                                       between now() - interval '21 days' and now()
                           else
                               greatest(final_design_signed_date, financial_agreement_signed_date,
                                        proof_of_homeowners_insurance_obtained_date, utility_bill_verified_date)
                                   between now() - interval '21 days' and now()
                     end
                   AND ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date > now()))
                   AND (pst.id != 3)
                 group by rru.user_id),
             lead_gen_den as (
                 select rru.user_id, count(1) as lead_gen_den
                 from brs.project_details pd
                          inner join flow.project p on p.id = pd.project_id
                          inner join round_robin_users rru on rru.user_id = pd.closer_user_id
                 where closer_appointment_start >= now() - interval '21 days'
                   and pd.source not in (7, 8, 484)
                 group by rru.user_id),
             self_gen as (
                 select rru.user_id, count(1) * 2 as self_gen
                 from brs.project_details pd
                          inner join flow.project p on p.id = pd.project_id
                          inner join flow.project_status_type pst on pst.id = p.company_project_status_type_id
                          inner join round_robin_users rru on rru.user_id = pd.closer_user_id
                 where greatest(final_design_signed_date, financial_agreement_signed_date, first_cash_payment_paid_date,
                                utility_bill_verified_date, proof_of_homeowners_insurance_obtained_date) >=
                       now() - interval '21 days'
                   and pd.source in (7, 8, 484)
                   and final_design_signed_date is not null
                   and pd.financial_agreement_signed_date is not null
                   and pd.utility_bill_verified_date is not null
                   and (pd.proof_of_homeowners_insurance_obtained_date is not null or
                        proof_of_homeowners_insurance_required = 306)
                   and case
                           when pd.primary_financier = 119 then
                               pd.first_cash_payment_paid_date is not null
                           else
                               1 = 1
                     end
                   AND ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date > now()))
                   AND (pst.id != 3)
                 group by rru.user_id),
             appointment_count as (
                 select rru.user_id, count(1) as appointment_count
                 from brs.project_details pd2
                          inner join round_robin_users rru on rru.user_id = pd2.closer_user_id
                 where closer_appointment_start between now() - interval '21 days' and now() + interval '100 days'
                 group by rru.user_id),
             appointment_count_with_interval as (
                 select rru.user_id, count(1) as appointment_count_with_interval
                 from brs.project_details pd2
                          inner join round_robin_users rru on rru.user_id = pd2.closer_user_id
                 where closer_appointment_start between now() - (rru.distribution_time_frame_days || 'days')::interval and now() + interval '100 days'
                 group by rru.user_id),
             total_avail as (
                 select ca.appointment_count as avail, ca.user_id
                 from brs.cached_appointment ca
                          inner join round_robin_users rru on rru.user_id = ca.user_id
             )
        select foo3.user_id
        into v_user_id
        from (
                 select foo2.user_id, acutal_lead_allocation - total_lead_allocation as distance_from_actual_to_target
                 from (
                          select foo1.user_id,
                                 round(score / sum(score) over (), 2) as total_lead_allocation,
                                 round(acutal_lead_allocation, 2)     as acutal_lead_allocation
                          from (
                                   select foo.user_id,
                                          case when lead_gen_den is null or lead_gen_den = 0 then
                                                       self_gen +
                                                       ((appointment_count + avail) / 3)
                                          else
                                          lead_gen_num / lead_gen_den::numeric * 1000 + self_gen +
                                          ((appointment_count + avail) / 3)  end                       as score,
                                          case
                                              when sum(appointment_count_with_interval) over () = 0 then
                                                  0
                                              else appointment_count_with_interval /
                                                   sum(appointment_count_with_interval) over () end as acutal_lead_allocation
                                   from (
                                            select pczu.user_id,
                                                   coalesce(lgn.lead_gen_num, 0)                     as lead_gen_num,
                                                   coalesce(lgd.lead_gen_den, 0)                     as lead_gen_den,
                                                   coalesce(sg.self_gen, 0)                          as self_gen,
                                                   ac.appointment_count,
                                                   coalesce(ta.avail, 0)                             as avail,
                                                   coalesce(acwi.appointment_count_with_interval, 0) as appointment_count_with_interval
                                            from flow.project p
                                                     inner join flow.postal_code pc on pc.postal_code = p.postal_code
                                                     inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id
                                                     inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id
                                                     left join lead_gen_num lgn on lgn.user_id = pczu.user_id
                                                     left join lead_gen_den lgd on lgd.user_id = pczu.user_id
                                                     left join self_gen sg on sg.user_id = pczu.user_id
                                                     left join appointment_count ac on ac.user_id = pczu.user_id
                                                     left join total_avail ta on ta.user_id = pczu.user_id
                                                     left join appointment_count_with_interval acwi on acwi.user_id = pczu.user_id
                                            where p.id = p_project_id
                                            group by pczu.user_id, lgn.lead_gen_num, lgd.lead_gen_den, sg.self_gen,
                                                     ac.appointment_count,
                                                     pcz.distribution_time_frame_days, ta.avail,
                                                     acwi.appointment_count_with_interval) as foo
                                   group by foo.user_id, foo.lead_gen_num, foo.lead_gen_den, foo.self_gen,
                                            foo.appointment_count,
                                            foo.avail, foo.appointment_count_with_interval) as foo1) as foo2
                 where foo2.user_id = any (p_users)
                 group by foo2.user_id, foo2.acutal_lead_allocation, foo2.total_lead_allocation
                 order by distance_from_actual_to_target) as foo3
        limit 1;
    end if;

    if v_user_id is not null then

        select into v_user_full_name, v_user_email
               first_name || ' ' || last_name,
                email
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
                VALUES (p_project_process_step_id, 7, v_user_position_id, now(), 2350555, false);
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
                VALUES (p_project_process_step_id, 5, p_appointment_start_time, now(), 2350555, false);
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
                        2350555, false);
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
