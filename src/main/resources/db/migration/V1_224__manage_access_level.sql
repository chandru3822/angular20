insert into flow.access_control(access_level, access_code, display_order)
select 'manage', 'MANAGE', 6
where not exists (select id from flow.access_control where access_code = 'MANAGE');

update flow.access_control
set display_order = 7
where access_code = 'ADMIN';


insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
select (select id from flow.feature where feature_code = 'PROCESS_STEPS'), (select id from flow.access_control where access_code = 'MANAGE'), 2417170
where not exists(
    select fac.id
    from flow.feature_access_control fac
           inner join flow.feature f on fac.feature_id = f.id
           inner join flow.access_control ac on fac.access_control_id = ac.id
    where feature_code = 'PROCESS_STEPS'
      and access_code = 'MANAGE'
  );
