-- adding the company feature and access levels
insert into flow.feature(feature_name, feature_code)
	(select 'Bill of Materials', 'BILL_OF_MATERIALS'  where not exists(select id from flow.feature where feature_code = 'BILL_OF_MATERIALS'));

INSERT INTO flow.company_feature (feature_name, company_id, feature_id)
values ('Bill of Materials', 3, (select id from flow.feature where feature_code = 'BILL_OF_MATERIALS'))
	ON CONFLICT DO NOTHING;

INSERT INTO flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
VALUES
	((select id from flow.feature where feature_code = 'BILL_OF_MATERIALS'), (select id from flow.access_control where access_code = 'VIEW'), 99999999, 99999999),
	((select id from flow.feature where feature_code = 'BILL_OF_MATERIALS'), (select id from flow.access_control where access_code = 'EDIT'), 99999999, 99999999)
	ON CONFLICT DO NOTHING;
