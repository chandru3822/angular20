create table if not exists flow.project_process_step_action
(
    id serial not null
        constraint project_process_step_action_pk
            primary key,
    project_process_step_id integer not null,
    process_step_action_id integer not null
        constraint ppsa_process_step_action_id_fk
            references flow.process_step_action,
    triggered_automatically boolean default false not null,
    date_created timestamp default now() not null,
    created_by_id integer not null
        constraint ppsa_created_by_id_fk
            references flow."user"
);

create index if not exists ppsa_project_process_step_id_idx on flow.project_process_step_action (project_process_step_id);

create unique index if not exists project_process_step_action_id_uindex on flow.project_process_step_action (id);

