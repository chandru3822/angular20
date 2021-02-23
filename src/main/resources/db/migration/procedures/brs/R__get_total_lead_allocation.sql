CREATE OR REPLACE FUNCTION brs.get_total_lead_allocation(p_postal_code_zone_id integer,
                                                         p_run_manual_allocation boolean default false)
    RETURNS table
            (
                postal_code_zone_user_id        integer,
                user_id                         integer,
                distance_from_actual_to_target  numeric,
                total_lead_allocation           numeric,
                actual_lead_allocation          numeric,
                score                           numeric,
                lead_gen_num                    bigint,
                lead_gen_den                    bigint,
                self_gen                        bigint,
                avail                           bigint,
                appointment_count_with_interval bigint,
                appointment_count               bigint,
                manual_allocation               numeric
            )
AS
$BODY$
BEGIN
    return query
        with round_robin_users as (
            select pczu.user_id, pcz.distribution_time_frame_days
            from flow.postal_code_zone pcz
                     inner join flow.postal_code_zone_user pczu
                                on pczu.postal_code_zone_id = pcz.id and pczu.postal_code_zone_user_type_id = 1 and
                                   pczu.archived is false
            where pcz.id = p_postal_code_zone_id
            ),
             lead_gen_num as (
                 select rru.user_id, count(pd.id) as lead_gen_num
                 from round_robin_users rru
                          left join brs.project_details pd on rru.user_id = pd.closer_user_id and
                                                              closer_appointment_start >= now() - interval '90 days'
                     and pd.source not in (523, 524, 530)
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
                     AND ((pd.cancelled_date is null) or
                          (pd.cancelled_date is not null and pd.cancelled_date > now()))
                          left join flow.project p on p.id = pd.project_id
                          left join flow.project_status_type pst
                                    on pst.id = p.company_project_status_type_id and pst.id != 3
                 group by rru.user_id),
             lead_gen_den as (
                 select rru.user_id, count(pd.id) as lead_gen_den
                 from round_robin_users rru
                          left join brs.project_details pd on rru.user_id = pd.closer_user_id and
                                                              closer_appointment_start >= now() - interval '90 days'
                     and pd.source not in (523, 524, 530)
                          left join flow.project p on p.id = pd.project_id
                 group by rru.user_id),
             self_gen as (
                 select rru.user_id, count(pd.id) as self_gen
                 from round_robin_users rru
                          left join brs.project_details pd on rru.user_id = pd.closer_user_id and
                                                              greatest(final_design_signed_date,
                                                                       financial_agreement_signed_date,
                                                                       first_cash_payment_paid_date,
                                                                       utility_bill_verified_date,
                                                                       proof_of_homeowners_insurance_obtained_date) >=
                                                              now() - interval '90 days'
                     and pd.source in (523, 524, 530)
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
                     AND ((pd.cancelled_date is null) or
                          (pd.cancelled_date is not null and pd.cancelled_date > now()))
                          left join flow.project p on p.id = pd.project_id
                          left join flow.project_status_type pst
                                    on pst.id = p.company_project_status_type_id and pst.id != 3
                 group by rru.user_id),
             appointment_count as (
                 select rru.user_id, count(pd2.id) as appointment_count
                 from round_robin_users rru
                          left join brs.project_details pd2 on rru.user_id = pd2.closer_user_id
                     and
                                                               closer_appointment_start between now() - interval '21 days' and now() + interval '100 days'
                 group by rru.user_id),
             appointment_count_with_interval as (
                 select rru.user_id, count(pd2.id) as appointment_count_with_interval
                 from round_robin_users rru
                          left join brs.project_details pd2 on rru.user_id = pd2.closer_user_id
                     and
                                                               closer_appointment_start between now() - (rru.distribution_time_frame_days || 'days')::interval and now() + interval '100 days'
                     and pd2.source not in (523, 524, 530)
                 group by rru.user_id),
             total_avail as (
                 select coalesce(ca.appointment_count, 0) as avail, rru.user_id
                 from round_robin_users rru
                          left join brs.cached_appointment ca on rru.user_id = ca.user_id
             )
        select foo3.postal_code_zone_user_id, foo3.user_id,
               foo3.actual_lead_allocation - foo3.total_lead_allocation as distance_from_actual_to_target,
               foo3.total_lead_allocation,
               foo3.actual_lead_allocation,
               foo3.score,
               foo3.lead_gen_num,
               foo3.lead_gen_den,
               foo3.self_gen,
               foo3.avail,
               foo3.appointment_count_with_interval,
               foo3.appointment_count,
               foo3.manual_allocation
        from (
                 select foo2.postal_code_zone_user_id, foo2.user_id,
                        foo2.actual_lead_allocation - foo2.total_lead_allocation as distance_from_actual_to_target,
                        case
                            when p_run_manual_allocation is true then
                                coalesce(foo2.manual_allocation,
                                         foo2.total_lead_allocation *
                                         (1 - foo2.sum_manual_allocation::numeric)::numeric)::numeric
                            else foo2.total_lead_allocation end                  as total_lead_allocation,
                        foo2.actual_lead_allocation,
                        foo2.score,
                        foo2.lead_gen_num,
                        foo2.lead_gen_den,
                        foo2.self_gen,
                        foo2.avail,
                        foo2.appointment_count_with_interval,
                        foo2.appointment_count,
                        foo2.manual_allocation
                 from (
                          select foo1.postal_code_zone_user_id, foo1.user_id,
                                 case
                                     when sum(foo1.score) over () = 0 then
                                         0
                                     else
                                         round(foo1.score / sum(foo1.score) over (), 10) end as total_lead_allocation,
                                 round(foo1.actual_lead_allocation, 10)                 as actual_lead_allocation,
                                 foo1.score                                       as score,
                                 foo1.lead_gen_num,
                                 foo1.lead_gen_den,
                                 foo1.self_gen,
                                 foo1.avail,
                                 foo1.appointment_count_with_interval,
                                 foo1.appointment_count,
                                 foo1.manual_allocation,
                                 foo1.sum_manual_allocation
                          from (
                                   select foo.postal_code_zone_user_id, foo.user_id,
                                          case
                                              when foo.lead_gen_den is null or foo.lead_gen_den = 0 then
                                                  case
                                                      when foo.manual_allocation is not null and p_run_manual_allocation is true
                                                          then
                                                          0
                                                      else
                                                              (foo.self_gen +
                                                               ((foo.appointment_count + foo.avail) / 3) +
                                                               ((foo.lead_gen_num + foo.self_gen) * 15))
                                                               end
                                              else
                                                  case
                                                      when foo.manual_allocation is not null and p_run_manual_allocation is true
                                                          then
                                                          0
                                                      else
                                                              ((foo.lead_gen_num / foo.lead_gen_den::numeric * 10000) +
                                                               foo.self_gen +
                                                               ((foo.appointment_count + foo.avail) / 3) +
                                                               ((foo.lead_gen_num + foo.self_gen) * 15))
                                                               end end               as score,
                                          case
                                              when sum(foo.appointment_count_with_interval) over () = 0 then
                                                  0
                                              else foo.appointment_count_with_interval /
                                                   sum(foo.appointment_count_with_interval) over () end as actual_lead_allocation,
                                          foo.lead_gen_num,
                                          foo.lead_gen_den,
                                          foo.self_gen,
                                          foo.avail,
                                          foo.appointment_count_with_interval,
                                          foo.appointment_count,
                                          foo.manual_allocation,
                                          sum(foo.manual_allocation) over ()                        as sum_manual_allocation
                                   from (
                                            select pczu.id as postal_code_zone_user_id,
                                                   pczu.user_id,
                                                   coalesce(lgn.lead_gen_num, 0)                     as lead_gen_num,
                                                   coalesce(lgd.lead_gen_den, 0)                     as lead_gen_den,
                                                   coalesce(sg.self_gen, 0)                          as self_gen,
                                                   ac.appointment_count,
                                                   coalesce(ta.avail, 0)                             as avail,
                                                   coalesce(acwi.appointment_count_with_interval, 0) as appointment_count_with_interval,
                                                   pczu.manual_allocation
                                            from flow.postal_code_zone pcz
                                                     inner join flow.postal_code_zone_user pczu
                                                                on pczu.postal_code_zone_id = pcz.id and
                                                                   pczu.postal_code_zone_user_type_id = 1 and
                                                                   pczu.archived is false
                                                     left join lead_gen_num lgn on lgn.user_id = pczu.user_id
                                                     left join lead_gen_den lgd on lgd.user_id = pczu.user_id
                                                     left join self_gen sg on sg.user_id = pczu.user_id
                                                     left join appointment_count ac on ac.user_id = pczu.user_id
                                                     left join total_avail ta on ta.user_id = pczu.user_id
                                                     left join appointment_count_with_interval acwi on acwi.user_id = pczu.user_id
                                            where pcz.id = p_postal_code_zone_id
                                            group by pczu.id, pczu.user_id, lgn.lead_gen_num, lgd.lead_gen_den, sg.self_gen,
                                                     ac.appointment_count,
                                                     pcz.distribution_time_frame_days, ta.avail,
                                                     acwi.appointment_count_with_interval,
                                                     pczu.manual_allocation) as foo
                                   group by foo.postal_code_zone_user_id, foo.user_id, foo.lead_gen_num, foo.lead_gen_den, foo.self_gen,
                                            foo.appointment_count,
                                            foo.avail, foo.appointment_count_with_interval,
                                            foo.manual_allocation) as foo1) as foo2
                 group by foo2.postal_code_zone_user_id, foo2.user_id, foo2.actual_lead_allocation, foo2.total_lead_allocation,
                          foo2.total_lead_allocation, foo2.actual_lead_allocation, foo2.score,
                          foo2.lead_gen_num,
                          foo2.lead_gen_den,
                          foo2.self_gen,
                          foo2.avail,
                          foo2.appointment_count_with_interval,
                          foo2.appointment_count,
                          foo2.manual_allocation,
                          foo2.sum_manual_allocation) as foo3;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
