
alter table flow.position
add column if not exists sms_enabled boolean default false;

CREATE TABLE if NOT EXISTS flow.user_message_properties
(
    id        serial                NOT NULL,
    user_id              integer NOT NULL
    constraint ump_user_id_fk
    references flow.user(id),
    last_sent timestamp without time zone,
    date_created            timestamp without time zone default now(),
    date_modified           timestamp without time zone default now(),
    created_by_id     integer not null,
    modified_by_id    integer,
    closed               boolean not null default false,
    CONSTRAINT flow_user_message_properties_pk PRIMARY KEY (id),
    CONSTRAINT ump_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ump_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                        ON UPDATE NO ACTION ON DELETE NO ACTION
    );

create INDEX if not exists ump_user_id_ix on flow.user_message_properties (user_id);

create unique index if not exists ump_user_id_uindex on flow.user_message_properties (user_id);

CREATE TABLE if NOT EXISTS flow.user_message_team
(
    id        serial                NOT NULL,
    user_id              integer NOT NULL
    constraint umt_user_id_fk
    references flow.user(id),
    sms_team_id integer NOT NULL,
    archived boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified           timestamp without time zone default now(),
    created_by_id     integer not null,
    modified_by_id    integer,
    CONSTRAINT flow_user_message_team_pk PRIMARY KEY (id),
    CONSTRAINT flow_umt_sms_team_id_fk FOREIGN KEY (sms_team_id)
    REFERENCES flow.sms_team (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT pmt_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT umt_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
    );

CREATE INDEX if not exists umt_sms_team_id_idx ON flow.user_message_team (sms_team_id);

create INDEX if not exists umt_user_id_ix on flow.user_message_team (user_id) where archived is false;

CREATE TABLE if NOT EXISTS flow.user_message_owner
(
    id        serial                NOT NULL,
    user_id              integer NOT NULL
    constraint pmow_user_id_fk
    references flow.user(id),
    sms_team_id integer NOT NULL,
    owner_user_id integer NOT NULL,
    archived boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified           timestamp without time zone default now(),
    created_by_id     integer not null,
    modified_by_id    integer,
    CONSTRAINT flow_user_message_owner_pk PRIMARY KEY (id),
    CONSTRAINT flow_umow_sms_team_id_fk FOREIGN KEY (sms_team_id)
    REFERENCES flow.sms_team (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_umow_user_id_fk FOREIGN KEY (owner_user_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT umow_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT umow_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
    );

CREATE INDEX if not exists umo_sms_team_id_idx ON flow.user_message_owner (sms_team_id);

CREATE INDEX if not exists umo_user_id_idx ON flow.user_message_owner (user_id);

CREATE TABLE if NOT EXISTS flow.user_message_owner_history
(
    id        serial                NOT NULL,
    owner_user_id integer NOT NULL,
    sms_team_id integer NOT NULL,
    user_id              integer,
    date_created            timestamp without time zone default now(),
    date_removed            timestamp without time zone,
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT flow_user_message_owner_history_pk PRIMARY KEY (id),
    CONSTRAINT flow_umoh_user_id_fk FOREIGN KEY (user_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_umoh_sms_team_id_fk FOREIGN KEY (sms_team_id)
    REFERENCES flow.sms_team (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_umoh_owner_user_id_fk FOREIGN KEY (owner_user_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_umoh_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_umoh_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
    );

alter table flow.user
    add column if not exists search_phone varchar generated always as ((right(translate(
    (COALESCE(phone_number, ''::character varying))::text,
    '+-() '::text, ''::text), 10))) stored;

create index if not exists flow_user_phone_ix
  on flow.user (search_phone);

create index if not exists notification_metadata_userId_ix on flow.notification using btree (((metadata -> 'userId')::integer));
