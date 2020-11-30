insert into flow.feature(feature_name, feature_code, feature_path)
select 'Closer Availability', 'CLOSER_AVAILABILITY', '/closerAvailability'
where not exists (select id from flow.feature where feature_code = 'CLOSER_AVAILABILITY');

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Closer Availability', 3, (select id from flow.feature where feature_code = 'CLOSER_AVAILABILITY')
where not exists (select id from flow.company_feature where feature_name = 'Closer Availability');
