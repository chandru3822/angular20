insert into flow.feature(feature_name, feature_code, feature_path)
select 'Aurora AI', 'AURORA_AI', null
where not exists (select id from flow.feature where feature_code = 'AURORA_AI');

insert into flow.company_feature(feature_name, company_id, feature_id, home_page, show_in_tools)
select 'Aurora AI', 3, (select id from flow.feature where feature_code = 'AURORA_AI'), false, false
where not exists (select id from flow.company_feature where feature_name = 'Aurora AI' and company_id = 3);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
    (select (select id from flow.feature where feature_code = 'AURORA_AI'), ac.id, 99999999
     from flow.access_control ac
     where not exists (
         select fac.id
         from flow.feature_access_control fac
         where feature_id = (select id from flow.feature where feature_code = 'AURORA_AI')
           and access_control_id = ac.id
     )
       and ac.id = 3
    );
