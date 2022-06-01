CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE if NOT EXISTS flow.sms_team
(
    id        serial                NOT NULL,
    team_name varchar(255),
    company_id integer not null,
    is_default boolean default false,
    archived boolean default false,
    date_created            timestamp without time zone default now(),
    date_modified           timestamp without time zone default now(),
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT flow_sms_team_pk PRIMARY KEY (id),
    CONSTRAINT st_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
    );

CREATE INDEX if not exists smst_company_id_idx ON flow.sms_team (company_id);

CREATE TABLE if not exists flow.sms_team_user
(
    id                 serial  NOT NULL,
    sms_team_id integer NOT NULL,
    user_id            integer NOT NULL,
    date_created       timestamp without time zone DEFAULT now(),
    date_modified      timestamp without time zone DEFAULT now(),
    created_by_id      integer not null,
    modified_by_id     integer,
    archived           boolean not null            default false,
    CONSTRAINT flow_sms_team_user_pk PRIMARY KEY (id),
    CONSTRAINT flow_stu_sms_team_id_fk FOREIGN KEY (sms_team_id)
    REFERENCES flow.sms_team (id) MATCH SIMPLE
                                 ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_stu_user_id_fk FOREIGN KEY (user_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                 ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_stu_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                 ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_stu_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                 ON UPDATE NO ACTION ON DELETE NO ACTION
    );

CREATE INDEX if not exists stu_sms_team_id_idx ON flow.sms_team_user (sms_team_id);

CREATE INDEX if not exists stu_user_id_idx ON flow.sms_team_user (user_id);

CREATE TABLE if not exists flow.sms_team_position
(
    id                 serial  NOT NULL,
    sms_team_id integer NOT NULL,
    position_id            integer NOT NULL,
    date_created       timestamp without time zone DEFAULT now(),
    date_modified      timestamp without time zone DEFAULT now(),
    created_by_id      integer not null,
    modified_by_id     integer,
    archived           boolean not null            default false,
    CONSTRAINT flow_sms_team_position_pk PRIMARY KEY (id),
    CONSTRAINT flow_stp_sms_team_id_fk FOREIGN KEY (sms_team_id)
    REFERENCES flow.sms_team (id) MATCH SIMPLE
                                 ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_stp_position_id_fk FOREIGN KEY (position_id)
    REFERENCES flow.position (id) MATCH SIMPLE
                                 ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_stp_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                 ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_stp_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                 ON UPDATE NO ACTION ON DELETE NO ACTION
    );

CREATE INDEX if not exists stp_sms_team_id_idx ON flow.sms_team_position (sms_team_id);

CREATE INDEX if not exists stp_position_id_idx ON flow.sms_team_position (position_id);


CREATE TABLE if not exists flow.sms_team_org
(
    id                 serial  NOT NULL,
    sms_team_id integer NOT NULL,
    org_id            integer NOT NULL,
    date_created       timestamp without time zone DEFAULT now(),
    date_modified      timestamp without time zone DEFAULT now(),
    created_by_id      integer not null,
    modified_by_id     integer,
    archived           boolean not null            default false,
    CONSTRAINT flow_sms_team_org_pk PRIMARY KEY (id),
    CONSTRAINT flow_sto_sms_team_id_fk FOREIGN KEY (sms_team_id)
    REFERENCES flow.sms_team (id) MATCH SIMPLE
                                 ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_sto_org_id_fk FOREIGN KEY (org_id)
    REFERENCES flow.org (id) MATCH SIMPLE
                                 ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_sto_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                 ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_sto_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                 ON UPDATE NO ACTION ON DELETE NO ACTION
    );

CREATE INDEX if not exists sto_sms_team_id_idx ON flow.sms_team_org (sms_team_id);

CREATE INDEX if not exists sto_org_id_idx ON flow.sms_team_org (org_id);

CREATE TABLE if NOT EXISTS flow.project_message_properties
(
    id        serial                NOT NULL,
    project_id              integer NOT NULL
    constraint pmp_project_id_fk
    references flow.project(id),
    last_sent timestamp without time zone,
    date_created            timestamp without time zone default now(),
    date_modified           timestamp without time zone default now(),
    created_by_id     integer not null,
    modified_by_id    integer,
    closed               boolean not null default false,
    CONSTRAINT flow_project_message_properties_pk PRIMARY KEY (id),
    CONSTRAINT pmp_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pmp_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                        ON UPDATE NO ACTION ON DELETE NO ACTION
    );

create INDEX if not exists pmp_project_id_ix on flow.project_message_properties (project_id);

CREATE TABLE if NOT EXISTS flow.project_message_team
(
    id        serial                NOT NULL,
    project_id              integer NOT NULL
    constraint pmt_project_id_fk
    references flow.project(id),
    sms_team_id integer NOT NULL,
    archived boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified           timestamp without time zone default now(),
    created_by_id     integer not null,
    modified_by_id    integer,
    CONSTRAINT flow_project_message_team_pk PRIMARY KEY (id),
    CONSTRAINT flow_pmt_sms_team_id_fk FOREIGN KEY (sms_team_id)
    REFERENCES flow.sms_team (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT pmt_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pmt_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
    );

CREATE INDEX if not exists pmt_sms_team_id_idx ON flow.project_message_team (sms_team_id);

create INDEX if not exists pmt_project_id_ix on flow.project_message_team (project_id) where archived is false;

CREATE TABLE if NOT EXISTS flow.project_message_owner
(
    id        serial                NOT NULL,
    project_id              integer NOT NULL
    constraint pmow_project_id_fk
    references flow.project(id),
    sms_team_id integer NOT NULL,
    user_id integer NOT NULL,
    archived boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified           timestamp without time zone default now(),
    created_by_id     integer not null,
    modified_by_id    integer,
    CONSTRAINT flow_project_message_owner_pk PRIMARY KEY (id),
    CONSTRAINT flow_pmow_sms_team_id_fk FOREIGN KEY (sms_team_id)
    REFERENCES flow.sms_team (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pmow_user_id_fk FOREIGN KEY (user_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT pmow_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pmow_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
    );

CREATE INDEX if not exists pmo_sms_team_id_idx ON flow.project_message_owner (sms_team_id);

CREATE INDEX if not exists pmo_user_id_idx ON flow.project_message_owner (user_id);

CREATE TABLE if NOT EXISTS flow.project_message_owner_history
(
    id        serial                NOT NULL,
    project_id              integer NOT NULL,
    sms_team_id integer NOT NULL,
    user_id integer,
    date_created            timestamp without time zone default now(),
    date_removed            timestamp without time zone,
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT flow_project_message_owner_history_pk PRIMARY KEY (id),
    CONSTRAINT flow_pmoh_project_id_fk FOREIGN KEY (project_id)
    REFERENCES flow.project (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pmoh_sms_team_id_fk FOREIGN KEY (sms_team_id)
    REFERENCES flow.sms_team (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pmoh_user_id_fk FOREIGN KEY (user_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pmoh_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_pmoh_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
    );

CREATE INDEX if not exists pmoh_project_id_idx ON flow.project_message_owner_history (project_id);

CREATE INDEX if not exists pmoh_sms_team_id_idx ON flow.project_message_owner_history (sms_team_id);

CREATE INDEX if not exists pmoh_user_id_idx ON flow.project_message_owner_history (user_id);

CREATE TABLE if NOT EXISTS flow.message_template
(
    id        serial                NOT NULL,
    title              text NOT NULL,
    message            text NOT NULL,
    team_ids integer[],
    archived boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified           timestamp without time zone default now(),
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT flow_message_template_pk PRIMARY KEY (id)
    );

create INDEX if not exists smsq_to_phone_ix
    on flow.sms_queue using gin ((trim(translate(to_phone, '()-+. ', ''))) gin_trgm_ops);

create INDEX if not exists smsr_from_phone_ix
    on flow.sms_reply using gin  ((trim(translate(from_phone, '()-+. ', ''))) gin_trgm_ops);

insert into flow.feature(feature_name, feature_code, feature_path)
select 'SMS Inbox', 'SMS_INBOX', '/inbox'
    where not exists (select id from flow.feature where feature_code = 'SMS_INBOX');

insert into flow.company_feature(feature_name, company_id, feature_id, home_page)
select 'SMS Inbox', 3, (select id from flow.feature where feature_code = 'SMS_INBOX'), false
    where not exists (select id from flow.company_feature where feature_name = 'SMS Inbox' and company_id = 3);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
    (select (select id from flow.feature where feature_code = 'SMS_INBOX'), ac.id, 2350555
     from flow.access_control ac
     where not exists (
             select fac.id
             from flow.feature_access_control fac
             where feature_id = (select id from flow.feature where feature_code = 'SMS_INBOX')
               and access_control_id = ac.id
         )
       and ac.id in (1,2,3,4,6,8)
    );
