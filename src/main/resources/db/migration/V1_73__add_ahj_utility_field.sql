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
