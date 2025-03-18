-- adding the company feature and access levels
insert into flow.feature(feature_name, feature_code)
	(select 'Bill of Materials', 'BILL_OF_MATERIALS'  where not exists(select id from flow.feature where feature_code = 'BILL_OF_MATERIALS'));

INSERT INTO flow.company_feature (feature_name, company_id, feature_id)
	SELECT 'Bill of Materials', 3, (select id from flow.feature where feature_code = 'BILL_OF_MATERIALS')
	WHERE NOT EXISTS (
	select id from flow.company_feature where feature_name = 'Bill of Materials'
	);

INSERT INTO flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
SELECT
	f.id,
	ac.id,
	99999999,
	99999999
FROM
	(SELECT id FROM flow.feature WHERE feature_code = 'BILL_OF_MATERIALS') f,
	(SELECT id FROM flow.access_control WHERE access_code IN ('VIEW', 'EDIT')) ac
WHERE NOT EXISTS (
	SELECT fac.id
	FROM flow.feature_access_control fac
	WHERE fac.feature_id = f.id
	  AND fac.access_control_id = ac.id
);
