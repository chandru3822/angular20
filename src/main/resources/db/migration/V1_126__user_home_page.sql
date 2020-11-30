alter table flow.user_company
add column if not exists home_page_company_feature_id int references flow.company_feature(id);

alter table flow.company_feature
    add column if not exists home_page boolean;

update flow.feature set feature_path = '/workQueue' where id = 7;
update flow.feature set feature_path = '/users' where id = 8;
update flow.feature set feature_path = '/orgs' where id = 9;
update flow.feature set feature_path = '/projects' where id = 11;
update flow.feature set feature_path = '/contacts' where id = 2;
update flow.feature set feature_path = '/schedule' where id = 4;

update flow.company_feature cf
set home_page = true
from flow.feature f
where f.id = cf.feature_id
and f.feature_path is not null;
