-- DROP FUNCTION IF EXISTS brs.get_goodleap_financial_option(varchar, varchar, bigint);
DROP FUNCTION IF EXISTS brs.get_goodleap_financial_option(varchar, varchar, varchar, bigint);
CREATE OR REPLACE FUNCTION brs.get_goodleap_financial_option(p_loan_type varchar, p_loan_term varchar, p_interest_rate varchar,
                                                             p_proposal_log_history_id bigint default null)
  returns text AS
$BODY$
declare
  v_financial_option text;
  v_default_option   text = 'blueraven';

BEGIN
  if (position('loanpal' in lower(p_loan_type)) > 0)
  then
    select financial_option
    into v_financial_option
    from brs.goodleap_financial_option_backward_compat gfobc
    where gfobc.archived is false
      and p_loan_term = gfobc.loan_term
      and p_interest_rate = gfobc.interest_rate;

    --if they pass in the proposal_log_history_id it means they want to update that record with this value
    --only update it if a non-default value is found
    if (p_proposal_log_history_id is not null and v_financial_option is not null)
    then
      update brs.proposal_log_history plh
      set financial_option = v_financial_option
      where plh.id = p_proposal_log_history_id;
    end if;
  end if;

  return coalesce(v_financial_option, v_default_option)::text;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
