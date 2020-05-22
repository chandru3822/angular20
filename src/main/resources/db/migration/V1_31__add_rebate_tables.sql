CREATE TABLE if NOT EXISTS brs.project_rebate_batch
(
    id                      serial not null
        constraint project_rebate_batch_pkey
            primary key,
    project_rebate_payment_ids integer[],
    batch_date              timestamp default timezone('US/Mountain'::text, now()),
    updated_date            timestamp,
    voided_batch            boolean   default false,
    updated_by_user_id      integer
        constraint project_rebate_batch_updated_by_user_id_fkey
            references flow."user"
);

CREATE TABLE if NOT EXISTS brs.project_rebate_payment_state
(
    id   serial      not null
        constraint project_rebate_payment_state_pkey
            primary key,
    name varchar(50) not null
);


CREATE TABLE if NOT EXISTS brs.project_rebate_payment
(
    id                   serial         not null
        constraint project_rebate_payment_pkey
            primary key,
    project_id              integer        not null
        constraint fk_project_rebate_payment_project_id
            references flow.project,
    payment_amount       numeric(12, 2) not null,
    created_by_user_id   integer        not null
        constraint fk_project_rebate_payment_created_by_user_id
            references flow."user",
    created_date         date           not null,
    approved_by_user_id  integer
        constraint fk_project_rebate_payment_approved_by_user_id
            references flow."user",
    approved_date        date,
    updated_by_user_id   integer,
    updated_date         date,
    project_rebate_payment_state_id             integer        not null
        constraint fk_project_rebate_payment_state_id
            references brs.project_rebate_payment_state,
    processed_date       date,
    processed_by_user_id integer
        constraint fk_project_rebate_payment_processed_by_user_id
            references flow."user",
    payment_nbr          integer,
    project_rebate_batch_id integer
        constraint fk_project_rebate_batch_id
            references brs.project_rebate_batch,
    check_number         integer,
    void_note            text
);

CREATE INDEX if not exists fki_project_rebate_payment_approved_by_user_id
    on brs.project_rebate_payment (approved_by_user_id);

CREATE INDEX if not exists fki_project_rebate_payment_created_by_user_id
    on brs.project_rebate_payment (created_by_user_id);

CREATE INDEX if not exists fki_project_rebate_payment_project_id
    on brs.project_rebate_payment (project_id);

CREATE INDEX if not exists fki_project_rebate_payment_state_id
    on brs.project_rebate_payment (state_id);

CREATE TABLE if NOT EXISTS brs.project_rebate_payment_audit
(
    id                 serial    not null
        constraint project_rebate_payment_audit_pkey
            primary key,
    project_id            integer   not null
        constraint fk_project_rebate_payment_audit_project_id
            references flow.project,
    audit              text,
    changed_date       timestamp not null,
    changed_by_user_id integer   not null
        constraint fk_project_rebate_payment_audit_user_id
            references flow."user"
);

CREATE INDEX if not exists fki_project_rebate_payment_audit_project_id
    on brs.project_rebate_payment_audit (project_id);

CREATE INDEX if not exists fki_project_rebate_payment_audit_user_id
    on brs.project_rebate_payment_audit (changed_by_user_id);

CREATE INDEX if not exists idx_project_rebate_payment_audit_created_date
    on brs.project_rebate_payment_audit (changed_date);
