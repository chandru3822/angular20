alter table flow.work_queue_category
add column if not exists display_order int;

alter table flow.work_queue_type
    add column if not exists display_order int;
;

alter table flow.process_step_action
    add column if not exists display_order int;
;
