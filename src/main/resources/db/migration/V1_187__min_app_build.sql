alter table flow.app_type
add column if not exists minimum_required_build_number int;

update flow.app_type
  set minimum_required_build_number = 1159
where id = 1;

update flow.app_type
  set minimum_required_build_number = 1160
where id = 3;
