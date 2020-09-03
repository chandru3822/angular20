alter table flow.custom_field_group_assignment
add column  if not exists read_only boolean not null default false;

CREATE TABLE if not exists flow.custom_field_group_assignment_white_listed_position
(
    id                       serial  NOT NULL,
    custom_field_group_assignment_id       integer NOT NULL,
    position_id       integer NOT NULL,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_cfgawlp_pk PRIMARY KEY (id),
    CONSTRAINT flow_cfgawlp_custom_field_group_assignment_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_cfgawlp_position_fk FOREIGN KEY (position_id)
        REFERENCES flow.position (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_cfgawlp_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_cfgawlp_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION

);
