-- MIGRATION *********************************************
-- todo: this needs to happen in blueraven schema first. verify that no new groups were added since I wrote this:

-- alter table blueraven.custom_dropdown_field
--     add column custom_field_group_id integer;
--
update blueraven.custom_dropdown_field set custom_field_group_id = 12 where id = 1;
update blueraven.custom_dropdown_field set custom_field_group_id = 12 where id = 2;
update blueraven.custom_dropdown_field set custom_field_group_id = 13 where id = 3;
update blueraven.custom_dropdown_field set custom_field_group_id = 13 where id = 4;
update blueraven.custom_dropdown_field set custom_field_group_id = 14 where id = 5;
update blueraven.custom_dropdown_field set custom_field_group_id = 14 where id = 6;
update blueraven.custom_dropdown_field set custom_field_group_id = 14 where id = 7;
update blueraven.custom_dropdown_field set custom_field_group_id = 14 where id = 8;
update blueraven.custom_dropdown_field set custom_field_group_id = 15 where id = 9;
update blueraven.custom_dropdown_field set custom_field_group_id = 15 where id = 10;
update blueraven.custom_dropdown_field set custom_field_group_id = 15 where id = 11;
update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 12;
update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 13;
update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 14;
update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 15;
update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 16;
update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 17;
update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 18;
update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 19;
update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 20;
update blueraven.custom_dropdown_field set custom_field_group_id = 13 where id = 21;
update blueraven.custom_dropdown_field set custom_field_group_id = 9 where id = 22;
update blueraven.custom_dropdown_field set custom_field_group_id = 9 where id = 23;
update blueraven.custom_dropdown_field set custom_field_group_id = 9 where id = 24;
update blueraven.custom_dropdown_field set custom_field_group_id = 9 where id = 25;
update blueraven.custom_dropdown_field set custom_field_group_id = 13 where id = 26;
update blueraven.custom_dropdown_field set custom_field_group_id = 17 where id = 27;
update blueraven.custom_dropdown_field set custom_field_group_id = 22 where id = 28;
update blueraven.custom_dropdown_field set custom_field_group_id = 22 where id = 29;
update blueraven.custom_dropdown_field set custom_field_group_id = 9 where id = 30;
update blueraven.custom_dropdown_field set custom_field_group_id = 13 where id = 31;


-- create the data types
insert into brs.data_type (data_type)
select 'date' where not exists (select id from brs.data_type where data_type = 'date');
insert into brs.data_type (data_type)
select 'timestamp' where not exists (select id from brs.data_type where data_type = 'timestamp');
insert into brs.data_type (data_type)
select 'boolean' where not exists (select id from brs.data_type where data_type = 'boolean');
insert into brs.data_type (data_type)
select 'numeric' where not exists (select id from brs.data_type where data_type = 'numeric');
insert into brs.data_type (data_type)
select 'text' where not exists (select id from brs.data_type where data_type = 'text');
insert into brs.data_type (data_type)
select 'integer' where not exists (select id from brs.data_type where data_type = 'integer');
insert into brs.data_type (data_type, has_list_values, allow_multiple)
select 'dropdown', true, false where not exists (select id from brs.data_type where data_type = 'dropdown');
insert into brs.data_type (data_type, has_list_values, allow_multiple)
select 'integer array', true, true where not exists (select id from brs.data_type where data_type = 'integer array');

-- create the object types
insert into brs.object_type(object_type, object_code)
    (select cds.screen, cds.code from blueraven.custom_dropdown_screen cds where not exists(select id from brs.object_type where object_code = 'AHJ_DESIGN'));
insert into brs.object_type(object_type, object_code)
    (select cds.screen, cds.code from blueraven.custom_dropdown_screen cds where not exists(select id from brs.object_type where object_code = 'AHJ_UTILITY'));
insert into brs.object_type(object_type, object_code)
    (select cds.screen, cds.code from blueraven.custom_dropdown_screen cds where not exists(select id from brs.object_type where object_code = 'AHJ_INSPECTION'));
insert into brs.object_type(object_type, object_code)
    (select 'AHJ Permit','AHJ_PERMIT' from blueraven.custom_dropdown_screen cds where not exists(select id from brs.object_type where object_code = 'AHJ_PERMIT'));

