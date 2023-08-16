drop procedure if exists brs.reset_financial_details();
CREATE OR REPLACE procedure brs.reset_financial_details() AS
$BODY$
declare
  x record;
BEGIN

  for x in
    select foo.project_id,
           brs.get_commissions_earned(foo.project_id, 'M1') as commission_earned_m1,
           brs.get_overrides_earned(foo.project_id, 'M1')   as overrides_earned_m1,
           brs.get_commissions_earned(foo.project_id, 'M2') as commission_earned_m2,
           brs.get_overrides_earned(foo.project_id, 'M2')   as overrides_earned_m2,
           brs.get_total_commissions_amount(foo.project_id) as total_commissions,
           brs.get_total_overrides_amount(foo.project_id)   as total_overrides
    from (select pd.project_id
          from brs.project_details pd
          where pd.final_design_complete_date is not null
           --and project_id = 807435
         ) as foo

    loop
      update brs.financial_details pd
      set commissions_earned_m1 = x.commission_earned_m1,
          overrides_earned_m1   = x.overrides_earned_m1,
          commissions_earned_m2 = x.commission_earned_m2,
          overrides_earned_m2   = x.overrides_earned_m2,
          total_commissions     = x.total_commissions,
          total_overrides       = x.total_overrides
      where project_id = x.project_id;
      commit;

    end loop;


  for x in select project_id, coalesce(sum(amount), 0) amount1
           from brs.project_commission_ledger pcl
           where ledger_type_id = 1
           group by project_id

    loop
      update brs.financial_details pd
      set total_commissions_paid_to_date = x.amount1
      where project_id = x.project_id;
      commit;

    end loop;

  for x in select project_id, coalesce(sum(amount), 0) amount1
           from brs.project_commission_ledger pcl
           where ledger_type_id = 2
           group by project_id

    loop
      update brs.financial_details pd
      set total_commissions_adjustments_paid_to_date = x.amount1
      where project_id = x.project_id;
      commit;

    end loop;


  for x in select project_id, coalesce(sum(paid_to_date), 0) amount1
           from brs.project_commission_ledger pcl
           where ledger_type_id = 3
           group by project_id

    loop
      update brs.financial_details pd
      set total_overrides_paid_to_date = x.amount1
      where project_id = x.project_id;
      commit;

    end loop;

  for x in select project_id, coalesce(sum(amount), 0) amount1
           from brs.project_commission_ledger pcl
           where ledger_type_id = 7
           group by project_id

    loop
      update brs.financial_details pd
      set total_commissions_forfeited_paid_to_date = x.amount1
      where project_id = x.project_id;
      commit;

    end loop;


END;
$BODY$
  LANGUAGE plpgsql;
