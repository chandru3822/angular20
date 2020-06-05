CREATE OR REPLACE VIEW brs.project_rebate_payment_upcoming
            (project_id, substantial_completion_date, batch_date, payment_number, total_payments,
             payment_amount, paid_to_date, total_promotion_amount, first_name, last_name, full_name,
             street1, street2, city, state, state_abbr, postal_code, payment_id, mailing_street1, mailing_street2,
             mailing_city, mailing_state, mailing_postal_code)
as
SELECT p.id AS project_id,
       pcs.sc,
       prb.batch_date,
       (SELECT count(1) + 1
        FROM brs.project_rebate_payment
        WHERE project_rebate_payment.project_id = p.id
          AND project_rebate_payment.project_rebate_payment_state_id = 3)   AS payment_number,
       (SELECT count(1)::integer AS count
        FROM brs.project_rebate_payment
        WHERE project_rebate_payment.project_id = p.id) AS total_payments,
       prp.payment_amount,
       (SELECT sum(project_rebate_payment.payment_amount) AS sum
        FROM brs.project_rebate_payment
        WHERE project_rebate_payment.project_id = p.id
          AND project_rebate_payment.project_rebate_payment_state_id = 3)   AS paid_to_date,
       flow.get_value_for_custom_field(4,
                                       (select id from flow.custom_field where field_name='Total Promotion Amount'),
                                       p.id,
                                       4) as total_promotion_amount,
       c.first_name,
       c.last_name,
       c.first_name || ' ' || c.last_name as full_name,
       c.street1,
       c.street2,
       c.city,
       c.state,
       state.abbreviation AS state_abbr,
       c.postal_code,
       prp.id AS payment_id,
       c.mailing_street1,
       c.mailing_street2,
       c.mailing_city,
       c.mailing_state,
       c.mailing_postal_code
FROM flow.project p
         JOIN brs.project_commission_snapshot pcs ON pcs.project_id = p.id
         JOIN brs.project_rebate_payment prp ON prp.project_id = p.id
         LEFT JOIN brs.project_rebate_batch prb ON prb.id = prp.project_rebate_batch_id
         JOIN flow.contact c ON c.id = p.contact_id
         JOIN flow.state state on c.state_id = state.id
WHERE prp.project_rebate_payment_state_id = 2;