-- create the custom_field_groups
-- ahj_permit (4)
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (1, 'Submission Details', 4, 1);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (2, 'Revision Submission Details', 4, 2);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (3, 'As-Built Submission Details', 4, 3);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (4, 'Follow-up / Approval Details', 4, 4);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (5, 'Delivery Details', 4, 5);
-- ahj_utility (2)
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (6, 'Rejections', 2, 1);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (7, 'Utility Rates', 2, 2);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (8, 'Customer Signatures', 2, 3);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (9, 'Design Utility Requirements', 2, 4);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (10, 'Submission Details', 2, 5);
-- this one is out of order because i forgot to add it and didn't want to go back and fix the id's i had already mapped
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (23, 'Approval Details', 2, 6);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (11, 'PTO Details', 2,7);
-- ahj_design (1)
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (12, 'Codes', 1, 1);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (13, 'Engineering', 1, 2);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (14, 'Design Requirements', 1, 3);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (15, 'Electrical Requirements', 1, 4);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (16, 'Structural Requirements', 1, 5);
-- ahj_inspection (3)
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (17, 'Scheduling with AHJ', 3, 1);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (18, 'Scheduling with BRS Technician', 3, 2);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (19, 'Scheduling with Customer', 3, 3);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (20, 'Obtaining Results', 3, 4);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (21, 'Re-inspections', 3, 5);
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (22, 'In-House MPUs', 3, 6);
SELECT setval('brs.custom_field_group_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.custom_field_group), 1), false);


-- migrate fields from blueraven.custom_dropdown_fields with null list of values
insert into brs.custom_field(id, list_of_value_id, field_name, field_code, data_type_id, date_created, created_by_id, archived)
    (select id, null, field, code, 7, now(), 99999999, archived from blueraven.custom_dropdown_field);
SELECT setval('brs.custom_field_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.custom_field), 1), false);

-- create parent list of value rows and
--temporarily set parent_id to the custom_field_id and the code field
insert into brs.list_of_value (name, code, parent_id, show_other, display_order, date_created, created_by_id, archived)
    (select field_name, 'delete_me_later', id, false, 1, now(), 99999999, archived from brs.custom_field);

-- update the custom_field list_of_value_id
update brs.custom_field cf
set list_of_value_id = (select lov.id from brs.list_of_value lov where parent_id = cf.id)
--just added where clause so it wouldn't warn me about updating the entire table
where cf.id < 100;

-- migrate the dropdown options use parent id do find the right field
insert into brs.list_of_value(name, code, parent_id, show_other, display_order, date_created, created_by_id, archived)
    (select title, null, (select id from brs.list_of_value where parent_id = custom_dropdown_field_id), false, display_order, now(), 99999999, archived from blueraven.custom_dropdown_value);

-- remove the temporary parent_id and code
update brs.list_of_value  set parent_id = null, code = null where code = 'delete_me_later';

-- add the parent_id constraint now - we didn't add it before so that we could use the parent_id column for something else during migration
alter table brs.list_of_value drop constraint if exists brs_lov_parent_id_fk;
alter table brs.list_of_value add CONSTRAINT brs_lov_parent_id_fk FOREIGN KEY (parent_id)
    REFERENCES brs.list_of_value (id);

-- custom_dropdown_field - create custom_field_group_assignment
insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
    (select
         cdf.custom_field_group_id,
         cdf.id, 1, false, now(), 99999999
     from blueraven.custom_dropdown_field cdf
     where cdf.id not in (34,35,33));


-- these are the inserts for the custom_dropdown_value columns
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.electrical_code_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where electrical_code_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.building_code_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where building_code_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.electrical_engineer_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where electrical_engineer_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.structural_engineer_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where structural_engineer_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.standard_racking_equipment_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where standard_racking_equipment_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.railless_landscape_attachment_spacing_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where railless_landscape_attachment_spacing_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.fire_setbacks_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where fire_setbacks_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.railless_portrait_attachment_spacing_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where railless_portrait_attachment_spacing_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.standard_conduit_run_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where standard_conduit_run_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.warning_labels_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where warning_labels_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.supplemental_ground_rod_required_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where supplemental_ground_rod_required_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.load_standard_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where load_standard_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.wood_standard_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where wood_standard_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.ult_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where ult_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.seismic_design_category_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where seismic_design_category_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.roof_snow_load_ahj_override_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where roof_snow_load_ahj_override_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.snow_load_reduction_allowed_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where snow_load_reduction_allowed_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.wind_exposure_factor_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where wind_exposure_factor_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.wind_exposure_factor_ahj_override_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where wind_exposure_factor_ahj_override_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.risk_category_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where risk_category_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.stamp_type_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where stamp_type_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select des.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.structural_post_install_letter_required_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where structural_post_install_letter_required_id is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select utl.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_utility utl
              inner join blueraven.custom_dropdown_value cdv on cdv.id = utl.ac_disconnect_required
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where ac_disconnect_required is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select utl.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_utility utl
              inner join blueraven.custom_dropdown_value cdv on cdv.id = utl.meter_can_taps_allowed
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where meter_can_taps_allowed is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select utl.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_utility utl
              inner join blueraven.custom_dropdown_value cdv on cdv.id = utl.pv_production_meter_required
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where pv_production_meter_required is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select utl.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_utility utl
              inner join blueraven.custom_dropdown_value cdv on cdv.id = utl.pv_ac_swap_locations
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where pv_ac_swap_locations is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select utl.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_utility utl
              inner join blueraven.custom_dropdown_value cdv on cdv.id = utl.utility_warning_labels_override
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where utility_warning_labels_override is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_inspection insp
              inner join blueraven.custom_dropdown_value cdv on cdv.id = insp.homeowner_required
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where homeowner_required is not null);

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            ( select id from brs.custom_field_group_assignment cfga
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id ),
            null,
            ( select lov.id from brs.custom_field_group_assignment cfga
                                     inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id
              where cfga.custom_field_group_id = cdf.custom_field_group_id
                and cfga.custom_field_id = cdf.id
                and lov.archived is not true
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_inspection insp
              inner join blueraven.custom_dropdown_value cdv on cdv.id = insp.brs_tech_required
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where brs_tech_required is not null);

--these one is different because the value of the field was text instead of id's. have to create the custom field first
with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Homeowner Required to be On-Site',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
          values ('Yes', (select p.id from parent p), false,1,now(),2350555, false ),
                 ('No', (select p.id from parent p), false,1,now(),2350555, false ),
                 ('Unknown', (select p.id from parent p), false,1,now(),2350555, false ),
                 ('false', (select p.id from parent p), false,1,now(),2350555, false )
          ),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Homeowner Required to be On-Site', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 19, cf.id, 1, false, now(), 99999999 from cf) returning id)
    insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
        (select insp.id,
                (select id from cfga),
                null,
                null,
                now(),
                99999999
         from blueraven.ahj_inspection insp
         where insp.homeowner_required_on_site is not null
        );
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = a.homeowner_required_on_site
     ) as v
