drop function if exists flow.adjust_commission_override_trigger() cascade;
CREATE OR REPLACE FUNCTION flow.adjust_commission_override_trigger()
    RETURNS TRIGGER AS
$$
declare

BEGIN

    perform brs.insert_commissions_on_project(pd.project_id)
    from brs.project_details pd
    left join brs.project_commission_ledger pcl on pcl.project_id = pd.project_id
        where pd.closer_user_id = new.user_id
    and pcl.id is null
    and pd.final_design_complete_date is not null;

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



