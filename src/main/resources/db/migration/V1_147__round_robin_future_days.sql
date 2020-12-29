alter table flow.postal_code_zone
    add column if not exists schedulable_future_days int;
