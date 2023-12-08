alter table flow.postal_code
    add column if not exists created_by_id bigint references flow."user"(id);

alter table flow.postal_code
    add column if not exists date_created timestamp without time zone not null default now();

CREATE INDEX if not exists pc_created_by_id_idx ON flow.postal_code (created_by_id);

update flow.postal_code
    set created_by_id = 2417170;

alter table flow.postal_code alter column created_by_id set not null;

drop table if exists flow.postal_code_audit;
create table if not exists flow.postal_code_audit
(
    id                  bigserial
        constraint postal_code_audit_pk primary key,
    postal_code_id         bigint,
    postal_code         varchar,
    place_name          varchar,
    postal_code_zone_id bigint,
    state_id            bigint,
    round_robin_id      bigint,
    call_group_id       bigint,
    active              boolean,
    disqualified        boolean,
    self_gen            boolean,
    inside_sales        boolean,
    sales_partners      boolean,
    archived            boolean,
    notes               text,
    created_by_id       bigint,
    modified_by_id      bigint,
    date_created        timestamp,
    date_modified       timestamp
);

drop table if exists flow.postal_code_zone_audit;
create table if not exists flow.postal_code_zone_audit
(
    id             bigserial
        constraint postal_code_zone_audit_pk primary key,
    postal_code_zone_id         bigint,
    zone_name      varchar,
    metro_area_id  bigint,
    adder_amount   numeric,
    archived       boolean,
    created_by_id  bigint,
    modified_by_id bigint,
    date_created   timestamp,
    date_modified  timestamp
);