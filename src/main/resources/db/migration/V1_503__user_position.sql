alter table flow.user_position add column if not exists sales_org_id bigint;
alter table flow.user_positions_vw add column if not exists sales_org_id bigint;
alter table flow.user_positions_vw add column if not exists sales_org_name text;
alter table brs.user_residual_snapshot add column if not exists residual_plan_id bigint;
