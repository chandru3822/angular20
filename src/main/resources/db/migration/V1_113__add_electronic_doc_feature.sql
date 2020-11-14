insert into flow.feature(feature_name, feature_code, feature_path)
select 'Electronic Documents', 'ELECTRONIC_DOCUMENTS', '/electronicDocuments/request'
where not exists (select id from flow.feature where feature_code = 'ELECTRONIC_DOCUMENTS');

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Electronic Documents', 3, (select id from flow.feature where feature_code = 'ELECTRONIC_DOCUMENTS')
where not exists (select id from flow.company_feature where feature_name = 'Electronic Documents');
