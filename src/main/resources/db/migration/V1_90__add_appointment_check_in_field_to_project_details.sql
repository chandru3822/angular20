insert into brs.project_details_config(company_id, custom_field_group_assignment_id, field_to_update, data_type_id)
(select 3, 1377, 'appointment_check_in', 2
    where not exists (select company_id from brs.project_details_config
        where company_id = 3 and custom_field_group_assignment_id = 1377 and field_to_update = 'appointment_check_in' and data_type_id = 2));

alter table brs.project_details add column if not exists appointment_check_in timestamp;
create index if not exists pd_appointment_check_in_idx on brs.project_details (appointment_check_in);
