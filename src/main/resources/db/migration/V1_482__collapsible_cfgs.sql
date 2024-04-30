alter table if exists flow.custom_field_group
add if not exists company_process_step_status_type_ids bigint[] default null,
add if not exists process_step_status_type_ids bigint[] default null,
add if not exists company_event_status_type_ids bigint[] default null,
add if not exists event_status_type_ids bigint[] default null,
add if not exists ps_collapse_by_default boolean default false,
add if not exists event_collapse_by_default boolean default false;

alter table if exists flow.event
add if not exists company_event_status_type_ids bigint[] default null,
add if not exists event_status_type_ids bigint[] default null,
add if not exists collapse_by_default boolean default false;