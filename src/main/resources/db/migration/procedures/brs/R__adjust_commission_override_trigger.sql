CREATE OR REPLACE FUNCTION flow.adjust_commission_override_trigger()
    RETURNS TRIGGER AS
$$
declare

BEGIN
    perform brs.insert_commissions_on_project(p.id)
    from brs.project_details pd
    inner join flow.project p on p.id = pd.project_id
    inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 175 and pps.main is true
                                        and pps.process_step_complete_date is not null
    inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
    inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id and psst.process_step_status_type = 'COMPLETE'
    left join brs.project_commission_ledger pcl on pcl.project_id = p.id
        where pd.closer_user_id = new.user_id
    and pcl.id is null;
    RETURN NULL;
END
$$
    LANGUAGE plpgsql;

drop trigger if exists adjust_commission_override_trigger_trg on brs.override_plan_assigned_user;
CREATE TRIGGER adjust_commission_override_trigger_trg
    after INSERT
    ON brs.override_plan_assigned_user
    FOR EACH ROW
EXECUTE PROCEDURE flow.adjust_commission_override_trigger();



