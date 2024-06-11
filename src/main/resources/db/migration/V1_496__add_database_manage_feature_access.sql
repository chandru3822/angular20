

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select feature_id from flow.company_feature where feature_name = 'AHJ'), 8, 99999999, 99999999 where not exists(
  select id from flow.feature_access_control where feature_id = (select feature_id from flow.company_feature where feature_name = 'AHJ') and access_control_id = 8
);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select feature_id from flow.company_feature where feature_name = 'HOA'), 8, 99999999, 99999999 where not exists(
  select id from flow.feature_access_control where feature_id = (select feature_id from flow.company_feature where feature_name = 'HOA') and access_control_id = 8
);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select feature_id from flow.company_feature where feature_name = 'Suppliers'), 8, 99999999, 99999999 where not exists(
  select id from flow.feature_access_control where feature_id = (select feature_id from flow.company_feature where feature_name = 'Suppliers') and access_control_id = 8
);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select feature_id from flow.company_feature where feature_name = 'Incentive'), 8, 99999999, 99999999 where not exists(
  select id from flow.feature_access_control where feature_id = (select feature_id from flow.company_feature where feature_name = 'Incentive') and access_control_id = 8
);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select (select feature_id from flow.company_feature where feature_name = 'Utility'), 8, 99999999, 99999999 where not exists(
  select id from flow.feature_access_control where feature_id = (select feature_id from flow.company_feature where feature_name = 'Utility') and access_control_id = 8
);
