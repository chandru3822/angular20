insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Electronic Documents', 2, (select id from flow.feature where feature_code = 'ELECTRONIC_DOCUMENTS')
where not exists (select id from flow.company_feature where feature_name = 'Electronic Documents' and company_id = 2);
