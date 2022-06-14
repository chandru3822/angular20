-- remove all user's contact - delete unless they also have admin
update flow.user_feature_access_control ufac
set enabled = false
where company_feature_id = 2
  and access_control_id = 4
and not exists (
  select id
  from flow.user_feature_access_control ufac2
  where ufac2.company_feature_id = 2
  and ufac2.access_control_id = 5
  and ufac.user_id = ufac2.user_id
  and ufac2.enabled is true
  );

-- remove all position's contact - delete unless they also have admin
update flow.position_feature_access_control ufac
set enabled = false
where company_feature_id = 2
  and access_control_id = 4
  and not exists (
  select id
  from flow.position_feature_access_control ufac2
  where ufac2.company_feature_id = 2
    and ufac2.access_control_id = 5
    and ufac.position_id = ufac2.position_id
    and ufac2.enabled is true
  );

-- remove all user's contact admin permissions
update flow.user_feature_access_control
set enabled = false
where company_feature_id = 2
and access_control_id = 5;


-- remove all positions's contact admin permissions
update flow.position_feature_access_control
set enabled = false
where company_feature_id = 2
  and access_control_id = 5;

-- remove the contact - admin permission completely it doesn't do anything anymore
update flow.feature_access_control
set archived = true
where feature_id = 2
  and access_control_id = 5;
