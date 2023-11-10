alter table flow.round_robin
    add column if not exists uses_total_lead_allocation boolean not null default false;
