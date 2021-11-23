alter table flow.work_queue_type
    add column if not exists schedule varchar(1000);
