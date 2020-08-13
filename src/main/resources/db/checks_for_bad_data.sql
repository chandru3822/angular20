-- using this as a placeholder for all queries i need to check for bad data i create from time to time.  i've fixed all the causes i could find

-- if an scheduling group has less than 3 fields something went wrong!
select cfg.id,
       cfg.group_name,
       cfg.group_order,
       count(1)
from flow.custom_field_group cfg
         inner join flow.custom_field_group_assignment cfga on cfga.custom_field_group_id = cfg.id
where cfg.event_type_id is not null
  and cfga.archived is not true
group by cfg.id, cfg.group_name, cfg.group_order
having count(1) < 3;

-- action logic not archived with the related requirement is
select *
from flow.process_step_logic psl
         inner join flow.process_step_requirement psr on psr.id = psl.process_step_requirement_id
where psr.archived is true
  and psl.archived is not true;

-- process step requirement not archived when some combo of custom field is deleted
select *
from flow.process_step_requirement psr
         inner join flow.custom_field_group_assignment cfga on cfga.id = psr.custom_field_group_assignment_id
         inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
         inner join flow.custom_field cf on cf.id = cfga.custom_field_id
where psr.archived is not true
  and (cfga.archived is true or cfg.archived is true or cf.archived is true);

-- custom field deleted but still assigned to custom field group
select *
from flow.custom_field_group_assignment cfga
         inner join flow.custom_field cf on cf.id = cfga.custom_field_id
where cfga.archived is not true
  and cf.archived is true;
