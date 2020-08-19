CREATE OR REPLACE FUNCTION flow.set_closer_appointment(p_project_id integer,
                                                       p_start_date timestamp,
                                                       p_end_date timestamp,
                                                       p_users integer array)
    RETURNS void AS
$BODY$
declare
    v_user_id                                    integer;
    v_project_process_step_id                    integer;
    v_project_process_step_custom_field_value_id integer;
    v_default_appointment_length                 integer;
BEGIN

    if array_length(p_users, 1) < 2 then
        select p_users[1]
        into v_user_id;
    else
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
                 where closer_appointment_start between now() - interval '21 days' and now()
                 group by rru.user_id),
             appointment_count_with_interval as (
                 select rru.user_id, count(1) as appointment_count_with_interval
                 from brs.project_details pd2
                          inner join round_robin_users rru on rru.user_id = pd2.closer_user_id
                 where closer_appointment_start between now() - (rru.distribution_time_frame_days || 'days')::interval and now()
                 group by rru.user_id),
             total_avail as (
                 select count(1) as avail, foo.user
                 from (
                          select unnest(users) as user, scheduled_start_time
                          from generate_series(p_start_date - interval '21 days',
                                               p_end_date, interval '1 day') as gs(d)
                                   join lateral flow.get_availability_time_slots(
                                  p_project_id,
                                  d,
                                  d + interval '23 hours 59 minutes 59 seconds',
                                  d::date,
                                  true) as t
                                        on true) as foo
                 group by foo.user
             )
        select user_id
        into v_user_id
        from (
                 select foo2.user_id, acutal_lead_allocation - total_lead_allocation as distance_from_actual_to_target
                 from (
                          select foo1.user_id,
                                 round(score / sum(score) over (), 2) as total_lead_allocation,
                                 round(acutal_lead_allocation, 2)     as acutal_lead_allocation
                          from (
                                   select user_id,
                                          lead_gen_num / lead_gen_den::numeric * 1000 + self_gen +
                                          ((appointment_count + avail) / 3)            as score,
                                          appointment_count_with_interval /
                                          sum(appointment_count_with_interval) over () as acutal_lead_allocation
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
                                                     left join total_avail ta on ta.user = pczu.user_id
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

        select uc.default_appointment_length
        into v_default_appointment_length
        from flow.project p
                 inner join flow.company_process cp on cp.id = p.company_process_id
                 inner join flow.user_company uc on uc.company_id = cp.company_id
        where p.id = p_project_id
          and uc.user_id = v_user_id;

        select pps.id, ppscfv.id
        into v_project_process_step_id,v_project_process_step_custom_field_value_id
        from flow.project_process_step_custom_field_value ppscfv
                 inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id
        where pps.project_id = p_project_id
          and ppscfv.custom_field_group_assignment_id = 7
        limit 1;
        --         raise notice 'this is v_project_process_step_id %',v_project_process_step_id;
--         raise notice 'this is v_project_process_step_custom_field_value_id %',v_project_process_step_custom_field_value_id;
--         raise notice 'this is v_user_idd %',v_user_id;
        if v_project_process_step_id is not null and v_project_process_step_custom_field_value_id is not null then
            update flow.project_process_step_custom_field_value
            set int_value = v_user_id
            where id = v_project_process_step_custom_field_value_id;
        else
            INSERT INTO flow.project_process_step_custom_field_value (project_process_step_id,
                                                                      custom_field_group_assignment_id, int_value,
                                                                      date_created, created_by_id, archived)
            VALUES (v_project_process_step_id, 7, v_user_id, now(), 2350555, false);
        end if;

        v_project_process_step_id = null;
        v_project_process_step_custom_field_value_id = null;
        select pps.id, ppscfv.id
        into v_project_process_step_id,v_project_process_step_custom_field_value_id
        from flow.project_process_step_custom_field_value ppscfv
                 inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id
        where pps.project_id = p_project_id
          and ppscfv.custom_field_group_assignment_id = 5
        limit 1;

        if v_project_process_step_id is not null and v_project_process_step_custom_field_value_id is not null then
            update flow.project_process_step_custom_field_value
            set timestamp_value = now()
            where id = v_project_process_step_custom_field_value_id;
        else
            INSERT INTO flow.project_process_step_custom_field_value (project_process_step_id,
                                                                      custom_field_group_assignment_id, timestamp_value,
                                                                      date_created, created_by_id, archived)
            VALUES (v_project_process_step_id, 5, now(), now(), 2350555, false);
        end if;

        v_project_process_step_id = null;
        v_project_process_step_custom_field_value_id = null;
        select pps.id, ppscfv.id
        into v_project_process_step_id,v_project_process_step_custom_field_value_id
        from flow.project_process_step_custom_field_value ppscfv
                 inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id
        where pps.project_id = p_project_id
          and ppscfv.custom_field_group_assignment_id = 6
        limit 1;

        if v_project_process_step_id is not null and v_project_process_step_custom_field_value_id is not null then
            update flow.project_process_step_custom_field_value
            set timestamp_value = now() - (v_default_appointment_length || 'days')::interval
            where id = v_project_process_step_custom_field_value_id;
        else
            INSERT INTO flow.project_process_step_custom_field_value (project_process_step_id,
                                                                      custom_field_group_assignment_id, timestamp_value,
                                                                      date_created, created_by_id, archived)
            VALUES (v_project_process_step_id, 6, now() - (v_default_appointment_length || 'days')::interval, now(), 2350555, false);
        end if;


    else
        --TODO throw an error that Randa is building.
    end if;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
