--TODO add the new data view table first.
insert into flow.feature(feature_name, feature_code, feature_path)
 select 'Financial Details','FINANCIAL_DETAILS',null
 where not exists (select id from flow.feature as f where f.feature_code = 'FINANCIAL_DETAILS');

alter table flow.data_view add column if not exists feature_id bigint;

alter table flow.data_view drop constraint  if exists dv_feature_id_fk;
alter table flow.data_view
  add CONSTRAINT dv_feature_id_fk FOREIGN KEY (feature_id)
    REFERENCES flow.feature (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION;

update flow.data_view
set feature_id = (select id from flow.feature f where f.feature_code = 'FINANCIAL_DETAILS')
where view_name = 'financial_details';

--TODO CARLIN TO FIND OUT WHO GETS ACCESS WHETHER IT'S BY POSITION OR INDIVIDUAL USER

insert into flow.unique_behavior_type(unique_behavior_type, date_created, date_modified, created_by_id, modified_by_id, archived, description, data_view, return_data_type_id, unique_behavior_code)
  (select 'COMMISSION_EARNED_TRIGGER',now(),now(),2350555,2350555,false,'returns the value for Commissions earned',true,4,'COMMISSION_EARNED_TRIGGER'
   where not exists (select id from flow.unique_behavior_type as ubt where ubt.unique_behavior_code = 'COMMISSION_EARNED_TRIGGER'));


insert into flow.unique_behavior_type(unique_behavior_type, date_created, date_modified, created_by_id, modified_by_id, archived, description, data_view, return_data_type_id, unique_behavior_code)
  (select 'OVERRIDES_EARNED_TRIGGER',now(),now(),2350555,2350555,false,'returns the value for overrides earned',true,4,'OVERRIDES_EARNED_TRIGGER'
   where not exists (select id from flow.unique_behavior_type as ubt where ubt.unique_behavior_code = 'OVERRIDES_EARNED_TRIGGER'));

insert into flow.unique_behavior_type(unique_behavior_type, date_created, date_modified, created_by_id, modified_by_id, archived, description, data_view, return_data_type_id, unique_behavior_code)
  (select 'TOTAL_COMMISSIONS_TRIGGER',now(),now(),2350555,2350555,false,'returns the value for Total Commissions',true,4,'TOTAL_COMMISSIONS_TRIGGER'
   where not exists (select id from flow.unique_behavior_type as ubt where ubt.unique_behavior_code = 'TOTAL_COMMISSIONS_TRIGGER'));

insert into flow.unique_behavior_type(unique_behavior_type, date_created, date_modified, created_by_id, modified_by_id, archived, description, data_view, return_data_type_id, unique_behavior_code)
  (select 'TOTAL_OVERRIDES_TRIGGER',now(),now(),2350555,2350555,false,'returns the value for Total Overrides',true,4,'TOTAL_OVERRIDES_TRIGGER'
   where not exists (select id from flow.unique_behavior_type as ubt where ubt.unique_behavior_code = 'TOTAL_OVERRIDES_TRIGGER'));

drop function if exists brs.get_commissions_earned(p_project_ids bigint[], p_period_end date);
drop function if exists brs.get_overrides_earned(p_project_ids bigint[],
                                                 p_period_end date,
                                                 p_user_id bigint);

drop function if exists flow.execute_data_view_field_configs(p_contains_children boolean,
                                                             p_value text,
                                                             p_dvfc_id bigint,
                                                             p_id bigint,
                                                             p_sql text,
                                                             p_field_to_update varchar,
                                                             p_update_first_value_only boolean,
                                                             p_update_first_value_only_id varchar,
                                                             p_is_last_row boolean,
                                                             p_data_type_id bigint);

drop function if exists flow.get_unique_behavior_value(p_unique_behavior_code text, p_value text,
                                                       p_id bigint,
                                                       p_type varchar);


alter table brs.financial_details add column  if not exists commission_plan_id bigint;
alter table brs.financial_details add column  if not exists commission_plan_status text;
alter table brs.financial_details add column  if not exists commission_plan text;
alter table brs.financial_details add column  if not exists override_plan_id bigint;
alter table brs.financial_details add column  if not exists override_plan_status text;
alter table brs.financial_details add column  if not exists override_plan text;

alter table brs.financial_details add column  if not exists residual_plan_id bigint;
alter table brs.financial_details add column  if not exists residual_plan_status text;
alter table brs.financial_details add column  if not exists residual_plan text;

create index if not exists fd_commission_plan_id_idx
  on brs.financial_details (commission_plan_id);
create index if not exists fd_commission_plan_status_idx
  on brs.financial_details (commission_plan_status);
create index if not exists fd_commission_plan_idx
  on brs.financial_details (commission_plan);
create index if not exists fd_override_plan_id_idx
  on brs.financial_details (override_plan_id);
create index if not exists fd_override_plan_status_idx
  on brs.financial_details (override_plan_status);
create index if not exists fd_override_plan_idx
  on brs.financial_details (override_plan);

create index if not exists fd_residual_plan_id_idx
  on brs.financial_details (residual_plan_id);
create index if not exists fd_residual_plan_status_idx
  on brs.financial_details (residual_plan_status);
create index if not exists fd_residual_plan_idx
  on brs.financial_details (residual_plan);

alter table brs.financial_details add column if not exists total_commissions_paid_to_date numeric;
alter table brs.financial_details add column if not exists total_overrides_paid_to_date numeric;
alter table brs.financial_details add column if not exists total_commissions_forfeited_paid_to_date numeric;
alter table brs.financial_details add column if not exists total_commissions_adjustments_paid_to_date numeric;
alter table brs.financial_details add column if not exists total_overrides numeric;
create index if not exists fd_total_commissions_paid_to_date_idx
  on brs.financial_details (total_commissions_paid_to_date);
create index if not exists fd_total_overrides_paid_to_date_idx
  on brs.financial_details (total_overrides_paid_to_date);
create index if not exists fd_total_commissions_forfeited_paid_to_date_idx
  on brs.financial_details (total_commissions_forfeited_paid_to_date);
create index if not exists fd_total_commissions_adjustments_paid_to_date_idx
  on brs.financial_details (total_commissions_adjustments_paid_to_date);

create index if not exists fd_project_id_idx
  on brs.financial_details (project_id);

create index if not exists fd_contact_idx
  on brs.financial_details (contact_id);

create index if not exists financial_details_total_overrides_idx
  on brs.financial_details (total_overrides);




DO
$$
  BEGIN
    IF EXISTS(SELECT *
              FROM information_schema.columns
              WHERE table_name = 'financial_details'
                and column_name = 'final_design_complete_date_cfv_id')
    THEN
      alter table brs.financial_details
        rename column final_design_complete_date_cfv_id to final_design_complete_date_ppscfv_id;
    END IF;
  END
$$;


DO
$$
  BEGIN
    IF EXISTS(SELECT *
              FROM information_schema.columns
              WHERE table_name = 'financial_details'
                and column_name = 'substantial_completion_date_cfv_id')
    THEN
      alter table brs.financial_details
        rename column substantial_completion_date_cfv_id to substantial_completion_date_ppsecfv_id;
    END IF;
  END
$$;


-- delete
-- from flow.data_view_field_config dvfc
-- where field_to_update = 'source'
--   and custom_field_group_assignment_id = 395;
--
-- delete from flow.data_view_maintenance dvm
-- where data_view_field_config_id in (
--   select dvfc.id
--   from flow.data_view_field_config dvfc
--   where field_to_update = 'source'
--     and custom_field_group_assignment_id = 395
-- );
--
-- delete from flow.data_view_child_field_config dvcfc
-- where data_view_field_config_id in (
--   select dvfc.id
--   from flow.data_view_field_config dvfc
--   where field_to_update = 'source'
--     and custom_field_group_assignment_id = 395
-- );


-- DO
-- $do$
--   declare
--     x record;
--
--   BEGIN
--     for x in select  pd.project_id,
--                      brs.get_commissions_earned(pd.project_id) as commission_earned,
--                      brs.get_overrides_earned(pd.project_id) as overrides_earned,
--                      brs.get_total_commissions_amount(pd.project_id ) as total_commissions,
--                      brs.get_total_overrides_amount(pd.project_id ) as total_overrides
--              from brs.project_details pd
--              where pd.final_design_complete_date is not null
--
--       loop
--         update brs.financial_details pd
--         set commissions_earned = x.commission_earned,
--             overrides_earned = x.overrides_earned,
--           total_commissions = x.total_commissions,
--           total_overrides = x.total_overrides
--         where project_id = x.project_id;
--         commit;
--
--       end loop;
--
--   end
-- $do$;


-- DO
-- $do$
--   declare
--     x record;
--
--   BEGIN
--     for x in select  pd.project_id,
--                      brs.get_commissions_earned(pd.project_id) as commission_earned,
--                      brs.get_overrides_earned(pd.project_id) as overrides_earned
--              from brs.project_details pd
--               where pd.substantial_completion_date is not null
--
--       loop
--         update brs.project_details pd
--         set commissions_earned = x.commission_earned,
--             overrides_earned = x.overrides_earned
--         where project_id = x.project_id;
--         commit;
--
--       end loop;
--
--   end
-- $do$;


-- DO
-- $do$
--   declare
--     x record;
--
--   BEGIN
--     for x in select  cp.id,cp.name,cps.status_type,pc.project_id
--              from brs.project_commission pc
--              inner join brs.commission_plan cp on cp.id = pc.commission_plan_id
--              left join brs.commission_plan_status cps on cps.id = cp.status_id
--
--
--       loop
--         update brs.financial_details pd
--         set commission_plan_id = x.id,
--             commission_plan = x.name,
--             commission_plan_status = x.status_type
--         where project_id = x.project_id;
--         commit;
--
--       end loop;
--
--   end
-- $do$;

-- DO
-- $do$
--   declare
--     x record;
--
--   BEGIN
--     for x in select  op.id,op.name,ops.status_type,po.project_id
--              from brs.project_override po
--                     inner join brs.override_plan op on op.id = po.override_plan_id
--                     left join brs.override_plan_status ops on ops.id = op.status_id
--
--
--       loop
--         update brs.financial_details pd
--         set override_plan_id = x.id,
--             override_plan = x.name,
--             override_plan_status = x.status_type
--         where project_id = x.project_id;
--         commit;
--
--       end loop;
--
--   end
-- $do$;


-- DO
-- $do$
--   declare
--     x record;
--
--   BEGIN
--     for x in select pd.project_id
--       from brs.project_details pd
--       inner join brs.financial_details fd on fd.project_id = pd.project_id and fd.residual_plan_id is null
--       inner join brs.residual_plan_user rpu on rpu.user_id = pd.closer_user_id  and rpu.residual_plan_id =1
--
--     loop
--         update brs.financial_details pd
--         set residual_plan_id = 1,
--             residual_plan = 'Legacy',
--             residual_plan_status = 'ACTIVE'
--         where pd.project_id = x.project_id;
--         commit;
--
--       end loop;
--
--   end
-- $do$;
--
--
-- DO
-- $do$
--   declare
--     x record;
--
--   BEGIN
--     for x in select pd.project_id
--              from brs.project_details pd
--                     inner join brs.residual_plan_user rpu on rpu.user_id = pd.closer_user_id  and rpu.residual_plan_id =2
--
--       loop
--         update brs.financial_details pd
--         set residual_plan_id = 2,
--             residual_plan = 'Enhanced',
--             residual_plan_status = 'ACTIVE'
--         where pd.project_id = x.project_id;
--         commit;
--
--       end loop;
--
--   end
-- $do$;

-- DO
-- $do$
--   declare
--     x record;
--
--   BEGIN
--     for x in select project_id,coalesce(sum(amount),0) amount1
--              from brs.project_commission_ledger pcl
--              where ledger_type_id = 1
--              group by project_id
--
--       loop
--         update brs.financial_details pd
--         set total_commissions_paid_to_date = x.amount1
--         where project_id = x.project_id;
--         commit;
--
--       end loop;
--
-- end
-- $do$;
--
-- DO
-- $do$
--   declare
--     x record;
--
--   BEGIN
--     for x in select project_id,coalesce(sum(amount),0) amount1
--              from brs.project_commission_ledger pcl
--              where ledger_type_id = 2
--              group by project_id
--
--       loop
--         update brs.financial_details pd
--         set total_commissions_adjustments_paid_to_date = x.amount1
--         where project_id = x.project_id;
--         commit;
--
--       end loop;
--
--   end
-- $do$;
--
--
-- DO
-- $do$
--   declare
--     x record;
--
--   BEGIN
--     for x in select project_id,coalesce(sum(paid_to_date),0) amount1
--              from brs.project_commission_ledger pcl
--              where ledger_type_id = 3
--              group by project_id
--
--       loop
--         update brs.financial_details pd
--         set total_overrides_paid_to_date = x.amount1
--         where project_id = x.project_id;
--         commit;
--
--       end loop;
--
--   end
-- $do$;
--
-- DO
-- $do$
--   declare
--     x record;
--
--   BEGIN
--     for x in select project_id,coalesce(sum(amount),0) amount1
--              from brs.project_commission_ledger pcl
--              where ledger_type_id = 7
--              group by project_id
--
--       loop
--         update brs.financial_details pd
--         set total_commissions_forfeited_paid_to_date = x.amount1
--         where project_id = x.project_id;
--         commit;
--
--       end loop;
--
--   end
-- $do$;
--
--
--
-- DO
-- $do$
--   declare
--     x record;
--
--   BEGIN
--     for x in select project_id,
--                     substantial_completion_date,
--                     substantial_completion_date_ppsecfv_id,
--                     cancelled_date,
--                     final_design_complete_date,
--                     final_design_complete_date_ppscfv_id,
--                     source,
--                     system_size,
--                     loan_term,
--                     primary_financier,
--                     interest_rate
--              from brs.project_details pd
--
--       loop
--         update brs.financial_details fd
--         set substantial_completion_date = x.substantial_completion_date,
--             substantial_completion_date_ppsecfv_id = x.substantial_completion_date_ppsecfv_id,
--             cancelled_date              = x.cancelled_date,
--             final_design_complete_date  = x.final_design_complete_date,
--             final_design_complete_date_ppscfv_id = x.final_design_complete_date_ppscfv_id,
--             source                      = x.source,
--             system_size                 = x.system_size,
--             loan_term                   = x.loan_term,
--             primary_financier           = x.primary_financier,
--             interest_rate               = x.interest_rate
--         where project_id = x.project_id;
--       commit;
--       end loop;
--
--   end
-- $do$;


--TODO delete from data_view_maintenance for Scott so we aren't updating all rows.  I will create
--todo the updates for commissions_earned and overrides_earned

--TODO FOR COMMISSIONS
--drop the child function for inserting commissions on projects on the FDC step Carlin
--delete the configuration for source on contact    Scott

--TODO CARLIN commissions_earned is the field to update and Display name is whatever you and it's numeric and COMMISSION_EARNED_TRIGGER is the unique behavior type
--add child config for final_design_signed_date  Carlin
--add child config for substantial_completion_date Carlin
--add child config for system size  Carlin
--add child config for source on PROJECT  Carlin
--add child config for primary_financier_name  Carlin
--add child config for loan_term  Carlin
--add child config for interest_rate  Carlin
--add child config for cancel date Carlin




--TODO CARLIN overrides_earned is the field to update and Display name is whatever you and it's numeric and OVERRIDES_EARNED_TRIGGER is the unique behavior type
--add child config for final_design_signed_date  Carlin
--add child config for substantial_completion_date Carlin
--add child config for system size  Carlin
--add child config for source on PROJECT  Carlin
--add child config for primary_financier_name  Carlin
--add child config for loan_term  Carlin
--add child config for interest_rate  Carlin
--add child config for cancel date Carlin


--TODO CARLIN total_commissions is the field to update and Display name is whatever you and it's numeric and TOTAL_COMMISSIONS_TRIGGER is the unique behavior type
--add child config for final_design_signed_date  Carlin
--add child config for substantial_completion_date Carlin
--add child config for system size  Carlin
--add child config for source on PROJECT  Carlin
--add child config for primary_financier_name  Carlin
--add child config for loan_term  Carlin
--add child config for interest_rate  Carlin


--TODO CARLIN total_overrides is the field to update and Display name is whatever you and it's numeric and TOTAL_OVERRIDES_TRIGGER is the unique behavior type
--add child config for final_design_signed_date  Carlin
--add child config for substantial_completion_date Carlin
--add child config for system size  Carlin
--add child config for primary_financier_name  Carlin
--add child config for loan_term  Carlin
--add child config for interest_rate  Carlin

