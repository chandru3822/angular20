CREATE OR REPLACE FUNCTION brs.check_project_zipcode(p_project_id integer)
  returns boolean AS
$BODY$
with published_proposal as (select proposal_version_id
                            from brs.primary_company_proposal_version
                            where company_id = 3),
     version_values as (select distinct on ( proposal_group_uuid, custom_field_group_assignment_id ) vw.id,
                                                                                                     vw.proposal_group_uuid,
                                                                                                     vw.value,
                                                                                                     vw.field_id
                        from brs.proposal_version_custom_field_value_vw vw
                        where vw.proposal_version_id <= (select proposal_version_id from published_proposal)
                          and vw.proposal_group_uuid not in (select distinct proposal_group_uuid
                                                             from brs.proposal_version_custom_field_group
                                                             where archived is not null
                                                               and proposal_version_id <=
                                                                   (select proposal_version_id from published_proposal))
                        order by vw.proposal_group_uuid, vw.custom_field_group_assignment_id, vw.id desc),
     approved_postal_code as (select p as postal_code
                              from version_values vv
                                     left join lateral jsonb_array_elements_text(value -> 'value') p on true
                              where field_id = 122 -- Postal Code
                                and p = (select postal_code from flow.project p2 where p2.id = p_project_id)),
     requested_process_step as (select pps.id,
                                       cpsst.process_step_status_type_id,
                                       cpsst.process_step_status_type,
                                       ppscfv2.int_value = any ('{20478,20479}') and
                                       cpsst.process_step_status_type_id = 2 as process_step_approval,
                                       pps.project_id
                                from flow.project_process_step pps
                                       inner join flow.company_process_step_status_type cpsst
                                                  on pps.company_process_step_status_type_id = cpsst.id
                                       left join flow.project_process_step_custom_field_value ppscfv2
                                                 on ppscfv2.project_process_step_id = pps.id
                                                   and ppscfv2.custom_field_group_assignment_id =
                                                       23496 -- postal code approval
                                where pps.project_id = p_project_id
                                  and pps.main is true
                                  and pps.process_step_id = 3546 -- Zip Code Approval
                                  and cpsst.process_step_status_type_id in (1, 2))
select case when t.approved then t.approved else coalesce(rps.process_step_approval, false) end
from (select exists(select apc.postal_code from approved_postal_code apc) as approved) as t
       left join requested_process_step rps on true;
$BODY$
  LANGUAGE sql VOLATILE
               COST 100;
