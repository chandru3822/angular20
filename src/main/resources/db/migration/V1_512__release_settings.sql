create table if not exists brs.release(
                                        id bigserial,
                                        release_name varchar(250),
                                        stage_lock_date date,
                                        uat_lock_date date,
                                        release_date date,
                                        archived boolean,
                                        date_created timestamp,
                                        date_modified timestamp,
                                        created_by_id bigint,
                                        modified_by_id bigint,
                                        UNIQUE (release_name)
);

create index if not exists release_name_idx
  on brs.release (release_name);

insert into flow.feature(feature_name, feature_code, archived, is_system, feature_path)
select 'Releases', 'RELEASES', false, false, null
where not exists ( select f.id from flow.feature f where f.feature_name = 'Releases');

insert into flow.company_feature(feature_name, company_id, feature_id, parent_company_feature_id)
select 'Releases', 3, (select f.id from flow.feature f where f.feature_code = 'RELEASES'), null
where not exists ( select cf.id from flow.company_feature cf where cf.feature_name = 'Releases');

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select ( select f.id from flow.feature f where f.feature_code = 'RELEASES'), 1, 2455325, 2455325
where not exists ( select fac.id from flow.feature_access_control fac where fac.feature_id = ( select f.id from flow.feature f where f.feature_code = 'RELEASES') and access_control_id = 1);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select ( select f.id from flow.feature f where f.feature_code = 'RELEASES'), 2, 2455325, 2455325
where not exists ( select fac.id from flow.feature_access_control fac where fac.feature_id = ( select f.id from flow.feature f where f.feature_code = 'RELEASES') and access_control_id = 2);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select ( select f.id from flow.feature f where f.feature_code = 'RELEASES'), 3, 2455325, 2455325
where not exists ( select fac.id from flow.feature_access_control fac where fac.feature_id = ( select f.id from flow.feature f where f.feature_code = 'RELEASES') and access_control_id = 3);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select ( select f.id from flow.feature f where f.feature_code = 'RELEASES'), 4, 2455325, 2455325
where not exists ( select fac.id from flow.feature_access_control fac where fac.feature_id = ( select f.id from flow.feature f where f.feature_code = 'RELEASES') and access_control_id = 4);
