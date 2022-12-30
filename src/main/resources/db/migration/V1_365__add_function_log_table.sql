CREATE TABLE if NOT EXISTS flow.company_function_log
(
    id        serial                NOT NULL,
    function_name varchar(255) not null,
    db_function_id integer,
    run_by_id integer,
    date_created            timestamp without time zone default now(),
    parameters text,
    CONSTRAINT flow_company_function_log_pk PRIMARY KEY (id),
    CONSTRAINT cfl_db_function_id_fk FOREIGN KEY (db_function_id)
    REFERENCES flow.db_function (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT run_by_id_fk FOREIGN KEY (run_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
    );

drop function if exists brs.cache_available_time_slots();
drop function if exists brs.get_all_users_overrides_earned_in_open_payroll(p_payroll_id bigint);
drop function if exists brs.get_allocation_by_zone(p_postal_code_zone_id bigint);
drop function if exists flow.get_availability_time_slots(bigint, timestamp, timestamp, date, boolean);
DROP FUNCTION IF EXISTS brs.get_closer_availability(p_start_time timestamp, p_end_time timestamp,
    p_postal_code_zone_user_ids bigint[]);
drop function if exists brs.get_commission_summary(p_position_id bigint);
drop function if exists brs.get_commission_summary_from_snapshot(p_payroll_id bigint);
drop function if exists brs.get_commission_summary_from_snapshot_for_setters(p_payroll_id bigint);
drop function if exists brs.rpt_closer_funnel_appt_date_cohort(p_custom_start_date date,
    p_custom_end_date date,
    p_user_position_ids bigint[], p_org_ids bigint[]);
drop function if exists brs.rpt_closer_funnel_appts_created_pipeline(p_custom_start_date date,
    p_custom_end_date date,
    p_brs_provided_source_ids bigint[],
    p_self_gen_source_ids bigint[]);
drop function if exists brs.rpt_closer_funnel_appts_created_pipeline_drilldown(p_start_date date, p_end_date date,
    p_funnel_id bigint,
    p_source_ids bigint[]);
drop function if exists brs.rpt_closer_funnel_standard(p_custom_start_date date, p_custom_end_date date,
    p_user_position_ids bigint[], p_org_ids bigint[]);
drop function if exists brs.rpt_closer_funnel_standard_and_cohort_drilldown(p_start_date date, p_end_date date,
    p_funnel_id bigint,
    p_user_position_ids bigint[],
    p_org_ids bigint[],
    p_is_checked_in_column boolean,
    p_is_cohort boolean);
drop function if exists brs.rpt_closer_funnel_standard_event_based(date, date, bigint[], bigint[]);
drop function if exists brs.rpt_company_dashboard(p_custom_start_date date, p_custom_end_date date,
    p_company_id bigint,
    p_target_type_id bigint);
drop function if exists brs.rpt_company_dashboard_drilldown(p_custom_start_date date, p_custom_end_date date,
    p_company_id bigint, p_milestone_type_id bigint,
    p_load_partners boolean);
drop function if exists brs.get_calculated_proposal_values(bigint, boolean);
drop function if exists brs.get_data_from_proposal(
    p_project_id bigint,
    p_proposal_nbr bigint);
drop function if exists brs.get_setter_mgr_performance_report(p_office_id bigint, p_start_date date, p_end_date date);
drop function if exists brs.get_setter_office_ranking(p_limit bigint,  p_time_interval character varying, p_days bigint);
drop function if exists brs.get_setter_office_to_beat(p_office_id bigint, p_start_date date, p_end_date date);
drop function if exists brs.get_setters_by_setter_mgr_office(p_office_id bigint);
drop function if exists brs.get_top_setter_offices(p_limit bigint, p_time_interval character varying, p_days bigint);
drop function if exists brs.get_top_setter_reps(p_limit bigint, p_time_interval character varying, p_days bigint);
drop function if exists brs.get_installer_dashboard_rankings(p_start_date DATE, p_end_date DATE, p_company_id bigint,
    p_parent_company_id bigint, p_is_parent boolean);
drop function if exists brs.get_round_robin_lead_allocation_rank(p_postal_code_zone_id bigint, p_time_interval bigint);
drop function if exists brs.get_tournament_brackets(p_tournament_id bigint);
drop function if exists brs.get_tournament_pool_users(p_tournament_id bigint, p_tournament_pool_type_id bigint);
drop function if exists flow.delete_project_process_step(p_project_process_step_id bigint);
drop function if exists flow.insert_note_relation(p_primary_id bigint, p_note_id bigint, p_object_type_id bigint);