where id = cfv_id;
-- this one is like the one above it
with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Fall Protection for Inspector Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         values ('Yes', (select p.id from parent p), false,1,now(),2350555, false ),
                ('No', (select p.id from parent p), false,1,now(),2350555, false ),
                ('Unknown', (select p.id from parent p), false,1,now(),2350555, false )
     ),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Fall Protection for Inspector Required', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 18, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            null,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.fall_protection_required is not null
    );
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = a.fall_protection_required
     ) as v
where id = cfv_id;
-- this one is like the one above it
with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Call For Time Window',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         values ('Yes', (select p.id from parent p), false,1,now(),2350555, false ),
                ('No', (select p.id from parent p), false,1,now(),2350555, false ),
                ('Unknown', (select p.id from parent p), false,1,now(),2350555, false )
     ),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Call For Time Window', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 19, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            null,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.call_for_time_window is not null
    );
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = a.call_for_time_window
     ) as v
where id = cfv_id;

-- TYPE TABLES: create list_of_values and their custom_fields for the type tables (above was for the custom_dropdown_values
-- todo: update the rest of the queries to match this first one
with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Information to have Handy',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_handy_information_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Information to have Handy', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 17, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.handy_information_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.handy_information_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_handy_information_type hit on hit.id = a.handy_information_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Inspection Capacity per Day',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_inspection_capacity_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Inspection Capacity per Day', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 17, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.inspection_capacity_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.inspection_capacity_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_inspection_capacity_type hit on hit.id = a.inspection_capacity_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Placard Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_placard_required_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Placard Required', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 17, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.placard_required_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.placard_required_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_placard_required_type hit on hit.id = a.placard_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Plans Required On-Site',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_plans_required_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Plans Required On-Site', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 18, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.plans_required_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.plans_required_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_plans_required_type hit on hit.id = a.plans_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Followup Method',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_pto_followup_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Followup Method', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 11, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.followup_method_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.followup_method_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_pto_followup_type hit on hit.id = a.followup_method_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Re-inspection Fee Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_reinspection_fee_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Re-inspection Fee Required', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 21, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.reinspection_fee_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.reinspection_fee_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_reinspection_fee_type hit on hit.id = a.reinspection_fee_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Representative Required On-Site',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_representative_required_onsite_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Representative Required On-Site', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 18, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.representative_required_onsite_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.representative_required_onsite_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_representative_required_onsite_type hit on hit.id = a.representative_required_onsite_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Results Documentation',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_results_documentation_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Results Documentation', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 20, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.results_documentation_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.results_documentation_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_results_documentation_type hit on hit.id = a.results_documentation_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Mid-Point / Rough Inspection Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_rough_inspection_required_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Mid-Point / Rough Inspection Required', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 17, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.rough_inspection_required_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.rough_inspection_required_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_rough_inspection_required_type hit on hit.id = a.rough_inspection_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Customer Scheduling Lead Time (Days)',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_scheduling_lead_time_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Customer Scheduling Lead Time (Days)', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 17, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.scheduling_lead_time_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.scheduling_lead_time_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_scheduling_lead_time_type hit on hit.id = a.scheduling_lead_time_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('AHJ Maximum Advanced Scheduling (Days)',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select cdv.title,(select p.id from parent p), case when cdv.title = 'Other' then true else false end,1,now(),2350555, cdv.archived
           from blueraven.custom_dropdown_value cdv
           where cdv.custom_dropdown_field_id = 32)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'AHJ Maximum Advanced Scheduling (Days)', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 17, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.ahj_max_advanced_scheduling_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.ahj_max_advanced_scheduling_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.custom_dropdown_value cdv on cdv.id = a.ahj_max_advanced_scheduling_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = cdv.title
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Primary Scheduling Method',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_scheduling_method_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Primary Scheduling Method', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 17, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.scheduling_method_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.scheduling_method_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_scheduling_method_type hit on hit.id = a.scheduling_method_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Signature Requested At',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_signature_requested_at_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Signature Requested At', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 8, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.signature_requested_at_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.signature_requested_at_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_signature_requested_at_type hit on hit.id = a.signature_requested_at_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Site Access Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_site_access_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Site Access Required', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 17, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.site_access_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.site_access_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_site_access_type hit on hit.id = a.site_access_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('SolaDeck Access Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_soladeck_access_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'SolaDeck Access Required', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 17, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.soladeck_access_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.soladeck_access_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_soladeck_access_type hit on hit.id = a.soladeck_access_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Special Documents Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_special_documents_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Special Documents Required', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 18, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.special_documents_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.special_documents_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_special_documents_type hit on hit.id = a.special_documents_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Special Equipment Needed',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_special_equipment_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Special Equipment Needed', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 18, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.special_equipment_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.special_equipment_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_special_equipment_type hit on hit.id = a.special_equipment_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Inspection Submission Method',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_utility_inspection_submission_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Inspection Submission Method', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 11, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.inspection_submission_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.inspection_submission_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_utility_inspection_submission_type hit on hit.id = a.inspection_submission_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Utility Method',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_utility_method_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Utility Method', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 11, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.utility_method_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.utility_method_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_utility_method_type hit on hit.id = a.utility_method_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Submission Method',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_utility_submission_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Submission Method', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 10, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.submission_method_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.submission_method_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_utility_submission_type hit on hit.id = a.submission_method_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('When to Create Application',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_when_to_create_application_type a)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'When to Create Application', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 10, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select id from cfga),
            insp.when_to_create_application_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.when_to_create_application_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_when_to_create_application_type hit on hit.id = a.when_to_create_application_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

