alter table flow.company_feature
add column if not exists hidden boolean not null default false;

insert into flow.feature (feature_name, feature_code, feature_path)
select 'Masquerade', 'MASQUERADE', null
where not exists ( select id
                   from flow.feature where feature_code = 'MASQUERADE' );

insert into flow.company_feature (feature_name, company_id, feature_id, home_page, hidden)
select 'Masquerade', 3,
       (select id from flow.feature where feature_code = 'MASQUERADE' and archived is false),
       false, true
where not exists ( select id
                   from flow.company_feature where feature_name = 'Masquerade' )
