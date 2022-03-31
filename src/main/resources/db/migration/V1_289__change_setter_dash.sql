drop function if exists brs.rpt_setter_funnel_standard_drilldown(date, date, integer, integer[], integer[]);
drop function if exists brs.rpt_setter_funnel_standard_drilldown(date, date, integer[], integer[]);
drop function if exists brs.rpt_setter_funnel_cohort_drilldown(date, date, integer[], integer[]);
drop function if exists brs.limit_by_org_for_setters(integer[], integer[], date);
drop function if exists brs.rpt_setter_funnel_standard(date, date, numeric, integer[], integer[]);
drop function if exists brs.rpt_setter_funnel_cohort(date, date, numeric, integer[], integer[]);

drop table if exists brs.setter_funnel;


alter table brs.funnel
add column if not exists unique_behavior boolean not null default false;

alter table brs.funnel
  add column if not exists expectation int;

alter table brs.funnel
drop column if exists setter_include_not_pitched_or_missed;

insert into brs.funnel(name, ratio, expectation, display_order, funnel_type_id, closer_appt_outcome_int_values, unique_behavior)
select 'Pitch Percentage', 0, 60, 4, 4, null, true
where not exists(
  select id from brs.funnel
  where name = 'Pitch Percentage'
  and funnel_type_id = 4
  )
;
