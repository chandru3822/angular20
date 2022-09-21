drop function if exists flow.get_reamortized_monthly_payment(p_rate numeric(15,9), p_periods smallint, p_principal numeric(20,2) );
  create or replace function flow.get_reamortized_monthly_payment(p_rate numeric(15,9), p_periods smallint, p_principal numeric(20,2) )
  returns numeric (38,9)
as
$BODY$
declare
  p_pmt numeric (38,9);
begin
  select p_principal
           / (power(1+p_rate,p_periods)-1)
           * (p_rate*power(1+p_rate,p_periods))
  into p_pmt;
  return p_pmt;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
