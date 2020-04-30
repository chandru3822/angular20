CREATE TABLE if not exists brs.residual_ledger
(
    id              serial  NOT NULL,
    user_project_id integer not null,
    paid            numeric(10, 2),
    residual_date   date    not null,
    paid_date       date,
    CONSTRAINT residual_ledger_pk PRIMARY KEY (id),
    CONSTRAINT residual_ledger_user_project_id_fk FOREIGN KEY (user_project_id)
        REFERENCES flow.user_project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

create table if not exists brs.residual_plan_status
(
    id          integer not null
        constraint residual_plan_status_pk
            primary key,
    status_type varchar(20)
);

INSERT INTO brs.residual_plan_status (id, status_type)
(select 1, 'PENDING' where not exists (select id from brs.residual_plan_status where status_type = 'PENDING'));
INSERT INTO brs.residual_plan_status (id, status_type)
 (select 2, 'ACTIVE' where not exists (select id from brs.residual_plan_status where status_type = 'ACTIVE'));
INSERT INTO brs.residual_plan_status (id, status_type)
 (select 3, 'INACTIVE' where not exists (select id from brs.residual_plan_status where status_type = 'INACTIVE'));


create table if not exists brs.residual_plan
(
    id                 serial                   not null
        constraint residual_plan_pk
            primary key,
    name               text,
    total              numeric(10, 2) default 0 not null,
    nbr_fdc_lower      integer                  not null,
    nbr_fdc_upper      integer                  not null,
    residual_status_id integer        default 1
        constraint residual_plan_residual_plan_status_id_fk
            references brs.residual_plan_status,
    position_id        integer
        constraint residual_plan_position_id_fk
            references flow.position,
    approved           timestamp with time zone,
    created            timestamp with time zone,
    created_by         integer
        constraint residual_plan_created_by_user_id_fk
            references flow."user",
    approved_by        integer
        constraint residual_plan_approved_by_user_id_fk
            references flow."user",
    description        text,
    notes              text
);


create index  if not exists residual_plan_name_trgm_idx
    on brs.residual_plan (name);


create table if not exists brs.residual_plan_user
(
    id               serial  not null
        constraint residual_plan_user_pk
            primary key,
    residual_plan_id integer not null
        constraint residual_plan_user_residual_plan_id_fk
            references brs.residual_plan,
    user_id          integer not null
        constraint residual_plan_user_user_id_fk
            references flow."user",
    start_date       date    not null,
    end_date         date,
    note             text
);

create index  if not exists residual_plan_user_user_id_daterange_excl
    on brs.residual_plan_user (user_id, daterange(start_date, end_date, '[]'::text));

