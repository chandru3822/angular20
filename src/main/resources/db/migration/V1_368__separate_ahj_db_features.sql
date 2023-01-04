alter table flow.company_feature add column if not exists parent_company_feature_id int;
alter table flow.company_feature add column if not exists has_permissions boolean not null default true;
alter table flow.company_feature add column if not exists show_in_tools boolean not null default true;
update flow.company_feature set feature_name = 'Database' where feature_name = 'AHJ Database';
update flow.feature set feature_name = 'AHJ', feature_code='AHJ' where feature_name = 'AHJ Database';
insert into flow.feature(feature_name, feature_code, feature_path)
select 'Database', 'DATABASE', '/database' where not exists(
        select id from flow.feature where feature_name = 'Database'
    );
insert into flow.feature(feature_name, feature_code, feature_path)
select 'Utility', 'UTILITY', '/database/utility' where not exists(
        select id from flow.feature where feature_name = 'Utility'
    );
insert into flow.feature(feature_name, feature_code, feature_path)
select 'HOA', 'HOA', '/database/hoa' where not exists(
        select id from flow.feature where feature_name = 'HOA'
    );
insert into flow.company_feature(feature_name, company_id, feature_id, home_page, parent_company_feature_id)
select 'AHJ', 3, (select id from flow.feature where feature_name = 'AHJ'), true, (select id from flow.feature where feature_name = 'Database') where not exists(
        select id from flow.company_feature where feature_name = 'AHJ'
    );
insert into flow.company_feature(feature_name, company_id, feature_id, home_page, parent_company_feature_id)
select 'Utility', 3, (select id from flow.feature where feature_name = 'Utility'), true, (select id from flow.feature where feature_name = 'Database') where not exists(
    select id from flow.company_feature where feature_name = 'Utility'
);
insert into flow.company_feature(feature_name, company_id, feature_id, home_page, parent_company_feature_id)
select 'HOA', 3, (select id from flow.feature where feature_name = 'HOA'), true, (select id from flow.feature where feature_name = 'Database') where not exists(
        select id from flow.company_feature where feature_name = 'HOA'
    );
insert into flow.company_feature(feature_name, company_id, feature_id, home_page, parent_company_feature_id)
select 'HOA', 3, (select id from flow.feature where feature_name = 'HOA'), true, (select id from flow.feature where feature_name = 'Database') where not exists(
        select id from flow.company_feature where feature_name = 'HOA'
    );
update flow.company_feature set show_in_tools = false, has_permissions = false, feature_id =
  (select id from flow.feature where feature_name = 'Database') where feature_name = 'Database';
insert into flow.feature(feature_name, feature_code, feature_path)
select 'Utility', 'UTILITY', '/database/utility' where not exists(
        select id from flow.feature where feature_name = 'Utility'
    );
insert into flow.feature(feature_name, feature_code, feature_path)
select 'HOA', 'HOA', '/database/hoa' where not exists(
        select id from flow.feature where feature_name = 'HOA'
    );
insert into flow.company_feature(feature_name, company_id, feature_id, home_page, parent_company_feature_id)
select 'AHJ', 3, (select id from flow.feature where feature_name = 'AHJ'), true, (select id from flow.feature where feature_name = 'Database') where not exists(
        select id from flow.company_feature where feature_name = 'AHJ'
    );
insert into flow.company_feature(feature_name, company_id, feature_id, home_page, parent_company_feature_id)
select 'Utility', 3, (select id from flow.feature where feature_name = 'Utility'), true, (select id from flow.feature where feature_name = 'Database') where not exists(
        select id from flow.company_feature where feature_name = 'Utility'
    );
insert into flow.company_feature(feature_name, company_id, feature_id, home_page, parent_company_feature_id)
select 'HOA', 3, (select id from flow.feature where feature_name = 'HOA'), true, (select id from flow.feature where feature_name = 'Database') where not exists(
        select id from flow.company_feature where feature_name = 'HOA'
    );
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select id from flow.company_feature where feature_name = 'HOA'), 1, 2453836, 2453836 where not exists(
        select id from flow.feature_access_control where feature_id = (select id from flow.company_feature where feature_name = 'HOA') and access_control_id = 1);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select id from flow.company_feature where feature_name = 'HOA'), 2, 2453836, 2453836 where not exists(
        select id from flow.feature_access_control where feature_id = (select id from flow.company_feature where feature_name = 'HOA') and access_control_id = 2);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select id from flow.company_feature where feature_name = 'HOA'), 3, 2453836, 2453836 where not exists(
        select id from flow.feature_access_control where feature_id = (select id from flow.company_feature where feature_name = 'HOA') and access_control_id = 3);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select(select id from flow.company_feature where feature_name = 'HOA'), 4, 2453836, 2453836 where not exists(
        select id from flow.feature_access_control where feature_id = (select id from flow.company_feature where feature_name = 'HOA') and access_control_id = 4);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select id from flow.company_feature where feature_name = 'Utility'), 1, 2453836, 2453836 where not exists(
    select id from flow.feature_access_control where feature_id = (select id from flow.company_feature where feature_name = 'Utility') and access_control_id = 1
    );
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select id from flow.company_feature where feature_name = 'Utility'), 2, 2453836, 2453836 where not exists(
    select id from flow.feature_access_control where feature_id = (select id from flow.company_feature where feature_name = 'Utility') and access_control_id = 2
    );
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select id from flow.company_feature where feature_name = 'Utility'), 3, 2453836, 2453836 where not exists(
        select id from flow.feature_access_control where feature_id = (select id from flow.company_feature where feature_name = 'Utility') and access_control_id = 3
    );
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select id from flow.company_feature where feature_name = 'Utility'), 4, 2453836, 2453836 where not exists(
        select id from flow.feature_access_control where feature_id = (select id from flow.company_feature where feature_name = 'Utility') and access_control_id = 4
    );

insert into flow.user_feature_access_control(user_id, company_feature_id, access_control_id, enabled) select user_id, (select id from flow.company_feature where feature_name = 'Utility'),
                                                                                                             access_control_id, enabled from flow.user_feature_access_control where company_feature_id = (select id from flow.company_feature where feature_name = 'AHJ');

insert into flow.user_feature_access_control(user_id, company_feature_id, access_control_id, enabled) select user_id, (select id from flow.company_feature where feature_name = 'HOA'),
                                                                                                             access_control_id, enabled from flow.user_feature_access_control where company_feature_id = (select id from flow.company_feature where feature_name = 'AHJ');
