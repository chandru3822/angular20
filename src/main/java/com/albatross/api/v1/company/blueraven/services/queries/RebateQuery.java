package com.albatross.api.v1.company.blueraven.services.queries;

public class RebateQuery {

  //language=PostgreSQL
  public final static String getPaymentStates = """
    select id, name from brs.project_rebate_payment_state
    """;

  //language=PostgreSQL
  public final static String updateTotalPromotionAmount = """
    update flow.project_process_step_custom_field_value
    set numeric_value = :newTotal ,
        date_modified = now()
    where id = (select ppscfv.id
                from flow.project_process_step_custom_field_value ppscfv
                where ppscfv.custom_field_group_assignment_id = 19462
                  and ppscfv.project_process_step_id = (
                  select id from flow.project_process_step pps
                  where pps.project_id = :projectId
                    and pps.process_step_id = 3355
                    and pps.main is true
                ));
    """;

  //language=PostgreSQL
  public final static String getOne = """
    select prp.id,
           prp.payment_amount,
           prp.created_date,
           prp.created_by_user_id,
           prp.approved_by_user_id,
           prp.approved_date,
           prp.project_id,
           prp.processed_by_user_id,
           prp.processed_date,
           prp.project_rebate_payment_state_id as payment_state_id
         from brs.project_rebate_payment prp
           INNER JOIN flow.project p on p.id = prp.project_id
         where prp.id = :paymentId
    """;

  //language=PostgreSQL
  public final static String approvePayments = """
    update brs.project_rebate_payment
    set approved_by_user_id = :userId,
        approved_date = (now() at time zone 'US/Mountain')::date,
        project_rebate_payment_state_id = 2,
        updated_by_user_id = :userId,
        updated_date = now()
    where id in (:paymentIds);
    """;

  //language=PostgreSQL
  public final static String assignPaymentsToBatch = """
    update brs.project_rebate_payment
    set updated_by_user_id = :userId,
        updated_date = (now() at time zone 'US/Mountain')::date,
        project_rebate_payment_state_id = 3,
        project_rebate_batch_id = :batchId
    where id in (:paymentIds);
    """;

  //language=PostgreSQL
  public final static String createBatch = """
    insert into brs.project_rebate_batch(project_rebate_payment_ids, updated_by_user_id) VALUES (array[ :paymentIds ]::bigint[], :userId);
    """;

  //language=PostgreSQL
  public final static String getBatchDetails = """
    select drb.id,
           drb.batch_date,
           drb.updated_date,
           drb.voided_batch,
           drb.updated_by_user_id,
           case when drb.updated_by_user_id is null then
             'System'
           else concat(u.first_name, ' ', u.last_name) end as updated_by_user,
             coalesce((
              SELECT array_to_json(array_agg(row_to_json(rebatePayments)))
              FROM (
                    select prp.id,
                      prp.payment_amount as "paymentAmount",
                      prp.payment_nbr as "paymentNbr",
                      pd.project_name as "projectName",
                      prp.check_number as "checkNumber",
                      prp.project_rebate_payment_state_id as "paymentStateId",
                      prp.project_id as "projectId"
                    from brs.project_rebate_payment prp
                      INNER JOIN flow.project p on p.id = prp.project_id
                      left join brs.project_details pd on pd.project_id = p.id
                    where prp.project_rebate_batch_id = drb.id
                    group by prp.id, prp.payment_nbr, pd.contact_name
                    order by payment_nbr) rebatePayments), '[]') AS "rebatePayments"
         from brs.project_rebate_batch drb
           LEFT JOIN flow."user" u on u.id = drb.updated_by_user_id
         where drb.id = :batchId
    """;

  //language=PostgreSQL
  public final static String voidBatch = """
    update brs.project_rebate_batch
    set voided_batch = true,
        updated_by_user_id = :userId,
        updated_date = now()
    where id = :batchId
    """;

  //language=PostgreSQL
  public final static String voidSinglePayment = """
    update brs.project_rebate_payment
    set updated_by_user_id = :userId,
        updated_date = now(),
        project_rebate_payment_state_id = 5,
        void_note = :note
    where id = :paymentId
    """;

  //language=PostgreSQL
  public final static String unvoidSinglePayment = """
    update brs.project_rebate_payment
    set updated_by_user_id = :userId,
        updated_date = now(),
        project_rebate_payment_state_id = 3,
        void_note = ''
    where id = :paymentId
    """;

  //language=PostgreSQL
  public final static String updatePaymentNote = """
    update brs.project_rebate_payment
    set updated_by_user_id = :userId,
        updated_date = now(),
        void_note = :note
    where id = :paymentId
    """;

