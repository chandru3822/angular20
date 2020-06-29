CREATE TABLE if not exists flow.unique_behavior_type
(
    id                       serial  NOT NULL,
    unique_behavior_type varchar(100),
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_state_pk PRIMARY KEY (id),
    CONSTRAINT flow_s_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_s_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION

);

alter table flow.process_step
    add column if not exists unique_behavior_type_id int references flow.unique_behavior_type(id);
;


