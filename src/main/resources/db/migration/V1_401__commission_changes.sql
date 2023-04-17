insert into brs.ledger_type(id, ledger_type)
(select 7,'FORFEITED_COMMISSION'
 where not exists(select id from brs.ledger_type as l where l.ledger_type = 'FORFEITED_COMMISSION'));


alter table brs.project_commission_snapshot add column  if not exists commission_forfeited_paid_to_date numeric;
alter table brs.project_commission_snapshot add column  if not exists commission_forfeited_by_closer numeric;
