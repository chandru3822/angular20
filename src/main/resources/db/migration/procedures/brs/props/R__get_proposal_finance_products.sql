drop function if exists brs.get_proposal_finance_products(p_version_id bigint,p_financial_product_id bigint);
drop function if exists brs.get_proposal_finance_products(p_version_id bigint,p_financial_product_id bigint,p_direct_to_consumer bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_finance_products(p_version_id bigint,p_financial_product_id bigint,p_direct_to_consumer bigint default null)
    returns table(apr numeric,
                  financial_option text,
                  reamortized_payment_factor_without_itc_paydown numeric,
                  loan_term_id bigint,
                  loan_term numeric,
                  dealer_fee numeric,
                  reamortization_factor numeric,
                  financier_id bigint,
                  financier text,
                  initial_payment_factor numeric) AS
$BODY$
declare


BEGIN
  if p_direct_to_consumer is not null then
    return query
    select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 111)') ->> 'value')::numeric   as apr,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 320)') ->> 'value')::text      as financial_option,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 148)') ->> 'value')::numeric   as reamortized_payment_factor_without_itc_paydown,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 110)') ->> 'intValue')::bigint   as loan_term_id,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 110)') ->> 'value')::numeric   as loan_term,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 114)') ->> 'value')::numeric   as dealer_fee,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 116)') ->> 'value')::numeric   as reamortization_factor,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 102)') ->> 'intValue')::bigint as financier_id,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 102)') ->> 'value')::text      as financier,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 115)') ->> 'value')::numeric   as initial_payment_factor
    from brs.get_proposal_version_value(p_version_id, array [(374, null, p_direct_to_consumer, null)::ProposalFieldFilter],
                                        'PROPOSAL_FINANCE_PRODUCTS');
  else
  return query
      select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 111)') ->> 'value')::numeric   as apr,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 320)') ->> 'value')::text      as financial_option,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 148)') ->> 'value')::numeric   as reamortized_payment_factor_without_itc_paydown,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 110)') ->> 'intValue')::bigint   as loan_term_id,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 110)') ->> 'value')::numeric   as loan_term,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 114)') ->> 'value')::numeric   as dealer_fee,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 116)') ->> 'value')::numeric   as reamortization_factor,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 102)') ->> 'intValue')::bigint as financier_id,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 102)') ->> 'value')::text      as financier,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 115)') ->> 'value')::numeric   as initial_payment_factor
      from brs.get_proposal_version_value(p_version_id, array [(128, null, p_financial_product_id, null)::ProposalFieldFilter],
                                          'PROPOSAL_FINANCE_PRODUCTS');
  end if;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
