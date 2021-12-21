--add the app downloads feature
insert into flow.feature(feature_name, feature_code, feature_path)
select 'App Downloads','APP_DOWNLOADS', null
where not exists (select id from flow.feature where feature_code = 'APP_DOWNLOADS');

--add the app downloads feature to company_id = 3
insert into flow.company_feature(feature_name, company_id, feature_id, home_page)
select 'App Downloads', 3, (select id from flow.feature where feature_code = 'APP_DOWNLOADS'), false
where not exists (select id from flow.company_feature where feature_name = 'App Downloads' and company_id = 3);

--add the access levels for the feature
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
select (select id from flow.feature where feature_code = 'APP_DOWNLOADS'), ac.id, 2417170
from flow.access_control ac
where ac.id in (1,6,2,3,4)
and not exists (
  select id from flow.feature_access_control
  where feature_id = (select id from flow.feature where feature_code = 'APP_DOWNLOADS')
  and access_control_id = ac.id
  );

--add the view access level for app downloads to all positions
insert into flow.position_feature_access_control(company_feature_id, access_control_id, position_id, enabled)
select (select id from flow.company_feature where feature_name = 'App Downloads' and company_id = 3 ), 1, p.id, true
from flow.position p
where p.company_id = 3
and p.archived is false
and not exists (
  select id from flow.position_feature_access_control
  where position_id = p.id
    and access_control_id = 1
  and company_feature_id = (select id from flow.company_feature where feature_name = 'App Downloads' and company_id = 3)
  )
;

--add the remaining access levels to judson and holly
--holly
insert into flow.user_feature_access_control(user_id, company_feature_id, access_control_id, enabled)
select 2422383, (select id from flow.company_feature where feature_name = 'App Downloads' and company_id = 3),
       ac.id, true
from flow.access_control ac
where id in (1,6,2,3,4)
and not exists (
  select id from flow.user_feature_access_control
  where user_id = 2422383
    and company_feature_id = (select id from flow.company_feature where feature_name = 'App Downloads' and company_id = 3)
  and access_control_id = ac.id
  );
--judson
insert into flow.user_feature_access_control(user_id, company_feature_id, access_control_id, enabled)
select 2350555, (select id from flow.company_feature where feature_name = 'App Downloads' and company_id = 3),
       ac.id, true
from flow.access_control ac
where id in (1,6,2,3,4)
  and not exists (
    select id from flow.user_feature_access_control
    where user_id = 2350555
      and company_feature_id = (select id from flow.company_feature where feature_name = 'App Downloads' and company_id = 3)
      and access_control_id = ac.id
  );
