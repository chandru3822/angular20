CREATE TABLE if not exists flow.error_log_status
(
    id                       serial  NOT NULL,
    status  text not null,
    archived       boolean not null default false,
    CONSTRAINT flow_error_log_status_pk PRIMARY KEY (id)
);
-- not sure what types we might have but we can always take them out
insert into flow.error_log_status (status)
select 'Active' where not exists (select id from flow.error_log_status where status = 'Active');
insert into flow.error_log_status (status)
select 'Resolved' where not exists (select id from flow.error_log_status where status = 'Resolved');
insert into flow.error_log_status (status)
select 'Ignore' where not exists (select id from flow.error_log_status where status = 'Ignore');

CREATE TABLE if not exists flow.company_error_log
(
    id                       serial  NOT NULL,
    company_feature_id       integer NOT NULL,
    error_message  text not null,
    error_log_status_id integer not null,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_company_error_log_pk PRIMARY KEY (id),
    CONSTRAINT flow_cel_company_feature_id_fk FOREIGN KEY (company_feature_id)
        REFERENCES flow.company_feature (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_cel_error_log_status_id_fk FOREIGN KEY (error_log_status_id)
        REFERENCES flow.error_log_status (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_cel_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_cel_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
