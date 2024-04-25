insert into flow.feature(feature_name, feature_code, feature_path)
select 'Road Map', 'ROAD_MAP', '/roadmap'
  where not exists (select id from flow.feature where feature_code = 'ROAD_MAP');

insert into flow.company_feature(feature_name, company_id, feature_id, home_page, show_in_tools)
select 'Road Map', 3, (select id from flow.feature where feature_code = 'ROAD_MAP'), true, true
  where not exists (select id from flow.company_feature where feature_name = 'Road Map' and company_id = 3);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
  (select (select id from flow.feature where feature_code = 'ROAD_MAP'), ac.id, 99999999
   from flow.access_control ac
   where not exists (
     select fac.id
     from flow.feature_access_control fac
     where feature_id = (select id from flow.feature where feature_code = 'ROAD_MAP')
       and access_control_id = ac.id
   )
     and ac.id = 1
  );
