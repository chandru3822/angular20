alter table brs.project_commission add column  if not exists is_booking boolean;


DO
$do$
  declare
    x record;
  BEGIN
    for x in  select pd.project_id,
                     ppscfv.int_value,
                     plh.commission_strategy_id,
                     plh.desired_commission_amount
              from brs.project_details pd
                     inner join brs.financial_details fd on fd.project_id = pd.project_id
                     inner join flow.project_process_step pps on pps.project_id = pd.project_id and pps.main is true and pps.process_step_id = 4
                     inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                                       ppscfv.custom_field_group_assignment_id =1434
                     inner join brs.proposal_log_history plh on plh.id = ppscfv.int_value
              where pd.installation_agreement_signed_date is not null and pd.final_design_complete_date is null
                and fd.commission_strategy is null
                and plh.commission_strategy_id is not null-- and plh.id = 2835075

      loop
        perform flow.set_pps_cfv(x.project_id, 2384850,26943, x.desired_commission_amount::text, true);
        perform flow.set_pps_cfv(x.project_id, 2384850,26944, x.commission_strategy_id::text, true);
      end loop;

  end
$do$;



with my_data as (
  select project_id,installation_agreement_signed_date,installation_agreement_signed_date_ppscfv_id,
         system_size
  from brs.project_details pd
  where installation_agreement_signed_date is not null
)
update brs.financial_details fd
set installation_agreement_signed_date = md.installation_agreement_signed_date,
    installation_agreement_signed_date_cfv_id = md.installation_agreement_signed_date_ppscfv_id,
    system_size = md.system_size
from my_data md
where md.project_id = fd.project_id;


DO
$do$
  declare
    x record;
  BEGIN
    for x in   select project_id
               from brs.financial_details fd
               where fd.installation_agreement_signed_date is not null and fd.final_design_complete_date is null
      loop
        call brs.reset_financial_details(x.project_id);
  end loop;
end
$do$;

