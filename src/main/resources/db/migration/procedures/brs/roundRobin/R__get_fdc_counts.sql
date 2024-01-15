drop function if exists brs.get_fdc_counts(p_user_id bigint, p_closer_gen_source_ids bigint[], p_interval bigint);
drop function if exists brs.get_fdc_counts(p_user_id bigint,p_user_position_id bigint, p_closer_gen_source_ids bigint[], p_interval bigint);
create or replace function brs.get_fdc_counts(p_user_id bigint,p_user_position_id bigint, p_closer_gen_source_ids bigint[], p_interval bigint)
  returns TABLE
          (
            user_id                    bigint,
            lead_gen_fdc_count         bigint,
            self_gen_fdc_count         bigint,
            total_fdc_count            bigint,
            lead_gen_appointment_count bigint
          )
as
$$
select p_user_id,
       (select coalesce((select count(pd.id) as lead_gen_fdc_count
                         from brs.project_details pd
                                inner join flow.company_project_status_type cpst
                                           on cpst.id = pd.company_project_status_type_id and
                                              cpst.project_status_type_id in (1, 4)
                         where pd.closer_user_position_id = p_user_position_id
                           and not pd.source = any (p_closer_gen_source_ids)
                           and pd.archived is false
                           and pd.final_design_complete_date is not null
                           and pd.final_design_complete_date >=
                               ((now() AT TIME ZONE 'US/Mountain') :: date - (p_interval || 'day')::interval)
                           and ((pd.cancelled_date is null) or
                                (pd.cancelled_date is not null and
                                 pd.cancelled_date > ((now() AT TIME ZONE 'US/Mountain') :: date)))
                           and pd.company_id = 3), 0)),
       (select coalesce((select count(pd.id) as self_gen_fdc_count
                         from brs.project_details pd
                                inner join flow.company_project_status_type cpst
                                           on cpst.id = pd.company_project_status_type_id and
                                              cpst.project_status_type_id in (1, 4)
                         where pd.closer_user_position_id = p_user_position_id
                           and pd.source = any (p_closer_gen_source_ids)
                           and pd.archived is false
                           and pd.final_design_complete_date is not null
                           and pd.final_design_complete_date >=
                               ((now() AT TIME ZONE 'US/Mountain') :: date - (p_interval || 'day')::interval)
                           and ((pd.cancelled_date is null) or
                                (pd.cancelled_date is not null and
                                 pd.cancelled_date > ((now() AT TIME ZONE 'US/Mountain') :: date)))
                           and pd.company_id = 3), 0)),
       (select coalesce((select count(pd.id) as total_fdc_count
                         from brs.project_details pd
                                inner join flow.company_project_status_type cpst
                                           on cpst.id = pd.company_project_status_type_id and
                                              cpst.project_status_type_id in (1, 4)
                         where pd.closer_user_position_id = p_user_position_id
                           and pd.archived is false
                           and pd.final_design_complete_date is not null
                           and pd.final_design_complete_date >=
                               ((now() AT TIME ZONE 'US/Mountain') :: date - (p_interval || 'day')::interval)
                           and ((pd.cancelled_date is null) or
                                (pd.cancelled_date is not null and
                                 pd.cancelled_date > ((now() AT TIME ZONE 'US/Mountain') :: date)))
                           and pd.company_id = 3), 0)),
       (select coalesce((select count(pd.id) as lead_gen_appointment_count
                         from brs.project_details pd
                                inner join flow.company_project_status_type cpst
                                           on cpst.id = pd.company_project_status_type_id and
                                              cpst.project_status_type_id in (1, 4)
                         where pd.closer_user_position_id = p_user_position_id
                           and pd.first_appointment >=
                               now() - (p_interval || 'day')::interval
                           and not pd.source = any (p_closer_gen_source_ids)
                           and pd.company_id = 3), 0));
$$ language sql stable;
