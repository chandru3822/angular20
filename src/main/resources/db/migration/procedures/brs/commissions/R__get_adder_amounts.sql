drop function if exists brs.get_adder_amounts(p_plh_id bigint);
CREATE OR REPLACE function brs.get_adder_amounts(p_plh_id bigint)
  returns TABLE(project_selected_adder_amount numeric,
                project_custom_adder_amount numeric,
                proposal_selected_adder_amount numeric,
                proposal_custom_adder_amount numeric,
                version_id bigint,
                commission_strategy_id bigint,
                storage_id bigint,
                auto_applied_adder_amount numeric,
                desired_commission_adder numeric)
AS
$BODY$
DECLARE
  v_proposal_selected_adder_amount numeric;
  v_proposal_custom_adder_amount   numeric;
  v_project_selected_adder_amount  numeric;
  v_project_custom_adder_amount    numeric;
  x                                record;
  v_commission_strategy_id         bigint;
  v_storage_id                     bigint;
  v_version_id                     bigint;
  v_proposal_id                    bigint;
  v_auto_applied_adder_amount           numeric;
  v_desired_commission_adder   numeric;
  v_financial_product_id bigint;
BEGIN


  select coalesce(plh.selected_adder_amount, 0),
         coalesce(plh.custom_adder_amount, 0),
         coalesce(plh.auto_applied_adder_amount,0),
         plh.commission_strategy_id,
         plh.storage_type_id,
         plh.proposal_version_id,
         plh.proposal_log_id,
         plh.desired_commission_adder,
         plh.financial_product_id
  into v_proposal_selected_adder_amount,v_proposal_custom_adder_amount,v_auto_applied_adder_amount,
    v_commission_strategy_id,v_storage_id,v_version_id,v_proposal_id,v_desired_commission_adder,v_financial_product_id
  from brs.proposal_log_history plh
  where plh.id = p_plh_id;

  v_project_custom_adder_amount = 0;
  for x in select ao.custom_project_adder_amount
           from brs.get_selected_custom_auto_adders(
                  v_proposal_id,
                  v_commission_strategy_id,
                  v_storage_id,
                  v_financial_product_id) ao
           where ao.adder_type = 'custom_adders'
    loop
      v_project_custom_adder_amount = v_project_custom_adder_amount + x.custom_project_adder_amount;

    end loop;

  v_project_selected_adder_amount = 0;
  for x in select ao.selected_adder_amount
           from brs.get_selected_custom_auto_adders(
                  v_proposal_id,
                  v_commission_strategy_id,
                  v_storage_id,
                  v_financial_product_id) ao
           where ao.adder_type = 'selected_adders'
             and ao.selected_project_adder is true
    loop
      v_project_selected_adder_amount = v_project_selected_adder_amount + x.selected_adder_amount;
    end loop;

  return query select coalesce(v_project_selected_adder_amount, 0),
                      coalesce(v_project_custom_adder_amount, 0),
                      coalesce(v_proposal_selected_adder_amount,0),
                      coalesce(v_proposal_custom_adder_amount,0),
                      v_version_id,
                      v_commission_strategy_id,
                      v_storage_id,
                      coalesce(v_auto_applied_adder_amount,0),
                      coalesce(v_desired_commission_adder,0);
END;
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
