CREATE OR REPLACE FUNCTION brs.get_round_robin_lead_allocation_rank(p_postal_code_zone_id integer, p_time_interval integer)
    RETURNS table
            (
                user_id              integer,
                closer_name          text,
                lead_gen_fdc         numeric,
                self_gen             bigint,
                average_availability bigint,
                score                numeric
            )
AS
$BODY$
BEGIN
    return query
        with round_robin_users as (
            select pczu.user_id, concat(u.first_name, ' ', u.last_name) as closer_name, pcz.distribution_time_frame_days
            from flow.postal_code_zone_user pczu
                     inner join flow.user u on u.id = pczu.user_id
                     inner join flow.postal_code_zone pcz on pcz.id = pczu.postal_code_zone_id and pcz.archived is false
            where pcz.id = p_postal_code_zone_id
              and pczu.postal_code_zone_user_type_id = 1
              and pczu.archived is false),
             lead_gen_num as (
                 select rru.user_id, count(pd.id) as lead_gen_num
                 from round_robin_users rru
                     left join brs.project_details pd on rru.user_id = pd.closer_user_id
                     left join flow.project p on p.id = pd.project_id
                     left join flow.project_status_type pst on pst.id = p.company_project_status_type_id and pst.id != 3
                 where pd.closer_appointment_start  >= now()  - interval '90 days'
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
                                         >= now()  - interval '90 days'
                             else
                                     greatest(final_design_signed_date, financial_agreement_signed_date,
                                              proof_of_homeowners_insurance_obtained_date, utility_bill_verified_date)
                                     >= now()  - interval '90 days'
                                                                  end
                     and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date > (now() AT TIME ZONE 'US/Mountain') :: date))
                     and pd.company_id = 3
                 group by rru.user_id),
             lead_gen_den as (
                 select rru.user_id, count(pd.id) as lead_gen_den
                 from round_robin_users rru
                     left join brs.project_details pd on rru.user_id = pd.closer_user_id
                     left join flow.project p on p.id = pd.project_id
                 where pd.closer_appointment_start >= now()  - interval '90 days'
                     and pd.source not in (523,524,530)
                     and pd.company_id = 3
                 group by rru.user_id),
             lead_gen_num_fdc as (
                 select rru.user_id, count(pd.id) as lead_gen_num
                 from round_robin_users rru
                     left join brs.project_details pd on rru.user_id = pd.closer_user_id
                     left join flow.project p on p.id = pd.project_id
                     left join flow.project_status_type pst on pst.id = p.company_project_status_type_id and pst.id != 3
                 where pd.closer_appointment_start  >= now()  - (p_time_interval ||'day')::interval
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
                                         >= ((now() AT TIME ZONE 'US/Mountain') :: date - (p_time_interval ||'day')::interval)
                             else
                                 greatest(final_design_signed_date, financial_agreement_signed_date,
                                          proof_of_homeowners_insurance_obtained_date, utility_bill_verified_date)
                                     >= ((now() AT TIME ZONE 'US/Mountain') :: date - (p_time_interval ||'day')::interval)
                                                                  end
                     and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date > ((now() AT TIME ZONE 'US/Mountain') :: date)))
                     and pd.company_id = 3
                 group by rru.user_id),
             lead_gen_den_fdc as (
                 select rru.user_id, count(pd.id) as lead_gen_den
                 from round_robin_users rru
                     left join brs.project_details pd on rru.user_id = pd.closer_user_id
                     left join flow.project p on p.id = pd.project_id
                 where pd.closer_appointment_start  >= now()  - (p_time_interval ||'day')::interval
                     and pd.source not in (523,524,530)
                     and pd.company_id = 3
                 group by rru.user_id),
             self_gen as (
                 select rru.user_id, count(pd.id)  as self_gen
                 from round_robin_users rru
                     left join brs.project_details pd on rru.user_id = pd.closer_user_id
                     left join flow.project p on p.id = pd.project_id
                     left join flow.project_status_type pst on pst.id = p.company_project_status_type_id and pst.id != 3
                 where greatest(final_design_signed_date, financial_agreement_signed_date, first_cash_payment_paid_date,
                                utility_bill_verified_date, proof_of_homeowners_insurance_obtained_date) >= ((now() AT TIME ZONE 'US/Mountain') :: date - (p_time_interval ||'day')::interval)
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
                     and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date > ((now() AT TIME ZONE 'US/Mountain') :: date)))
                     and pd.company_id = 3
                 group by rru.user_id),
             appointment_count as (
                 select rru.user_id, count(pd2.id) as appointment_count
                 from round_robin_users rru
                     left join brs.project_details pd2 on rru.user_id = pd2.closer_user_id
                 where ((pd2.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date between ((now() AT TIME ZONE 'US/Mountain') :: date - (p_time_interval ||'day')::interval) and ((now() AT TIME ZONE 'US/Mountain') :: date + interval '100 days')
                     and pd2.company_id = 3
                 group by rru.user_id),
             appointment_count_with_interval as (
                 select rru.user_id, count(pd2.id) as appointment_count_with_interval
                 from round_robin_users rru
                     left join brs.project_details pd2 on rru.user_id = pd2.closer_user_id
                 where ((pd2.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date between (((now() AT TIME ZONE 'US/Mountain') :: date) - (rru.distribution_time_frame_days || 'days')::interval) and ((now() AT TIME ZONE 'US/Mountain') :: date + interval '100 days')
                     and pd2.company_id = 3
                 group by rru.user_id),
             total_avail as (
                 select coalesce(ca.appointment_count,0) as avail, rru.user_id
                 from round_robin_users rru
                     left join brs.cached_appointment ca on rru.user_id = ca.user_id
             )



        select foo1.user_id,
               foo1.closer_name,
               foo1.lead_gen_fdc * 100,
               foo1.self_gen,
               foo1.average_availability,
               case when sum(foo1.score) = 0 then
                   0
                else
               round(foo1.score / sum(foo1.score) over (), 2)*100
                end as score
        from (
                 select foo.user_id,
                        case when lead_gen_den is null or lead_gen_den = 0 then
                                     (foo.self_gen +
                                     ((foo.appointment_count + foo.avail) / 3) + ((foo.lead_gen_num + foo.self_gen) * 15))
                                     * case when (select count(1) > 0 as count
                                                  from flow.user_position up
                                                  where up.user_id = foo.user_id and
                                                      up.primary_flag is true and
                                                          up.position_id = 2) then
                                                1.5
                                            else
                                                1 end
                             else
                                             ((foo.lead_gen_num / foo.lead_gen_den::numeric * 10000) + foo.self_gen +
                                             ((foo.appointment_count + foo.avail) / 3) + ((foo.lead_gen_num + foo.self_gen) * 15))
                                     * case when (select count(1) > 0 as count
                                                  from flow.user_position up
                                                  where up.user_id = foo.user_id and
                                                      up.primary_flag is true and
                                                          up.position_id = 2) then
                                                1.5
                                            else
                                                1 end end as score,
                        case
                            when foo.lead_gen_den_fdc is null or foo.lead_gen_den_fdc = 0 then
                                0
                            else
                                round((foo.lead_gen_num_fdc / foo.lead_gen_den_fdc::numeric), 2) end   as lead_gen_fdc,
                        ((foo.appointment_count + foo.avail) / 9)                                       as average_availability,
                        foo.self_gen,
                        foo.closer_name
                 from (
                          select pczu.user_id,
                             concat(u.first_name, ' ', u.last_name)                as closer_name,
                                 coalesce(lgn.lead_gen_num, 0)                     as lead_gen_num,
                                 coalesce(lgd.lead_gen_den, 0)                     as lead_gen_den,
                                 coalesce(lgnfdc.lead_gen_num, 0)                     as lead_gen_num_fdc,
                                 coalesce(lgdfdc.lead_gen_den, 0)                     as lead_gen_den_fdc,
                                 coalesce(sg.self_gen, 0)                          as self_gen,
                                 ac.appointment_count,
                                 coalesce(ta.avail, 0)                             as avail,
                                 coalesce(acwi.appointment_count_with_interval, 0) as appointment_count_with_interval
                          from flow.postal_code_zone pcz
                                   inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id and pczu.archived is false
                                   inner join flow.user u on u.id = pczu.user_id
                                   left join lead_gen_num lgn on lgn.user_id = pczu.user_id
                                   left join lead_gen_den lgd on lgd.user_id = pczu.user_id
                                   left join lead_gen_num_fdc lgnfdc on lgnfdc.user_id = pczu.user_id
                                   left join lead_gen_den_fdc lgdfdc on lgdfdc.user_id = pczu.user_id
                                   left join self_gen sg on sg.user_id = pczu.user_id
                                   left join appointment_count ac on ac.user_id = pczu.user_id
                                   left join total_avail ta on ta.user_id = pczu.user_id
                                   left join appointment_count_with_interval acwi on acwi.user_id = pczu.user_id
                          where pcz.id = p_postal_code_zone_id
                            and pczu.postal_code_zone_user_type_id = 1
                            and pcz.archived is false
                          group by pczu.user_id, concat(u.first_name, ' ', u.last_name), lgn.lead_gen_num, lgd.lead_gen_den, sg.self_gen,
                                   lgnfdc.lead_gen_num,lgdfdc.lead_gen_den,
                                   ac.appointment_count,
                                   pcz.distribution_time_frame_days, ta.avail,
                                   acwi.appointment_count_with_interval) as foo
                 group by foo.user_id, foo.closer_name, foo.lead_gen_num, foo.lead_gen_den, foo.self_gen,
                          foo.lead_gen_num_fdc,foo.lead_gen_den_fdc,
                          foo.appointment_count,
                          foo.avail) as foo1
        group by foo1.score,foo1.average_availability,foo1.user_id, foo1.closer_name, foo1.lead_gen_fdc, foo1.self_gen, coalesce(foo1.average_availability, 0), coalesce(foo1.score, 0);
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
