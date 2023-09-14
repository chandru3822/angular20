alter table brs.override_plan_receiving_user add column  if not exists red_line_m1_allocation numeric;
alter table brs.override_plan_receiving_user add column  if not exists red_line_m2_allocation numeric;

update brs.override_plan_receiving_user opru
set red_line_m1_allocation = 0,
    red_line_m2_allocation = 0;

alter table brs.override_plan_receiving_user alter column red_line_m1_allocation set not null;
alter table brs.override_plan_receiving_user alter column red_line_m2_allocation set  not null;