  //language=PostgreSQL
  public final static String voidBatchPayments = """
    update brs.project_rebate_payment
    set project_rebate_batch_id = null,
        updated_by_user_id = :userId,
        updated_date = now(),
        project_rebate_payment_state_id = 1,
        check_number = null
    where project_rebate_batch_id = :batchId
    """;

  //language=PostgreSQL
  public final static String getAllBatches = """
    select drb.id,
           drb.batch_date,
           drb.updated_date,
           drb.voided_batch,
           drb.updated_by_user_id,
           case when drb.updated_by_user_id is null then
           'System'
           else concat(u.first_name, ' ', u.last_name) end as updated_by_user
         from brs.project_rebate_batch drb
           LEFT JOIN flow."user" u on u.id = drb.updated_by_user_id
         order by drb.batch_date desc
    """;

  //language=PostgreSQL
  public final static String getPaymentsPending = """
    select * from (
        select pd.project_id,
               pd.project_name,
               (select concat(u.first_name, ' ', u.last_name) from flow.user u where id = :createdBy) as createdBy,
               pd.substantial_completion_date substantialCompletionDate,
               pd.primary_financier_name as financier,
               pd.num_of_promotion_payments as numberOfPromotionPayments,
               pd.product_name as product,
               pd.total_promotion_amount,
               (select count(*) from brs.project_rebate_payment where project_id = pd.project_id) as numOfPayments
        from brs.project_details pd
        where ((pd.substantial_completion_date is not null and
                pd.product in  (295,293)) or
               (pd.substantial_completion_date is not null and
                pd.substantial_completion_date  <= (now() AT TIME ZONE 'US/Mountain') - interval '18 months'  and
                                              pd.product =  19424)) and
                pd.company_id = 3 and
            pd.archived is false
        group by pd.project_id,
                 pd.contact_name,
                 (select concat(u.first_name, ' ', u.last_name) from flow.user u where id = :createdBy),
                 pd.substantial_completion_date,
                 pd.primary_financier_name,
                 pd.num_of_promotion_payments,
                 pd.product_name,
                 pd.total_promotion_amount,
                 numOfPayments
    ) as payments where numOfPayments < 1
    """;

  //language=PostgreSQL
  public final static String getPaymentsNeedApproval = """
    select prp.id payment_id,
           pd.project_id,
           pd.project_name,
           pd.substantial_completion_date substantialCompletionDate,
           (select batch_date::date
            from brs.project_rebate_payment prp1
                   inner join brs.project_rebate_batch drb on drb.id = prp1.project_rebate_batch_id
            where project_rebate_payment_state_id = 3
              and prp1.project_id = pd.project_id
            order by payment_nbr desc limit 1) as last_payment_date,
           prp.payment_amount,
           coalesce((select sum(prp2.payment_amount)from brs.project_rebate_payment prp2 where prp2.project_id = pd.project_id and project_rebate_payment_state_id = 3),0) total_paid,
           (select max(payment_nbr) from brs.project_rebate_payment where project_id = pd.project_id and project_rebate_payment_state_id = 3) last_payment,
           (select min(payment_nbr) from brs.project_rebate_payment where project_id = pd.project_id and project_rebate_payment_state_id = 1) nextScheduledPayment,
           prps.name state,
           case when (select count(1) from brs.project_rebate_payment where project_id = pd.project_id and payment_nbr < prp.payment_nbr and project_rebate_payment_state_id=1)>0 then false else true end approvable,
           pd.primary_financier_name as financier,
           pd.num_of_promotion_payments as numberOfPromotionPayments,
           pd.product_name as product,
           pd.total_promotion_amount,
           (pd.total_promotion_amount - (select sum(prp2.payment_amount) from brs.project_rebate_payment prp2 where prp2.project_id = pd.project_id and project_rebate_payment_state_id = 3)) balance_owed,
           false as selected
    from brs.project_details pd
           inner join brs.project_rebate_payment prp on pd.project_id = prp.project_id
           inner join brs.project_rebate_payment_state prps on prp.project_rebate_payment_state_id = prps.id
    where prp.payment_nbr = (select min(payment_nbr) from brs.project_rebate_payment prp1 where prp.project_id = prp1.project_id and prp1.project_rebate_payment_state_id = 1)
      and pd.archived is false
    """;

