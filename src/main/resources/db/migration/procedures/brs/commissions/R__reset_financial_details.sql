drop procedure if exists brs.reset_financial_details(p_project_id bigint);
CREATE OR REPLACE procedure brs.reset_financial_details(p_project_id bigint) AS
$BODY$
declare
  x record;
BEGIN

  if p_project_id is not null then
    perform
           brs.insert_commissions_on_project(p_project_id);
  else
    select
      brs.insert_commissions_on_project(p.project_id)
    from brs.project_details p
    where p.installation_agreement_signed_date is not null and p.final_design_complete_date is null;
  end if;

  for x in
    select foo.project_id,
           brs.get_commissions_earned(foo.project_id, 'M1',case when foo.final_design_complete_date is null and foo.installation_agreement_signed_date is not null then
                                                              true else false end) as commission_earned_m1,
           brs.get_overrides_earned(foo.project_id, 'M1')   as overrides_earned_m1,
           brs.get_commissions_earned(foo.project_id, 'M2') as commission_earned_m2,
           brs.get_overrides_earned(foo.project_id, 'M2')   as overrides_earned_m2,
           brs.get_total_commissions_amount(foo.project_id,case when foo.final_design_complete_date is null and foo.installation_agreement_signed_date is not null then
                                                              true else false end) as total_commissions,
           brs.get_total_overrides_amount(foo.project_id)   as total_overrides
    from (select pd.project_id,
                pd.final_design_complete_date,
                pd.installation_agreement_signed_date
          from brs.project_details pd
          where (pd.final_design_complete_date is not null or pd.installation_agreement_signed_date is not null)
            and case when p_project_id is not null then  project_id = p_project_id
                else 1=1 end
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

  update brs.financial_details fd
  set total_commissions_paid_to_date = 0,
      total_commissions_adjustments_paid_to_date = 0,
      total_overrides_paid_to_date = 0,
      total_commissions_forfeited_paid_to_date = 0
  where project_id = p_project_id;

  for x in select project_id, coalesce(sum(amount), 0) amount1
           from brs.project_commission_ledger pcl
           where ledger_type_id = 1 and
             case when p_project_id is not null then  project_id = p_project_id
                  else 1=1 end
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
             and case
                   when p_project_id is not null then project_id = p_project_id
                   else 1 = 1 end
           group by project_id

    loop
      update brs.financial_details pd
      set total_commissions_adjustments_paid_to_date = x.amount1
      where project_id = x.project_id;
      commit;

    end loop;


  for x in select project_id, coalesce(sum(paid_to_date), 0) amount1
           from brs.project_commission_ledger pcl
           where ledger_type_id = 3 and
             case
               when p_project_id is not null then project_id = p_project_id
               else 1 = 1 end
           group by project_id

    loop
      update brs.financial_details pd
      set total_overrides_paid_to_date = x.amount1
      where project_id = x.project_id;
      commit;

    end loop;

  for x in select project_id, coalesce(sum(amount), 0) amount1
           from brs.project_commission_ledger pcl
           where ledger_type_id = 7 and
             case
               when p_project_id is not null then project_id = p_project_id
               else 1 = 1 end
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
