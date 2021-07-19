CREATE TABLE if not exists brs.call_group_phone_log
(
    id                   serial  NOT NULL,
    call_group_id        integer not null,
    phone_number         varchar(50) not null,
    date_created         timestamp without time zone default now(),
    created_by_id        integer,
    CONSTRAINT cgpl_pk PRIMARY KEY (id),
    CONSTRAINT cgpl_id_fk FOREIGN KEY (call_group_id)
    REFERENCES brs.call_group (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cgpl_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
    );

