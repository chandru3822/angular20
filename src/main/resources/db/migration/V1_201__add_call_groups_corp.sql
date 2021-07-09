CREATE TABLE if not exists brs.call_group_phone_number
(
    id              serial  NOT NULL,
    call_group_id integer not null,
    call_count integer not null default 0,
    phone_number         varchar(50) not null,
    archived           boolean not null default false,
    active           boolean not null default true,
    last_used           boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT cgpn_pk PRIMARY KEY (id),
    CONSTRAINT cgpn_id_fk FOREIGN KEY (call_group_id)
    REFERENCES brs.call_group (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cgpn_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cgpn_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
    );

insert into brs.call_group_phone_number(call_group_id, phone_number, created_by_id, date_created)
    (select id, phone_number, created_by_id, date_created from brs.call_group)

alter table brs.call_group drop column if exists phone_number;
alter table brs.call_group add column if not exists active boolean default true;
alter table brs.call_group add column if not exists max_call_count integer default 0;
alter table brs.call_group add column if not exists days_per_period integer default 0;

