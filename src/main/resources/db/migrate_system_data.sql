insert into flow.company(company_name,aws_bucket, abbreviation)values('Blue Raven Solar','blueraven', 'brs');

-- todo: make these work for uat where they already exist
insert into flow.system_list_type (system_list_type, archived)
select 'orgs', false  where not exists (select id from flow.system_list_type where system_list_type = 'orgs');
insert into flow.system_list_type (system_list_type, archived)
select 'users', false  where not exists (select id from flow.system_list_type where system_list_type = 'users');

insert into flow.system_list (system_list, system_list_type_id, archived)
select 'Users by Organization', 2, false  where not exists (select id from flow.system_list where system_list = 'Users by Organization');
insert into flow.system_list (system_list, system_list_type_id, archived)
select 'Users by Position', 2, false  where not exists (select id from flow.system_list where system_list = 'Users by Position');
insert into flow.system_list (system_list, system_list_type_id, archived)
select 'Organizations by Type', 1, false  where not exists (select id from flow.system_list where system_list = 'Organizations by Type');

insert into flow.company_system_list (system_list_id, company_id, schedulable)
select 1, 1, true  where not exists (select id from flow.company_system_list where system_list_id = 1);
insert into flow.company_system_list (system_list_id, company_id, schedulable)
select 2, 1, true  where not exists (select id from flow.company_system_list where system_list_id = 2);
insert into flow.company_system_list (system_list_id, company_id, schedulable)
select 3, 1, true  where not exists (select id from flow.company_system_list where system_list_id = 3);

insert into flow.bucket_type(bucket_type) values
('apps'),
('deal-attachments'),
('media'),
('photos'),
('proptool'),
('reimbursement'),
('scheduled-message-attachments'),
('uploads'),
('welcome-closer-email');

insert into flow.custom_field_sql_key( sql_key) values ('customFieldSql.brs.ahjList');

insert into flow.owner_type(owner_type) values('CUSTOMER');
insert into flow.owner_type(owner_type) values('PROJECT');

insert into flow.owner_position_id(company_id,position_ids,owner_type_id)values(1,'{4}',1);

INSERT INTO flow.data_type(data_type)
VALUES ('date');

INSERT INTO flow.data_type(data_type)
VALUES ('timestamp');

INSERT INTO flow.data_type(data_type)
VALUES ('boolean');

INSERT INTO flow.data_type(data_type)
VALUES ('numeric');

INSERT INTO flow.data_type(data_type)
VALUES ('text');

INSERT INTO flow.data_type(data_type)
VALUES ('integer');

INSERT INTO flow.data_type(data_type)
VALUES ('integer array');

INSERT INTO flow.data_type(data_type,custom_behavior)
VALUES ('system',true);

insert into flow.schedule_field_type (field_type, required_data_type_id)
select 'Event Start Time', 2  where not exists (select id from flow.schedule_field_type where field_type = 'start time');

insert into flow.schedule_field_type (field_type, required_data_type_id)
select 'Event End Time', 2  where not exists (select id from flow.schedule_field_type where field_type = 'end time');

insert into flow.schedule_field_type (field_type, required_data_type_id)
select 'Event Resource', 9  where not exists (select id from flow.schedule_field_type where field_type = 'resource');

insert into flow.operator_type(id, operator_type) values
(1, 'Equals'),
(2, 'Not Equal To'),
(3, 'is Greater Than'),
(4, 'is Less Than'),
(5,'In');

insert into flow.action_type(action_type) values ('Link'), ('Button');

insert into flow.country(country,abbreviation) values ('United States', 'USA');


insert into flow.operation_type(operation_type, operation_code)
values
('(', '('),
(')', ')'),
('AND', 'AND'),
('OR', 'OR'),
('NOT', '!');

insert into flow.operator_data_type (data_type_id, operator_type_id) values
( 5, 1 ),
( 5, 2 ),
( 1, 1 ),
( 1, 2 ),
( 1, 3 ),
( 1, 4 ),
( 2, 1 ),
( 2, 2 ),
( 2, 3 ),
( 2, 4 ),
( 3, 1 ),
( 3, 2 ),
( 6, 1 ),
( 6, 2 ),
( 6, 3 ),
( 6, 4 ),
( 4, 1 ),
( 4, 2 ),
( 4, 3 ),
( 4, 4 ),
( 7, 1 ),
( 7, 2 );

-- system data type
insert into flow.operator_data_type (operator_type_id, data_type_id, archived)
select 1, 8, false  where not exists (select id from flow.operator_data_type where operator_type_id = 1 and data_type_id = 8);
insert into flow.operator_data_type (operator_type_id, data_type_id, archived)
select 2, 8, false  where not exists (select id from flow.operator_data_type where operator_type_id = 2 and data_type_id = 8);
-- system list data type
insert into flow.operator_data_type (operator_type_id, data_type_id, archived)
select 1, 9, false  where not exists (select id from flow.operator_data_type where operator_type_id = 1 and data_type_id = 9);
insert into flow.operator_data_type (operator_type_id, data_type_id, archived)
select 2, 9, false  where not exists (select id from flow.operator_data_type where operator_type_id = 2 and data_type_id = 9);




insert into flow.parameter_type(parameter_type) values('System');
insert into flow.parameter_type(parameter_type) values('Dynamic');
insert into flow.parameter_type(parameter_type) values('Custom Field');

insert into flow.flow_type(flow_type) values ('Object');
insert into flow.flow_type(flow_type) values ('Process Step');

insert into flow.status_type (id, status_type) values (1, 'Active');
insert into flow.status_type (id, status_type) values (2, 'Inactive');



