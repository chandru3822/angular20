insert into flow.flow_type(flow_type)
select 'Attachments' where not exists (select id
from flow.flow_type where flow_type = 'Attachments' );

insert into flow.object_type(object_type, object_code, flow_type_id)
select 'Attachments', 'ATTACHMENTS', (select id
                                      from flow.flow_type where flow_type = 'Attachments')
WHERE NOT exists (select id from flow.object_type where object_code = 'ATTACHMENTS');

insert into flow.company_object_type(object_type_id, company_id, created_by_id)
select (select id from flow.object_type where object_code = 'ATTACHMENTS'), 3, 2417170
where not exists (
  select id from flow.company_object_type
  where company_id = 3 and object_type_id = (select id from flow.object_type where object_code = 'ATTACHMENTS')
  );
