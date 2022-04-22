CREATE OR REPLACE FUNCTION flow.adjust_commission_override_trigger()
    RETURNS TRIGGER AS
$$
declare

BEGIN
    create temp table  milestone_one_projects as (
        select project_id, min(process_step_complete_date) milestone_one_complete_date
        from flow.project_process_step pps
                 inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
                 inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id and psst.id = 2
        where pps.process_step_id = 175
        group by project_id);

    perform brs.insert_commissions_on_project(p.id)
    from brs.project_details pd
    inner join flow.project p on p.id = pd.project_id
    inner join milestone_one_projects mop on mop.project_id = p.id
    left join brs.project_commission_ledger pcl on pcl.project_id = p.id
        where pd.closer_user_id = new.user_id
    and pcl.id is null;
    drop table milestone_one_projects;
    RETURN null;
END
$$
    LANGUAGE plpgsql;

drop trigger if exists adjust_commission_override_trigger_trg on brs.override_plan_assigned_user;
CREATE TRIGGER adjust_commission_override_trigger_trg
    after INSERT
    ON brs.override_plan_assigned_user
    FOR EACH ROW
EXECUTE PROCEDURE flow.adjust_commission_override_trigger();



