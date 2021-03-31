-- for when flyway fails because randa forgets to rename a column back for the one millionth time:
-- alter table flow.process_step_action
-- rename column hide_from_mobile to hidden;

alter table flow.process_step_action
rename column hidden to hide_from_mobile;

alter table flow.process_step_action
    add column if not exists hide_from_web boolean not null default false;

update flow.process_step_action
set hide_from_web = true
where hide_from_mobile is true;
