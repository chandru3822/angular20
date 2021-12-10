drop view if exists brs.proposal_version_custom_field_value_vw;
create or replace view brs.proposal_version_custom_field_value_vw as
(
select pvcfv.id,
       pvcfv.custom_field_group_assignment_id,
       pvcfg.proposal_group_uuid,
       pvcfg.proposal_version_id,
       pvcfv.value,
       cf.id as field_id,
       cf.field_code,
       cf.field_name,
       ot.object_code,
       pvcfv.modified_by_id,
       concat_ws(' ', mu.first_name, mu.last_name) as modified_by,
       pvcfv.date_modified
from brs.proposal_version_custom_field_value pvcfv
       inner join brs.proposal_version_custom_field_group pvcfg
                  on pvcfv.proposal_version_custom_field_group_id = pvcfg.id
       inner join brs.proposal_version pv on pvcfg.proposal_version_id = pv.id
       inner join brs.custom_field_group_assignment cfga on pvcfv.custom_field_group_assignment_id = cfga.id
       inner join brs.custom_field cf on cfga.custom_field_id = cf.id
       inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
       inner join brs.object_type ot on cfg.object_type_id = ot.id
       inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
       inner join flow.data_type dt on cdt.data_type_id = dt.id
       inner join flow.user mu on mu.id = pvcfv.modified_by_id
where pvcfg.archived is null
  );
