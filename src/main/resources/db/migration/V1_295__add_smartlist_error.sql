create table if not exists flow.smartlist_error (
    id                     bigserial,
    smartlist_id           bigint not null
      constraint se_smartlist_id_fk references flow.smartlist,
    smartlist              jsonb,
    smartlist_fields       jsonb,
    smartlist_requirements jsonb,
    stacktrace             text,
    date_created           timestamp default now(),
    created_by             bigint not null
    constraint se_created_by_fk references flow."user"
);

create index if not exists se_smartlist_id_idx on flow.smartlist_error (smartlist_id);