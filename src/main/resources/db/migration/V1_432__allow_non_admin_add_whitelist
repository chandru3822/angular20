-- add a whitelist to the "Allow Non-Admin to Add to Project" setting

insert into flow.white_list_type (white_list_type)
select 'PROCESS_STEP_ADD_TO_PROJECT' WHERE not exists (select id from flow.white_list_type where white_list_type.white_list_type = 'PROCESS_STEP_ADD_TO_PROJECT');  
  
alter table flow.process_step  
add column if not exists non_admin_add_allow boolean not null default true;
