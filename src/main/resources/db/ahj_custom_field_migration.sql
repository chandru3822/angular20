-- MIGRATION *********************************************
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
insert into brs.custom_field_group(id, group_name, object_type_id, group_order)
values (11, 'PTO Details', 2,6);
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
values (18, 'Scheduling with BRS Techincian', 3, 2);
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
     from blueraven.custom_dropdown_field cdf);

--todo: do the weird custom field values that are text (homeowner_required, homeowner_required_on_site, brs_tech_required
-- ac_disconnect_required, meter_can_taps_allowed, pv_production_meter_required, pv_ac_swap_locations, utility_warning_labels_override
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
                and lov.name = cdv.title),
            now(), 99999999
     from blueraven.ahj_design des
              inner join blueraven.custom_dropdown_value cdv on cdv.id = des.structural_post_install_letter_required_id
              inner join blueraven.custom_dropdown_field cdf on cdf.id = cdv.custom_dropdown_field_id
     where structural_post_install_letter_required_id is not null);

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
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_inspection_capacity_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Inspection Capacity per Day', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Placard Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_placard_required_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Placard Required', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Plans Required On-Site',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_plans_required_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Plans Required On-Site', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Followup Method',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_pto_followup_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Followup Method', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Re-inspection Fee Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_reinspection_fee_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Re-inspection Fee Required', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Representative Required On-Site',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_representative_required_onsite_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Representative Required On-Site', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Results Documentation',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_results_documentation_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Results Documentation', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Mid-Point / Rough Inspection Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_rough_inspection_required_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Mid-Point / Rough Inspection Required', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Scheduling Lead Time (Days)',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_scheduling_lead_time_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Scheduling Lead Time (Days)', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Primary Scheduling Method',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_scheduling_method_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Primary Scheduling Method', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Signature Requested At',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_signature_requested_at_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Signature Requested At', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Site Access Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_site_access_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Site Access Required', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('SolaDeck Access Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_soladeck_access_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'SolaDeck Access Required', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Special Documents Required',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_special_documents_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Special Documents Required', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Special Equipment Needed',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_special_equipment_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Special Equipment Needed', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Inspection Submission Method',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_utility_inspection_submission_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Inspection Submission Method', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Utility Method',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_utility_method_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Utility Method', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('Submission Method',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_utility_submission_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Submission Method', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('When to Create Application',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_when_to_create_application_type a)
     ) insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'When to Create Application', 7, now(), 99999999, false from parent p);

-- these 2 are different because they are used for multiple fields
with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('AHJ Submit Type',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_submit_type a)
     ), a as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Payment Method', 7, now(), 99999999, false from parent p) ),
-- todo @scott how to do multiple?
     b as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         (select p.id, 'Submittal Method', 7, now(), 99999999, false from parent p))
insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Pickup Method', 7, now(), 99999999, false from parent p);

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('AHJ Simple List Type',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select a.name,(select p.id from parent p), case when a.name = 'Other' then true else false end,1,now(),2350555,!a.active
           from blueraven.ahj_simple_list_type a)
     ),
     a as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'HOA Approval Required for Submission', 7, now(), 99999999, false from parent p)),
     b as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'NEM Approval Required for Submission', 7, now(), 99999999, false from parent p)),
     c as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Rebate Program', 7, now(), 99999999, false from parent p)),
     d as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Signature Req''d Prior to Submission', 7, now(), 99999999, false from parent p)),
     e as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Customer Signature Required for Resubmission', 7, now(), 99999999, false from parent p)),
     f as ( insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'Interconnection Fee', 7, now(), 99999999, false from parent p))
insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
    ( select p.id, 'Utility Inspection Required', 7, now(), 99999999, false from parent p)



-- alter table blueraven.custom_dropdown_field
--     add column custom_field_group_id integer;
--
-- update blueraven.custom_dropdown_field set custom_field_group_id = 12 where id = 1;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 12 where id = 2;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 13 where id = 3;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 13 where id = 4;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 14 where id = 5;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 14 where id = 6;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 14 where id = 7;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 14 where id = 8;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 15 where id = 9;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 15 where id = 10;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 15 where id = 11;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 12;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 13;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 14;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 15;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 16;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 17;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 18;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 19;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 16 where id = 20;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 13 where id = 21;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 9 where id = 22;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 9 where id = 23;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 9 where id = 24;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 9 where id = 25;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 13 where id = 26;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 17 where id = 27;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 22 where id = 28;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 22 where id = 29;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 9 where id = 30;
-- update blueraven.custom_dropdown_field set custom_field_group_id = 13 where id = 31;
