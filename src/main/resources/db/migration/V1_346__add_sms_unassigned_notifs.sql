CREATE TABLE if not exists flow.sms_team_user_unassigned_notification
(
    id                 serial  NOT NULL,
    sms_team_id        integer NOT NULL,
    user_id            integer NOT NULL,
    date_created       timestamp without time zone DEFAULT now(),
    date_modified      timestamp without time zone DEFAULT now(),
    created_by_id      integer not null,
    modified_by_id     integer,
    archived           boolean not null            default false,
    CONSTRAINT flow_sms_team_user_unassigned_notification_pk PRIMARY KEY (id),
    CONSTRAINT flow_stuun_sms_team_id_fk FOREIGN KEY (sms_team_id)
    REFERENCES flow.sms_team (id) MATCH SIMPLE
                                 ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_stuun_user_id_fk FOREIGN KEY (user_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                 ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_stuun_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                 ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_stuun_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                 ON UPDATE NO ACTION ON DELETE NO ACTION
    );

CREATE unique INDEX IF NOT EXISTS flow_stuun_index ON flow.sms_team_user_unassigned_notification(sms_team_id, user_id);
