DROP TABLE if exists flow.cert;
CREATE TABLE if not exists flow.cert
(
    id              bigserial NOT NULL,
    cert_name       varchar(255),
    expiration_date date,
    notes           text,
    thirty_day_notice_sent           boolean not null default false,
    date_created    timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone DEFAULT now(),
    created_by_id   integer   not null,
    modified_by_id  integer,
    archived        boolean   not null          default false,
    CONSTRAINT flow_cert_pk PRIMARY KEY (id),
    CONSTRAINT flow_c_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_c_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists flow.cert_admin_email
(
    id              bigserial NOT NULL,
    first_name      varchar(255),
    last_name       varchar(255),
    email           varchar(255),
    archived        boolean   not null          default false,
    CONSTRAINT flow_cert_admin_email_pk PRIMARY KEY (id)
);

insert into flow.cert_admin_email(first_name, last_name, email)
select 'Randa', 'Nunn', 'randa@7oaksgroup.com'
where not exists (select id from flow.cert_admin_email where email = 'randa@7oaksgroup.com');

insert into flow.cert_admin_email(first_name, last_name, email)
select 'Kaleb', 'Scholes', 'kaleb@7oaksgroup.com'
where not exists (select id from flow.cert_admin_email where email = 'kaleb@7oaksgroup.com');

insert into flow.cert_admin_email(first_name, last_name, email)
select 'Scott', 'Humes', 'scott.humes@7oaksgroup.com'
where not exists (select id from flow.cert_admin_email where email = 'scott.humes@7oaksgroup.com');


