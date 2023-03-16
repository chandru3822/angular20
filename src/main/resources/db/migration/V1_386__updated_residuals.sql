alter table brs.user_residual_snapshot add column if not exists current_clawbacks_in_period numeric;
alter table brs.user_residual_snapshot add column if not exists existing_clawbacks numeric;
alter table brs.residual_plan add column if not exists default_plan boolean not null default false;
update brs.residual_plan rp set default_plan = true where id = 2;
create unique index if not exists residual_plan_default_plan_udx
  on brs.residual_plan (default_plan) where residual_plan.default_plan is true;


alter table brs.residual
  add column if not exists period_start date;
alter table brs.residual
  add column if not exists grace_period_end date;

DROP FUNCTION IF EXISTS brs.get_residual_account_details(date);

alter table brs.residual
  add column if not exists previous_grace_period_end date;


ALTER TABLE brs.user_residual ALTER COLUMN date_created SET DEFAULT now();
ALTER TABLE brs.user_residual ALTER COLUMN date_modified SET DEFAULT now();

ALTER TABLE brs.residual_plan_user ALTER COLUMN date_created SET DEFAULT now();
ALTER TABLE brs.residual_plan_user ALTER COLUMN date_modified SET DEFAULT now();

drop function if exists brs.get_residual_fds_qualified_this_period(p_closer_user_id bigint,p_include_cancel boolean);
drop function if exists brs.get_closer_residual_details(p_closer_user_id bigint);
