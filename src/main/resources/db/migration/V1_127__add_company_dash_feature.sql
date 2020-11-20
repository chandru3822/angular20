drop table if exists brs.company_dashboard_targets;

create table if not exists brs.company_dashboard_targets (
    id                              serial not null primary key,
    target_date                     date,
    bookings_brs                    integer,
    bookings_partner                integer,
    final_designs_approved_brs      integer,
    final_designs_approved_partner  integer,
    substantial_completions_brs     integer,
    substantial_completions_partner integer,
    final_completions_brs           integer,
    final_completions_partner       integer
);

insert into flow.feature(feature_name, feature_code, feature_path)
select 'Company Dashboard', 'COMPANY_DASHBOARD', '/companyDashboard'
where not exists (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD');

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 2, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 2);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 3, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 3);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 4, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 4);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 5, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 5);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 6, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 6);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 7, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 7);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 8, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 8);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 10, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 10);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 11, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 11);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 12, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 12);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 13, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 13);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 14, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 14);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 15, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 15);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 16, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 16);

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Company Dashboard', 17, (select id from flow.feature where feature_code = 'COMPANY_DASHBOARD')
where not exists (select id from flow.company_feature where feature_name = 'Company Dashboard' and company_id = 17);

insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
(select 3, 67, 'permit_pack_complete', 1, 'Permit Pack Complete'
    where not exists (
        select company_id from brs.project_details_config
        where company_id = 3
            and custom_field_group_assignment_id = 67
            and field_to_update = 'permit_pack_complete'
            and data_type_id = 1
            and display_name = 'Permit Pack Complete'
    )
);
alter table brs.project_details add column if not exists permit_pack_complete date;
create index if not exists pd_permit_pack_complete_idx on brs.project_details (permit_pack_complete);

insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 1190, 'installation_scheduled', 1, 'Installation Scheduled'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 1190
               and field_to_update = 'installation_scheduled'
               and data_type_id = 1
               and display_name = 'Installation Scheduled'
         )
    );
alter table brs.project_details add column if not exists installation_scheduled date;
create index if not exists pd_installation_scheduled_idx on brs.project_details (installation_scheduled);

insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 1194, 'ahj_inspection_scheduled_date', 1, 'AHJ Inspection Scheduled'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 1194
               and field_to_update = 'ahj_inspection_scheduled_date'
               and data_type_id = 1
               and display_name = 'AHJ Inspection Scheduled'
         )
    );
insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 1195, 'ahj_inspection_scheduled_date', 1, 'AHJ Inspection Scheduled'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 1195
               and field_to_update = 'ahj_inspection_scheduled_date'
               and data_type_id = 1
               and display_name = 'AHJ Inspection Scheduled'
         )
    );
alter table brs.project_details add column if not exists ahj_inspection_scheduled_date date;
create index if not exists pd_ahj_inspection_scheduled_date_idx on brs.project_details (ahj_inspection_scheduled_date);

insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 148, 'ahj_inspection_start_time', 2, 'AHJ Inspection Start Time'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 148
               and field_to_update = 'ahj_inspection_start_time'
               and data_type_id = 2
               and display_name = 'AHJ Inspection Start Time'
         )
    );
insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 651, 'ahj_inspection_start_time', 2, 'AHJ Inspection Start Time'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 651
               and field_to_update = 'ahj_inspection_start_time'
               and data_type_id = 2
               and display_name = 'AHJ Inspection Start Time'
         )
    );
insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 648, 'ahj_inspection_start_time', 2, 'AHJ Inspection Start Time'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 648
               and field_to_update = 'ahj_inspection_start_time'
               and data_type_id = 2
               and display_name = 'AHJ Inspection Start Time'
         )
    );
insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 928, 'ahj_inspection_start_time', 2, 'AHJ Inspection Start Time'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 928
               and field_to_update = 'ahj_inspection_start_time'
               and data_type_id = 2
               and display_name = 'AHJ Inspection Start Time'
         )
    );
insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 934, 'ahj_inspection_start_time', 2, 'AHJ Inspection Start Time'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 934
               and field_to_update = 'ahj_inspection_start_time'
               and data_type_id = 2
               and display_name = 'AHJ Inspection Start Time'
         )
    );
insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 937, 'ahj_inspection_start_time', 2, 'AHJ Inspection Start Time'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 937
               and field_to_update = 'ahj_inspection_start_time'
               and data_type_id = 2
               and display_name = 'AHJ Inspection Start Time'
         )
    );
insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 956, 'ahj_inspection_start_time', 2, 'AHJ Inspection Start Time'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 956
               and field_to_update = 'ahj_inspection_start_time'
               and data_type_id = 2
               and display_name = 'AHJ Inspection Start Time'
         )
    );
insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 959, 'ahj_inspection_start_time', 2, 'AHJ Inspection Start Time'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 959
               and field_to_update = 'ahj_inspection_start_time'
               and data_type_id = 2
               and display_name = 'AHJ Inspection Start Time'
         )
    );
insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 1016, 'ahj_inspection_start_time', 2, 'AHJ Inspection Start Time'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 1016
               and field_to_update = 'ahj_inspection_start_time'
               and data_type_id = 2
               and display_name = 'AHJ Inspection Start Time'
         )
    );
insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 1042, 'ahj_inspection_start_time', 2, 'AHJ Inspection Start Time'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 1042
               and field_to_update = 'ahj_inspection_start_time'
               and data_type_id = 2
               and display_name = 'AHJ Inspection Start Time'
         )
    );
insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 578, 'ahj_inspection_start_time', 2, 'AHJ Inspection Start Time'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 578
               and field_to_update = 'ahj_inspection_start_time'
               and data_type_id = 2
               and display_name = 'AHJ Inspection Start Time'
         )
    );
alter table brs.project_details add column if not exists ahj_inspection_start_time date;
create index if not exists pd_ahj_inspection_start_time_idx on brs.project_details (ahj_inspection_start_time);

insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 1210, 'verified_inspection_approval_received_by_utility_date', 1, 'Verified Inspection Approval Received by Utility'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 1210
               and field_to_update = 'verified_inspection_approval_received_by_utility_date'
               and data_type_id = 1
               and display_name = 'Verified Inspection Approval Received by Utility'
         )
    );
alter table brs.project_details add column if not exists verified_inspection_approval_received_by_utility_date date;
create index if not exists pd_verified_inspection_approval_received_by_utility_date_idx on brs.project_details (verified_inspection_approval_received_by_utility_date);

insert into brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id, display_name)
    (select 3, 154, 'ahj_inspection_approval_submitted_date', 1, 'AHJ Inspection Approval Submitted to Utility'
     where not exists (
             select company_id from brs.project_details_config
             where company_id = 3
               and custom_field_group_assignment_id = 154
               and field_to_update = 'ahj_inspection_approval_submitted_date'
               and data_type_id = 1
               and display_name = 'AHJ Inspection Approval Submitted to Utility'
         )
    );
alter table brs.project_details add column if not exists ahj_inspection_approval_submitted_date date;
create index if not exists pd_ahj_inspection_approval_submitted_date_idx on brs.project_details (ahj_inspection_approval_submitted_date);
