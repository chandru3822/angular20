insert into flow.feature(feature_name, feature_code, feature_path)
select 'Installer Dashboard', 'INSTALLER_DASHBOARD', '/installerDashboard'
    where not exists (select id from flow.feature where feature_code = 'INSTALLER_DASHBOARD');

insert into flow.company_feature(feature_name, company_id, feature_id, home_page)
select 'Installer Dashboard', 3, (select id from flow.feature where feature_code = 'INSTALLER_DASHBOARD'), true
    where not exists (select id from flow.company_feature where feature_name = 'Installer Dashboard' and company_id = 3);
