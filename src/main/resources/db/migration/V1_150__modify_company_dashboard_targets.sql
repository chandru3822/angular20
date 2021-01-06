alter table if exists brs.company_dashboard_targets
  add column if not exists final_designs_completed_brs integer;

alter table if exists brs.company_dashboard_targets
  add column if not exists final_designs_completed_partner integer;

alter table if exists brs.company_dashboard_targets
  drop column if exists final_designs_approved_brs;

alter table if exists brs.company_dashboard_targets
  drop column if exists final_designs_approved_partner;

update brs.company_dashboard_targets
set final_designs_completed_brs = 0,
    final_designs_completed_partner = 0
where final_designs_completed_brs is null
  and final_designs_completed_partner is null;
