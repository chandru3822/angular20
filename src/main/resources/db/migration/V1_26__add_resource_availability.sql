CREATE TABLE if not exists flow.day_of_week
(
    id                       serial  NOT NULL,
    day_of_week       varchar(10) NOT NULL,
    abbreviation    varchar(5) NOT NULL,
    CONSTRAINT flow_day_of_week_pk PRIMARY KEY (id)
);

insert into flow.day_of_week(day_of_week, abbreviation)
values ('Sunday', 'Sun'),
       ('Monday', 'Mon'),
       ('Tuesday', 'Tue'),
       ('Wednesday', 'Wed'),
       ('Thursday', 'Thu'),
       ('Friday', 'Fri'),
       ('Saturday', 'Sat');

CREATE TABLE if not exists flow.company_week_start
(
    id                       serial  NOT NULL,
    company_id        integer NOT NULL,
    day_of_week_id    integer NOT NULL,
    CONSTRAINT flow_company_week_start_pk PRIMARY KEY (id),
    CONSTRAINT flow_cws_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_cws_day_of_week_id_fk FOREIGN KEY (day_of_week_id)
        REFERENCES flow.day_of_week (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
);

insert into flow.company_week_start(company_id, day_of_week_id)
values (3, 2);

CREATE TABLE if not exists flow.resource_schedule
(
    id                       serial  NOT NULL,
    company_id       integer NOT NULL,
    user_id        integer,
    org_id         integer,
    start_date   date not null,
    end_date   date,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_resource_schedule_pk PRIMARY KEY (id),
    CONSTRAINT flow_rs_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_rs_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_rs_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists flow.resource_schedule_availability
(
    id                       serial  NOT NULL,
    resource_schedule_id       integer NOT NULL,
    start_time   time not null,
    end_time   time not null,
    day_of_week_id  integer not null,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_resource_schedule_availability_pk PRIMARY KEY (id),
    CONSTRAINT flow_rsa_resource_schedule_id_fk FOREIGN KEY (resource_schedule_id)
        REFERENCES flow.resource_schedule (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_rsa_day_of_week_id_fk FOREIGN KEY (day_of_week_id)
        REFERENCES flow.day_of_week (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_rsa_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_rsa_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