insert into flow.process_step_requirement_type(id, process_step_requirement_type)
values (1, 'Custom Field'),
       (2, 'Function');

INSERT INTO flow.object_type(
    object_type, object_code,flow_type_id)
VALUES ('Project','PROJECT',1);

INSERT INTO flow.object_type(
    object_type, object_code,flow_type_id)
VALUES ('Customer','CUSTOMER',1);

INSERT INTO flow.object_type(
    object_type, object_code,flow_type_id)
VALUES ('User','USER',1);

INSERT INTO flow.object_type(
    object_type, object_code,flow_type_id)
VALUES ('Process Step','PROCESS_STEP',2);
insert into flow.object_type(object_type, object_code, flow_type_id)
values ('Organization', 'ORGANIZATION', 1);

insert into flow.company_object_type (object_type_id, company_id)
select 1, 1 where not exists (select id from flow.company_object_type where object_type_id = 1 and company_id = 1 );

insert into flow.company_object_type (object_type_id, company_id)
select 2, 1 where not exists (select id from flow.company_object_type where object_type_id = 2 and company_id = 1 );

insert into flow.company_object_type (object_type_id, company_id)
select 3, 1 where not exists (select id from flow.company_object_type where object_type_id = 3 and company_id = 1 );

insert into flow.company_object_type (object_type_id, company_id)
select 4, 1 where not exists (select id from flow.company_object_type where object_type_id = 4 and company_id = 1 );

insert into flow.company_object_type (object_type_id, company_id)
select 5, 1 where not exists (select id from flow.company_object_type where object_type_id = 5 and company_id = 1 );


insert into flow.company_data_type(company_id, company_data_type, data_type_id)
values(1,'Text',5);
insert into flow.company_data_type(company_id, company_data_type, data_type_id)
values(1,'Date',1);
insert into flow.company_data_type(company_id, company_data_type, data_type_id)
values(1,'Timestamp',2);
insert into flow.company_data_type(company_id, company_data_type, data_type_id)
values(1,'Boolean',3);
insert into flow.company_data_type(company_id, company_data_type, data_type_id)
values(1,'Integer',6);
insert into flow.company_data_type(company_id, company_data_type, data_type_id)
values(1,'Decimal Number',4);
insert into flow.company_data_type(company_id, company_data_type, data_type_id,has_list_values)
values(1,'Dropdown',6,true);
insert into flow.company_data_type(company_id, company_data_type, data_type_id,has_list_values,allow_multiple)
values(1,'Multi-Select',7,true,true);
insert into flow.company_data_type(company_id, company_data_type, data_type_id,has_list_values)
values(1,'System',8,false);

insert into flow.data_type(data_type, custom_behavior, system_list)
select 'System List', false, true where not exists (select id from flow.data_type where data_type = 'System List');

insert into flow.company_data_type(company_id, company_data_type, data_type_id)
select 1, 'System List', 9 where not exists (select id from flow.company_data_type where company_data_type = 'System List');


INSERT INTO flow.data_type_requirement(data_type_id, data_type_value, secondary_requirement, date_created)
VALUES (1, 'current date -', true,now()),
       (1, 'current date +', true,now()),
       (1, 'current date', false,now()),
       (1, 'null', false,now()),
       (1, 'not null', false,now()),
       (2, 'current date -', true,now()),
       (2, 'current date +', true,now()),
       (2, 'current date', false,now()),
       (2, 'timestamp - interval hours', true,now()),
       (2, 'timestamp + interval hours', true,now()),
       (2, 'timestamp', false,now()),
       (2, 'null', false,now()),
       (2, 'not null', false,now()),
       (3, 'true', false ,now()),
       (3, 'false', false ,now()),
       (4, 'null', false ,now()),
       (4, 'not null', false ,now()),
       (5, 'null', false ,now()),
       (5, 'not null', false ,now()),
       (6, 'null', false ,now()),
       (6, 'not null', false ,now()),
       (7, 'null', false ,now()),
       (7, 'not null', false ,now());

insert into flow.data_type_requirement (data_type_id, data_type_value, created_by_id)
select 8, 'null', 2350555  where not exists (select id from flow.data_type_requirement where data_type_id = 8 and data_type_value = 'null');
insert into flow.data_type_requirement (data_type_id, data_type_value, created_by_id)
select 8, 'not null', 2350555  where not exists (select id from flow.data_type_requirement where data_type_id = 8 and data_type_value = 'not null');


insert into flow.data_type_requirement (data_type_id, data_type_value, created_by_id)
select 9, 'null', 2350555  where not exists (select id from flow.data_type_requirement where data_type_id = 9 and data_type_value = 'null');
insert into flow.data_type_requirement (data_type_id, data_type_value, created_by_id)
select 9, 'not null', 2350555  where not exists (select id from flow.data_type_requirement where data_type_id = 9 and data_type_value = 'not null');


insert into flow.key_pattern
    (select * from blueraven.key_pattern);


insert into flow.attachment_type(id, attachment_type,attachment_code,company_id,key_pattern_id,is_system)
    (select id, type,type,1,key_pattern_id,true
     from blueraven.attachment_source_type);

SELECT setval('flow.attachment_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.attachment_type), 1), false);


INSERT INTO flow.attachment(id, filename, content_type, s3_key, size, archived, date_created, date_modified,attachment_type_id)
    (select a.id, filename, content_type, s3_key, size, deleted, created, updated,as1.attachment_source_type_id
     from blueraven.attachment a
              inner join blueraven.attachment_source as1 on as1.attachment_id = a.id);

SELECT setval('flow.attachment_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.attachment), 1), false);

insert into flow.system_value(system_value)values('Current User ID');
insert into flow.system_value(system_value)values('Current Project ID');
