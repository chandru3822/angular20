create table if not exists flow.smartlist
(
    id                     serial                  not null
        constraint smartlist_pk
            primary key,
    name                   varchar,
    company_object_type_id integer
        constraint smartlist_company_object_type_id_fk
            references flow.company_object_type,
    shared                 boolean   default false not null,
    owner_id               integer                 not null
        constraint smartlist_owner_id_fk
            references flow.user,
    date_created           timestamp default now(),
    date_modified          timestamp,
    created_by_id          integer
        constraint smartlist_created_by_id_fk
            references flow.user,
    modified_by_id         integer
        constraint smartlist_modified_by_id_fk
            references flow.user,
    archived               boolean   default false not null
);


create table if not exists flow.smartlist_field
(
    id                     serial                  not null
        constraint smartlist_field_pk
            primary key,
    company_object_type_id integer                 not null
        constraint sf_company_object_type_id_fk
            references flow.company_object_type,
    name                   varchar                 not null,
    reference_table        varchar                 not null,
    reference_column       varchar                 not null,
    date_created           timestamp default now(),
    date_modified          timestamp,
    created_by_id          integer                 not null
        constraint sf_created_by_id_fk
            references flow.user,
    modified_by_id         integer
        constraint sf_modified_by_id_fk
            references flow.user,
    archived               boolean   default false not null,
    company_data_type_id   integer                 not null
        constraint sf_company_data_type_id_fk
            references flow.company_data_type
);


create table if not exists flow.smartlist_field_assignment
(
    id                               serial                  not null
        constraint smartlist_field_assignment_pk
            primary key,
    smartlist_id                     integer                 not null
        constraint sfa_smartlist_id_fk
            references flow.smartlist,
    smartlist_field_id               integer
        constraint sfa_smartlist_field_id_fk
            references flow.smartlist_field,
    custom_field_group_assignment_id integer
        constraint sfa_custom_field_group_assignment_id_fk
            references flow.custom_field_group_assignment,
    date_created                     timestamp default now(),
    date_modified                    timestamp,
    created_by_id                    integer                 not null
        constraint sfa_created_by_id_fk
            references flow.user,
    modified_by_id                   integer
        constraint sfa_modified_by_id_fk
            references flow.user,
    archived                         boolean   default false not null,
    display_order                    integer                 not null,
    process_step_id                  integer
        constraint sfa_process_step_id_fk
            references flow.process_step
);


create table if not exists flow.smartlist_logic
(
    id                       serial                  not null
        constraint smartlist_logic_pk
            primary key,
    smartlist_id             integer                 not null
        constraint sl_smartlist_id_fk
            references flow.smartlist,
    smartlist_requirement_id integer
        constraint sl_smartlist_requirement_id_fk
            references flow.smartlist_requirement,
    operation_type_id        integer
        constraint sl_operation_type_id_fk
            references flow.operation_type,
    sql_order                integer                 not null,
    created_by_id            integer                 not null
        constraint sl_created_by_id_fk
            references flow.user,
    date_created             timestamp default now() not null,
    modified_by_id           integer
        constraint sl_modified_by_id_fk
            references flow.user,
    date_modified            timestamp,
    archived                 boolean   default false not null
);


create unique index if not exists smartlist_logic_id_uindex on flow.smartlist_logic (id);

create table if not exists flow.smartlist_requirement
(
    id                               serial                  not null
        constraint smartlist_requirement_pk
            primary key,
    smartlist_id                     integer                 not null
        constraint sr_smartlist_id_fk
            references flow.smartlist,
    process_step_id                  integer
        constraint sr_process_step_id_fk
            references flow.process_step,
    custom_field_group_assignment_id integer
        constraint sr_custom_field_group_assignment_fk
            references flow.custom_field_group_assignment,
    operator_type_id                 integer                 not null
        constraint sr_operator_type_id_fk
            references flow.operator_type,
    requirement_value                varchar,
    secondary_requirement_value      varchar,
    data_type_requirement_id         integer
        constraint sr_data_type_requirement_id_fk
            references flow.data_type_requirement,
    display_order                    integer                 not null,
    immutable                        boolean   default false not null,
    created_by_id                    integer                 not null
        constraint sr_created_by_id_fk
            references flow.user,
    date_created                     timestamp default now() not null,
    modified_by_id                   integer
        constraint sr_modified_by_id_fk
            references flow.user,
    date_modified                    timestamp,
    archived                         boolean   default false not null,
    smartlist_field_id               integer
        constraint sr_smartlist_field_id_fk
            references flow.smartlist_field
);

create unique index if not exists smartlist_requirement_id_uindex on flow.smartlist_requirement (id);
