alter table flow.resource_appointment
    ADD column if not exists recurring_event_id VARCHAR(255) NULL;

alter table flow.resource_appointment
    ADD column if not exists recurring_event_end_type VARCHAR(10);

alter table flow.company
    add column if not exists archived boolean default false not null;

drop function if exists flow.company_hierarchy_filter_down(int);
