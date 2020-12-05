alter table flow.process_step_process
add column if not exists company_process_id int references flow.company_process(id);

update flow.process_step_process psp
set company_process_id = ( select cp.id
                            from flow.company_process cp
                            inner join flow.process p on p.id = cp.process_id
                            where cp.process_id = psp.process_id)
where id > 0;

alter table flow.process_step_process
drop column if exists process_id;
