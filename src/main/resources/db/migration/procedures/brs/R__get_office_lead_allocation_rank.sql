CREATE OR REPLACE FUNCTION brs.get_office_lead_allocation_rank(p_postal_code_zone_id integer, p_time_interval integer)
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
            select up.user_id, concat(u.first_name, ' ', u.last_name) as closer_name, pcz.distribution_time_frame_days
            from flow.postal_code_zone_user pczu
                     inner join flow.user_position up on up.id = pczu.user_position_id
                     inner join flow.position p on p.id = up.position_id
                     inner join flow.postal_code_zone pcz on pcz.id = pczu.postal_code_zone_id
                     inner join flow.user u on u.id = up.user_id
            where pcz.id = p_postal_code_zone_id
              and pczu.postal_code_zone_user_type_id = 1),
             lead_gen_num as (
                 select rru.user_id, rru.closer_name, count(1) as lead_gen_num
                 from brs.project_details pd
                          inner join flow.project p on p.id = pd.project_id
                          inner join flow.project_status_type pst on pst.id = p.company_project_status_type_id
                          inner join round_robin_users rru on rru.user_id = pd.closer_user_id
                 where closer_appointment_start >= (now() at time zone 'US/Mountain')::date - p_time_interval
                   and pd.source not in (523, 524, 530) --(Closer Gen, Referral, Events - Closer Gen)
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
                                       >= (now() at time zone 'US/Mountain')::date - p_time_interval
                           else
                               greatest(final_design_signed_date, financial_agreement_signed_date,
                                        proof_of_homeowners_insurance_obtained_date, utility_bill_verified_date)
                                   >= (now() at time zone 'US/Mountain')::date - p_time_interval
                     end
                   AND ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date > now()))
                   AND (pst.id != 3)
                 group by rru.user_id, rru.closer_name),
             lead_gen_den as (
                 select rru.user_id, rru.closer_name, count(1) as lead_gen_den
                 from brs.project_details pd
                          inner join flow.project p on p.id = pd.project_id
                          inner join round_robin_users rru on rru.user_id = pd.closer_user_id
                 where closer_appointment_start >= (now() at time zone 'US/Mountain')::date - p_time_interval
                   and pd.source not in (523, 524, 530) --(Closer Gen, Referral, Events - Closer Gen)
                 group by rru.user_id, rru.closer_name),
             self_gen as (
                 select rru.user_id, rru.closer_name, count(1) * 2 as self_gen
                 from brs.project_details pd
                          inner join flow.project p on p.id = pd.project_id
                          inner join flow.project_status_type pst on pst.id = p.company_project_status_type_id
                          inner join round_robin_users rru on rru.user_id = pd.closer_user_id
                 where greatest(final_design_signed_date, financial_agreement_signed_date, first_cash_payment_paid_date,
                                utility_bill_verified_date, proof_of_homeowners_insurance_obtained_date)
                           >= (now() at time zone 'US/Mountain')::date - p_time_interval
                   and pd.source in (523, 524, 530) --(Closer Gen, Referral, Events - Closer Gen)
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
                   AND (pst.id != 3)
                 group by rru.user_id, rru.closer_name),
             appointment_count as (
                 select rru.user_id, rru.closer_name, count(1) as appointment_count
                 from brs.project_details pd2
                          inner join round_robin_users rru on rru.user_id = pd2.closer_user_id
                 where closer_appointment_start between ((now() at time zone 'US/Mountain')::date - p_time_interval) and now() + interval '100 days'
                 group by rru.user_id, rru.closer_name),
             appointment_count_with_interval as (
                 select rru.user_id, rru.closer_name, count(1) as appointment_count_with_interval
                 from brs.project_details pd2
                          inner join round_robin_users rru on rru.user_id = pd2.closer_user_id
                 where closer_appointment_start between now() - (rru.distribution_time_frame_days || 'days')::interval and now() + interval '100 days'
                 group by rru.user_id, rru.closer_name),
             total_avail as (
                 select ca.appointment_count as avail, ca.user_id
                 from brs.cached_appointment ca
                          inner join round_robin_users rru on rru.user_id = ca.user_id
             )


        select foo1.user_id,
               foo1.closer_name,
               foo1.lead_gen_fdc,
               foo1.self_gen,
               coalesce(foo1.average_availability, 0)       as average_availability,
               coalesce(foo1.score, 0)                      as score
        from (
                 select foo.user_id,
                        foo.closer_name,
                        case
                            when foo.lead_gen_den is null or foo.lead_gen_den = 0 then
                                0
                            else
                                round((foo.lead_gen_num / foo.lead_gen_den::numeric) * 100, 1) end      as lead_gen_fdc,
                        foo.self_gen                                                                    as self_gen,
                        ((foo.appointment_count + foo.avail) / 3)                                       as average_availability,
                        case
                            when foo.lead_gen_den is null or foo.lead_gen_den = 0 then
                                    foo.self_gen +
                                    ((foo.appointment_count + foo.avail) / 3)
                            else
                                    round(foo.lead_gen_num / foo.lead_gen_den::numeric * 1000 + foo.self_gen +
                                    ((foo.appointment_count + foo.avail) / 3), 1) end     as score
                 from (
                          select up.user_id,
                             concat(u.first_name, ' ', u.last_name)                as closer_name,
                                 coalesce(lgn.lead_gen_num, 0)                     as lead_gen_num,
                                 coalesce(lgd.lead_gen_den, 0)                     as lead_gen_den,
                                 coalesce(sg.self_gen, 0)                          as self_gen,
                                 ac.appointment_count,
                                 coalesce(ta.avail, 0)                             as avail,
                                 coalesce(acwi.appointment_count_with_interval, 0) as appointment_count_with_interval
                          from flow.postal_code_zone pcz
                                   inner join flow.postal_code_zone_user pczu on pczu.postal_code_zone_id = pcz.id
                                   inner join flow.user_position up on up.id = pczu.user_position_id
                                   inner join flow.position p on p.id = up.position_id
                                   inner join flow.user u on u.id = up.user_id
                                   left join lead_gen_num lgn on lgn.user_id = up.user_id
                                   left join lead_gen_den lgd on lgd.user_id = up.user_id
                                   left join self_gen sg on sg.user_id = up.user_id
                                   left join appointment_count ac on ac.user_id = up.user_id
                                   left join total_avail ta on ta.user_id = up.user_id
                                   left join appointment_count_with_interval acwi on acwi.user_id = up.user_id
                          where pcz.id = p_postal_code_zone_id
                            and pczu.postal_code_zone_user_type_id = 1
                          group by up.user_id, concat(u.first_name, ' ', u.last_name), lgn.lead_gen_num, lgd.lead_gen_den, sg.self_gen,
                                   ac.appointment_count,
                                   pcz.distribution_time_frame_days, ta.avail,
                                   acwi.appointment_count_with_interval) as foo
                 group by foo.user_id, foo.closer_name, foo.lead_gen_num, foo.lead_gen_den, foo.self_gen,
                          foo.appointment_count,
                          foo.avail, foo.appointment_count_with_interval) as foo1
        group by foo1.user_id, foo1.closer_name, foo1.lead_gen_fdc, foo1.self_gen, coalesce(foo1.average_availability, 0), coalesce(foo1.score, 0);
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
