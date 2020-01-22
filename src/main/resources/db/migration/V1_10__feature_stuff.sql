ALTER TABLE if exists flow.feature_access_control
    RENAME TO role_feature_access_control;

ALTER TABLE if exists flow.user_feature_access_control_override
    RENAME TO user_feature_access_control;

alter table flow.role_feature_access_control
    rename column archived to enabled;

CREATE TABLE if not exists flow.position_feature_access_control
(
    id              serial                NOT NULL,
    company_feature_id integer not null,
    access_control_id  integer not null,
    position_id integer not null,
    enabled        boolean DEFAULT false,
    CONSTRAINT position_feature_access_control_pk PRIMARY KEY (id),
    CONSTRAINT pfac_company_feature_id_fk FOREIGN KEY (company_feature_id)
        REFERENCES flow.company_feature (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pfac_access_control_id_fk FOREIGN KEY (access_control_id)
        REFERENCES flow.access_control (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pfac_position_id_fk FOREIGN KEY (position_id)
        REFERENCES flow.position (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists pfac_company_feature_id_idx ON flow.position_feature_access_control (company_feature_id);
CREATE INDEX if not exists pfac_access_control_id_idx ON flow.position_feature_access_control (access_control_id);
CREATE INDEX if not exists pfac_position_id_idx ON flow.position_feature_access_control (position_id);
