insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
select 22, 6, 2417170
where not exists (
  select id from flow.feature_access_control
  where feature_id = 22 and access_control_id = 6
  );

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
select 22, 7, 2417170
where not exists (
  select id from flow.feature_access_control
  where feature_id = 22 and access_control_id = 7
  );