  //language=PostgreSQL
  public final static String getPaymentsUnbalanced = """
    select * from (
     select p.id project_id,
     p.project_name project_name,
     pd.substantial_completion_date substantialCompletionDate,
     sum(prp.payment_amount) payment_amount,
     coalesce((select sum(prp2.payment_amount)from brs.project_rebate_payment prp2 where prp2.project_id = p.id and project_rebate_payment_state_id = 3),0) total_paid,
     pd.primary_financier_name as financier,
     pd.num_of_promotion_payments as numberOfPromotionPayments,
     pd.product_name as product,
     pd.total_promotion_amount
     from flow.project p
       inner join brs.project_rebate_payment prp on p.id = prp.project_id
       left join brs.project_details pd on pd.project_id = p.id
     where p.archived is false
       group by p.id,
       pd.contact_name,
       pd.substantial_completion_date,
       pd.primary_financier_name,
       num_of_promotion_payments,
       pd.product_name,
       total_promotion_amount,
       coalesce((select sum(prp2.payment_amount) from brs.project_rebate_payment prp2 where prp2.project_id = p.id and project_rebate_payment_state_id = 3),0),
       (select concat(u.first_name, ' ', u.last_name) from flow.user u where id = prp.created_by_user_id)
    ) payments where ROUND(payments.total_promotion_amount) != ROUND(payments.total_paid) AND (ROUND(payments.total_promotion_amount) - ROUND(payments.total_paid) > 0)
    """;

  //language=PostgreSQL
  public final static String getRebateDetails = """
    select array_to_json(array_agg(row_to_json(results)))
       from (
       select p.id project_id,
       p.project_name project_name,
       pd.substantial_completion_date substantialCompletionDate,
       (case when num_of_promotion_payments = 0 then 0
                 else (total_promotion_amount)/(num_of_promotion_payments)::numeric end) as payment_amount,
       c.id as contact_id,
       c.street1,
       c.street2,
       c.city,
       s.state,
       c.postal_code,
       c.mailing_street1,
       c.mailing_street2,
       c.mailing_city,
       (select s.abbreviation from flow.state s inner join flow.company_state cs on  s.id = cs.state_id
                     where cs.id = c.mailing_company_state_id) as mailing_state_abbr,
       c.mailing_company_state_id as mailing_state_id,
       c.mailing_postal_code,
       pd.primary_financier_name as financier,
       pd.num_of_promotion_payments as numberOfPromotionPayments,
       pd.product_name as product,
       pd.total_promotion_amount,
       coalesce((select sum(prp2.payment_amount)from brs.project_rebate_payment prp2 where prp2.project_id = p.id and project_rebate_payment_state_id = 3),0) total_paid,
       (select sum(prp2.payment_amount)from brs.project_rebate_payment prp2 where prp2.project_id = p.id and project_rebate_payment_state_id = 3) payment_sum,
       ((select sum(payment_amount) from brs.project_rebate_payment drp3
           where drp3.project_id = p.id and project_rebate_payment_state_id != 4) < (total_promotion_amount)::numeric) red_balanced_owed,
       (total_promotion_amount - (select sum(prp2.payment_amount) from brs.project_rebate_payment prp2 where prp2.project_id = p.id and project_rebate_payment_state_id = 3)) balance_owed,
       (select array_to_json(array_agg(row_to_json(payment_history))) from
       (select drp.id,
       batch_date,
       payment_amount,
       s.name,
       s.id as payment_state_id,
       payment_nbr,
       drb.id as batch_id,
       drp.check_number,
       drp.void_note
       from brs.project_rebate_payment drp
       left join brs.project_rebate_batch drb on drb.id = drp.project_rebate_batch_id
       inner join brs.project_rebate_payment_state s on project_rebate_payment_state_id = s.id where project_id = p.id order by payment_nbr)payment_history) payment_history
       from flow.project p
         left join brs.project_details pd on pd.project_id = p.id
         inner join brs.project_rebate_payment drp on p.id = drp.project_id
         inner join flow.contact c on c.id = p.contact_id
         left outer join flow.company_state cs on cs.id = c.company_state_id
         left outer join flow.state s on s.id = cs.state_id
       where p.id = :projectId
       group by p.id,
       pd.contact_name,
       pd.substantial_completion_date,
       total_promotion_amount,
       num_of_promotion_payments,
       payment_amount,
       c.id,
       c.street1,
       c.street2,
       c.city,
       s.state,
       c.postal_code,
       c.mailing_street1,
       c.mailing_street2,
       c.mailing_city,
       s.abbreviation,
       c.mailing_postal_code,
       pd.primary_financier_name,
       pd.product_name,
       coalesce((select sum(prp2.payment_amount)from brs.project_rebate_payment prp2 where prp2.project_id = p.id and project_rebate_payment_state_id = 3),0)
     ) results
    """;

  //language=PostgreSQL
  public final static String getCheckNumber = """
    select nextval('brs.rebate_check_nbr_seq')
    """;
}