-- these 2 are different because they are used for multiple fields
with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('AHJ Submit Type',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555, not a.active
           from blueraven.ahj_submit_type a)
     ),
     -- payment
     pm_cf as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
        ( select p.id, 'Payment Method', 7, now(), 99999999, false from parent p) returning id ),
     pm_sd_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 1, pm_cf.id, 1, false, now(), 99999999 from pm_cf) returning id),
     pm_sd_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select id from pm_sd_cfga),
                 perm.submission_payment_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.submission_payment_type_id is not null
         )),
     pm_rsd_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 2, pm_cf.id, 1, false, now(), 99999999 from pm_cf) returning id),
     pm_rsd_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select id from pm_rsd_cfga),
                 perm.revision_payment_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.revision_payment_type_id is not null
         )),
     pm_absd_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 3, pm_cf.id, 1, false, now(), 99999999 from pm_cf) returning id),
     pm_absd_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select id from pm_absd_cfga),
                 perm.as_built_submittal_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.as_built_payment_type_id is not null
         )),
     pm_fu_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 4, pm_cf.id, 1, false, now(), 99999999 from pm_cf) returning id),
     pm_fu_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select id from pm_fu_cfga),
                 perm.follow_up_payment_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.follow_up_payment_type_id is not null
         )),
     pm_dd_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 5, pm_cf.id, 1, false, now(), 99999999 from pm_cf) returning id),
     pm_dd_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select id from pm_fu_cfga),
                 perm.delivery_payment_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.delivery_payment_type_id is not null
         )),
     -- submittal
     sm_cf as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         (select p.id, 'Submittal Method', 7, now(), 99999999, false from parent p) returning id),
     sm_sd_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 1, sm_cf.id, 1, false, now(), 99999999 from sm_cf) returning id),
     sm_sd_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select id from sm_sd_cfga),
                 perm.submittal_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.submittal_type_id is not null
         )),
     sm_rsd_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 2, sm_cf.id, 1, false, now(), 99999999 from sm_cf) returning id),
     sm_rsd_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select id from sm_rsd_cfga),
                 perm.revision_submittal_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.revision_submittal_type_id is not null
         )),
     sm_absd_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 3, sm_cf.id, 1, false, now(), 99999999 from sm_cf) returning id),
     sm_absd_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select id from sm_absd_cfga),
                 perm.as_built_submittal_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.as_built_submittal_type_id is not null
         )),
     -- pickup
     pk_cf as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
            ( select p.id, 'Pickup Method', 7, now(), 99999999, false from parent p) returning id),
     pk_dd_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 5, pk_cf.id, 1, false, now(), 99999999 from pk_cf) returning id)
    -- pk_dd_cfv as
    insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
     (select perm.id,
             (select id from pk_dd_cfga),
             perm.delivery_pickup_type_other,
             null,
             now(),
             99999999
      from blueraven.ahj_permit perm
      where perm.delivery_pickup_type_id is not null
     )
