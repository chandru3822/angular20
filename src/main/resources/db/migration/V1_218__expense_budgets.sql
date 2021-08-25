insert into flow.feature (feature_name, feature_code, feature_path, is_system)
select 'Expenses', 'EXPENSES', null, true
where not exists ( select id
                   from flow.feature where feature_code = 'EXPENSES' );

insert into flow.company_feature (feature_name, company_id, feature_id, home_page, hidden)
select 'Expenses', 3,
       (select id from flow.feature where feature_code = 'EXPENSES' and archived is false),
       false, true
where not exists ( select id
                   from flow.company_feature where feature_name = 'Expenses' );


insert into flow.feature (feature_name, feature_code, feature_path, is_system)
select 'Reimbursement', 'REIMBURSEMENT', null, true
where not exists ( select id
                   from flow.feature where feature_code = 'REIMBURSEMENT' );

insert into flow.company_feature (feature_name, company_id, feature_id, home_page, hidden)
select 'Reimbursement', 3,
       (select id from flow.feature where feature_code = 'REIMBURSEMENT' and archived is false),
       false, true
where not exists ( select id
                   from flow.company_feature where feature_name = 'Reimbursement' );


