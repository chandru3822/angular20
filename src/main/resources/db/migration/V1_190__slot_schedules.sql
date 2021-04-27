CREATE TABLE if not exists flow.resource_slot_schedule
(
    id                       serial  NOT NULL,
    company_id       integer NOT NULL,
    schedule_name    varchar(255),
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_resource_slot_schedule_pk PRIMARY KEY (id),
    CONSTRAINT flow_rss_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_rss_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_rss_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
CREATE TABLE if not exists flow.resource_slot_time
(
    id                       serial  NOT NULL,
    resource_slot_schedule_id       integer NOT NULL,
    start_time time not null,
    end_time time not null,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_resource_slot_time_pk PRIMARY KEY (id),
    CONSTRAINT flow_rst_resource_slot_schedule_id_fk FOREIGN KEY (resource_slot_schedule_id)
        REFERENCES flow.resource_slot_schedule (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_rst_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_rst_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

alter table flow.resource_schedule_availability
    add column if not exists resource_slot_schedule_id int references flow.resource_slot_schedule(id);

alter table flow.resource_schedule_availability alter column start_time drop not null;
alter table flow.resource_schedule_availability alter column end_time drop not null;

alter table flow.position
add column if not exists use_slot_schedule boolean not null default false;
;