;
-- update all the lovs for the custom_field_value rows that were just created
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.submission_payment_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.revision_payment_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.as_built_payment_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.follow_up_payment_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.delivery_payment_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.submittal_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.revision_submittal_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.as_built_submittal_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.delivery_pickup_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

-- todo: need to finish this field like above but i need to test the one above first.

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('AHJ Simple List Type',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,not a.active
           from blueraven.ahj_simple_list_type a)
     ),
     hoa_cf as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'HOA Approval Required for Submission', 7, now(), 99999999, false from parent p) returning id),
     hoa_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 1, hoa_cf.id, 1, false, now(), 99999999 from hoa_cf) returning id),
     hoa_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select id from hoa_cfga),
                 perm.hoa_approval_required_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.hoa_approval_required_type_id is not null
         )),
     nem_cf as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'NEM Approval Required for Submission', 7, now(), 99999999, false from parent p) returning id),
     nem_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 1, nem_cf.id, 1, false, now(), 99999999 from nem_cf) returning id),
     nem_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select id from nem_cfga),
                 perm.nem_approval_required_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.nem_approval_required_type_id is not null
         )),
     rp_cf as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Rebate Program', 7, now(), 99999999, false from parent p) returning id),
     rp_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 7, rp_cf.id, 1, false, now(), 99999999 from rp_cf) returning id),
     rp_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select util.id,
                 (select id from rp_cfga),
                 util.rebate_program_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_utility util
          where util.rebate_program_type_id is not null
         )),
     sr_cf as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Signature Req''d Prior to Submission', 7, now(), 99999999, false from parent p) returning id),
     sr_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 8, sr_cf.id, 1, false, now(), 99999999 from sr_cf) returning id),
     sr_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select util.id,
                 (select id from sr_cfga),
                 util.signature_required_prior_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_utility util
          where util.signature_required_prior_type_id is not null
         )),
     cs_cf as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Customer Signature Required for Resubmission', 7, now(), 99999999, false from parent p) returning id),
     cs_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 23, cs_cf.id, 1, false, now(), 99999999 from cs_cf) returning id),
     cs_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select util.id,
                 (select id from cs_cfga),
                 util.customer_signature_resubmission_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_utility util
          where util.customer_signature_resubmission_type_id is not null
         )),
     if_cf as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Interconnection Fee', 7, now(), 99999999, false from parent p) returning id),
     if_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
        (select 10, if_cf.id, 1, false, now(), 99999999 from if_cf) returning id),
     if_cfv as (insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
        (select util.id,
                (select id from if_cfga),
                util.interconnection_fee_type_other,
                null,
                now(),
                99999999
            from blueraven.ahj_utility util
            where util.interconnection_fee_type_id is not null
        )),
     ir_cf as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Utility Inspection Required', 7, now(), 99999999, false from parent p) returning id),
     ir_cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
        (select 11, ir_cf.id, 1, false, now(), 99999999 from ir_cf) returning id)
    -- ir_cfv as (
         insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
        (select util.id,
                (select id from ir_cfga),
                util.utility_inspection_required_type_other,
                null,
                now(),
                99999999
            from blueraven.ahj_utility util
            where util.utility_inspection_required_type_id is not null
        );

-- update lovs for the custom_field_value rows just added
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.hoa_approval_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.nem_approval_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.rebate_program_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.signature_required_prior_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.customer_signature_resubmission_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.interconnection_fee_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.utility_inspection_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

-- these are the fields for
-- ADD INTERCONNECTION APPLICATION SIGNATURE CUSTOM FIELD AND LIST OF VALUES
insert into brs.list_of_value(name, code, parent_id, display_order, created_by_id)
select 'Interconnection Application Signature', 'INTERCONNECTION_APPLICATION_SIGNATURE', null, 1, 2350555
where not exists (
        select id
        from brs.list_of_value
        where code = 'INTERCONNECTION_APPLICATION_SIGNATURE'
    )
;
insert into brs.list_of_value(name, code, parent_id, display_order, created_by_id)
select 'Before Submission', 'IAS_BEFORE_SUBMISSION', (select id from brs.list_of_value where code = 'INTERCONNECTION_APPLICATION_SIGNATURE' ), 2, 2350555
where not exists (
        select id
        from brs.list_of_value
        where code = 'IAS_BEFORE_SUBMISSION'
    )
;
insert into brs.list_of_value(name, code, parent_id, display_order, created_by_id)
select 'After Submission', 'IAS_AFTER_SUBMISSION', (select id from brs.list_of_value where code = 'INTERCONNECTION_APPLICATION_SIGNATURE' ), 3, 2350555
where not exists (
        select id
        from brs.list_of_value
        where code = 'IAS_AFTER_SUBMISSION'
    )
;
insert into brs.list_of_value(name, code, parent_id, display_order, created_by_id)
select 'Before and After Submission', 'IAS_BEFORE_AND_AFTER_SUBMISSION', (select id from brs.list_of_value where code = 'INTERCONNECTION_APPLICATION_SIGNATURE' ), 4, 2350555
where not exists (
        select id
        from brs.list_of_value
        where code = 'IAS_BEFORE_AND_AFTER_SUBMISSION'
    )
;
insert into brs.custom_field(list_of_value_id, field_name, field_code, data_type_id, created_by_id)
select (select id from brs.list_of_value where code = 'INTERCONNECTION_APPLICATION_SIGNATURE'), 'Interconnection Application Signature', 'INTERCONNECTION_APPLICATION_SIGNATURE', 7, 2350555
where not exists (
        select id
        from brs.custom_field
        where field_code = 'INTERCONNECTION_APPLICATION_SIGNATURE'
    )
;
insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, created_by_id)
select 8, (select id from brs.custom_field where field_code = 'INTERCONNECTION_APPLICATION_SIGNATURE'), 3, 2350555
where not exists (
        select id
        from brs.custom_field_group_assignment
        where custom_field_id = (select id from brs.custom_field where field_code = 'INTERCONNECTION_APPLICATION_SIGNATURE')
    )
;

