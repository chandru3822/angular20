-- ### DESIGN ###
drop trigger if exists commission_plan_org_trg ON brs.commission_plan_org;
drop function if exists brs.commission_plan_org();
CREATE OR REPLACE FUNCTION brs.commission_plan_org()
  RETURNS TRIGGER AS
$$
declare
  v_CFGA_PARTNER_ORG_ASSIGNMENT bigint[];
  x                             record;
  v_financial_details_id        bigint;
  v_count                       bigint;
  v_partner_m1_amount numeric;
  v_partner_m2_amount numeric;
  v_partner_total_commissions numeric;
  v_custom_adder_amount numeric;
  v_selected_adder_amount numeric;
  v_partner_commission_amount numeric;
  v_financial_details_partner_id bigint;
BEGIN

  select (select string_to_array(value, ',')
          from flow.company_configuration_value
          where code = 'CFGA_PARTNER_ORG_ASSIGNMENT')::bigint[]
  into v_CFGA_PARTNER_ORG_ASSIGNMENT;

  for x in select pcfv.project_id, p.contact_id, c.company_id, p.company_process_id,cp.name,cps.status_type,cp.position_id
           from flow.project_custom_field_value pcfv
                  inner join flow.project p on p.id = pcfv.project_id
                  inner join flow.contact c on c.id = p.contact_id
                  inner join brs.commission_plan cp on cp.id = new.commission_plan_id
                  left join brs.commission_plan_status cps on cps.id = cp.status_id
           where pcfv.custom_field_group_assignment_id = any (v_CFGA_PARTNER_ORG_ASSIGNMENT)
             and pcfv.int_value = new.org_id
             and not exists(select fdp.id
                            from brs.financial_details f
                                   inner join brs.financial_details_partner fdp on fdp.financial_details_id = f.id
                            where f.project_id = pcfv.project_id
                              and fdp.position_id = cp.position_id
                             and fdp.org_id = new.org_id)
    loop
      v_count = 0;
      select id
      into v_financial_details_id
      from brs.financial_details fd
      where project_id = x.project_id;

      select count(1)
      into v_count
      from flow.data_view dv
      where x.company_process_id = any (dv.company_process_ids)
        and dv.id = 2;

      if v_count > 0 then

        if v_financial_details_id is null then
          insert into brs.financial_details(project_id, contact_id, company_id,
                                            date_modified)
          values (x.project_id, x.contact_id, x.company_id, now())
          returning  id into v_financial_details_id;
        end if;

        insert into brs.financial_details_partner (created_by_id, modified_by_id, partner_commissions_earned_m1,
                                                   partner_commissions_earned_m2, partner_total_commissions,
                                                   partner_commission_plan,
                                                   partner_commission_plan_id, partner_commission_plan_status,
                                                   financial_details_id, org_id, position_id, custom_adder_amount,
                                                   selected_adder_amount, base_commission_amount,active)
        (select 99999999,99999999,v_partner_m1_amount,v_partner_m2_amount,v_partner_total_commissions,x.name,new.commission_plan_id,
                x.status_type,v_financial_details_id,new.org_id,x.position_id,v_custom_adder_amount,v_selected_adder_amount,v_partner_commission_amount,true)
        returning id into v_financial_details_partner_id;

        select m1_amount, m2_amount, total_commissions,custom_adder_amount,select_adder_amount,partner_commission_amount
        into v_partner_m1_amount,v_partner_m2_amount,v_partner_total_commissions,v_custom_adder_amount,v_selected_adder_amount,v_partner_commission_amount
        from brs.get_partner_commissions_earned(x.project_id, new.org_id);

        update brs.financial_details_partner fdp2
        set partner_commissions_earned_m1 = v_partner_m1_amount,
            partner_commissions_earned_m2 = v_partner_m2_amount,
            partner_total_commissions = v_partner_total_commissions,
            custom_adder_amount = v_custom_adder_amount,
            selected_adder_amount = v_selected_adder_amount,
            base_commission_amount = v_partner_commission_amount
        where id = v_financial_details_partner_id;

      end if;
    end loop;
  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

CREATE TRIGGER commission_plan_org_trg
  after INSERT
  ON brs.commission_plan_org
  FOR EACH ROW
EXECUTE PROCEDURE brs.commission_plan_org();

