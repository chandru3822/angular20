drop function if exists brs.get_current_pay(p_total_commissions numeric,
                                            p_commissions_earned numeric,
                                            p_commission_paid_to_date numeric,
                                            p_forfeited_by_closer numeric,
                                            p_forfeited_paid_to_date numeric);
CREATE OR REPLACE function brs.get_current_pay(p_total_commissions numeric,
                                               p_commissions_earned numeric,
                                               p_commission_paid_to_date numeric,
                                               p_forfeited_by_closer numeric,
                                               p_forfeited_paid_to_date numeric)
  returns table
          (
            amount_to_pay    numeric,
            forfeited_amount numeric
          )
AS
$BODY$
DECLARE
  v_forfeit_left_over numeric;
  v_diff              numeric;
  v_amount_to_forfeit numeric;
  v_amount_to_pay     numeric;
  v_abs_diff          numeric;
  v_correction        numeric;
BEGIN

  if p_commissions_earned > 0 then
    v_forfeit_left_over = p_forfeited_by_closer - p_forfeited_paid_to_date;
    v_diff = v_forfeit_left_over - (p_total_commissions - p_commissions_earned);
    v_amount_to_forfeit = greatest(v_diff, 0);

    v_amount_to_pay =
        p_commissions_earned -
        (p_commission_paid_to_date + p_forfeited_paid_to_date) -
        v_amount_to_forfeit;

    if (v_diff < 0) then
      v_abs_diff = abs(v_diff);
      v_correction = least(v_abs_diff::numeric, p_forfeited_paid_to_date::numeric);

      v_amount_to_forfeit = v_amount_to_forfeit - v_correction;
      v_amount_to_pay = v_amount_to_pay + v_correction;
    end if;
  else
    v_amount_to_pay = 0.00::numeric;
    v_amount_to_forfeit = 0.00::numeric;
  end if;

  return query
    select v_amount_to_pay, v_amount_to_forfeit;


END;
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
