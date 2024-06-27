update brs.funnel f
set display_order = 2
where id = 10;

update brs.funnel f
set display_order = 3
where id = 12;

update brs.funnel f
set display_order = 4
where id = 13;

update brs.funnel f
set display_order = 5
where id = 26;

insert into brs.funnel(name, ratio, display_order, funnel_type_id, closer_appt_outcome_int_values, exclude_values, hide_future,
                       only_future, show_checked_in_column, archived, use_self_gen_sources,
                       use_brs_sources, unique_behavior, expectation)
(select 'Leads Created',0.00,1,2,null,false,false,false,false,false,false,false,false,null);


create index if not exists flow_date_created_ix
  on flow.contact ((timezone('US/Mountain'::text, timezone('UTC'::text, date_created))::date));

alter table brs.project_details add column  if not exists prioritized_closer_dashboard_outcome_id bigint;
alter table brs.project_details add column  if not exists prioritized_closer_dashboard_outcome text;
alter table brs.project_details add column  if not exists prioritized_closer_dashboard_start_time timestamp;
alter table brs.project_details add column  if not exists prioritized_closer_dashboard_checkin timestamp;
alter table brs.project_details add column  if not exists prioritized_closer_dashboard_ppse_id bigint;
alter table brs.project_details add column  if not exists prioritized_appointment_type bigint;
alter table brs.project_details add column  if not exists prioritized_closer_appointment_by_round_robin boolean not null default false;


CREATE INDEX if not exists pd_prioritized_closer_appointment_by_round_robin_idx ON brs.project_details(prioritized_closer_appointment_by_round_robin);



create index if not exists pd_prioritized_closer_dashboard_start_time_idx
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, prioritized_closer_dashboard_start_time))::date));

CREATE INDEX if not exists pd_prioritized_closer_dashboard_outcome_id_idx ON brs.project_details (prioritized_closer_dashboard_outcome_id);
CREATE INDEX if not exists pd_prioritized_closer_dashboard_outcome_idx ON brs.project_details (prioritized_closer_dashboard_outcome);
CREATE INDEX if not exists pd_prioritized_closer_dashboard_checkin_idx ON brs.project_details (prioritized_closer_dashboard_checkin);
CREATE INDEX if not exists pd_prioritized_closer_dashboard_ppse_id_idx ON brs.project_details (prioritized_closer_dashboard_ppse_id);


drop view if exists brs.closer_dashboard_drilldown_vw;

alter table brs.proposal_log_history add column if not exists all_ancillary_costs jsonb;

drop function if exists brs.rpt_closer_funnel_standard_and_cohort_drilldown(p_start_date date, p_end_date date,
                                                                            p_funnel_id bigint,
                                                                            p_user_position_ids bigint[],
                                                                            p_org_ids bigint[],
                                                                            p_is_checked_in_column boolean,
                                                                            p_is_cohort boolean,
                                                                            p_run_by_id bigint);

drop function if exists brs.rpt_closer_funnel_appts_created_pipeline_drilldown(p_start_date date, p_end_date date,
                                                                               p_funnel_id bigint,
                                                                               p_source_ids bigint[],
                                                                               p_run_by_id bigint);
