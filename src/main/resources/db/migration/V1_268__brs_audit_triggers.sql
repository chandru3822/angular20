CREATE TABLE if not exists brs.ahj_design_custom_field_value_audit
(
  id              serial  not null,
  ahj_design_custom_field_value_id integer not null,
  old_value        text,
  new_value        text,
  date_modified    timestamp without time zone,
  modified_by_id  integer,
  CONSTRAINT ahj_design_custom_field_value_audit_pk primary key (id),
  CONSTRAINT ahj_dcfva_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.ahj_inspection_custom_field_value_audit
(
  id              serial  not null,
  ahj_inspection_custom_field_value_id integer not null,
  old_value        text,
  new_value        text,
  date_modified    timestamp without time zone,
  modified_by_id  integer,
  CONSTRAINT ahj_inspection_custom_field_value_audit_pk primary key (id),
  CONSTRAINT ahj_icfva_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);


CREATE TABLE if not exists brs.ahj_permit_custom_field_value_audit
(
  id              serial  not null,
  ahj_permit_custom_field_value_id integer not null,
  old_value        text,
  new_value        text,
  date_modified    timestamp without time zone,
  modified_by_id  integer,
  CONSTRAINT ahj_permit_custom_field_value_audit_pk primary key (id),
  CONSTRAINT ahj_pcfva_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);


CREATE TABLE if not exists brs.ahj_utility_custom_field_value_audit
(
  id              serial  not null,
  ahj_utility_custom_field_value_id integer not null,
  old_value        text,
  new_value        text,
  date_modified    timestamp without time zone,
  modified_by_id  integer,
  CONSTRAINT ahj_utility_custom_field_value_audit_pk primary key (id),
  CONSTRAINT ahj_ucfva_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);


CREATE TABLE if not exists brs.commission_override_custom_field_value_audit
(
  id              serial  not null,
  commission_override_custom_field_value_id integer not null,
  old_value        text,
  new_value        text,
  date_modified    timestamp without time zone,
  modified_by_id  integer,
  CONSTRAINT commission_override_custom_field_value_audit_pk primary key (id),
  CONSTRAINT cocfva_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.proposal_custom_field_value_audit
(
  id              serial  not null,
  proposal_custom_field_value_id integer not null,
  old_value        text,
  new_value        text,
  date_modified    timestamp without time zone,
  modified_by_id  integer,
  CONSTRAINT proposal_custom_field_value_audit_pk primary key (id),
  CONSTRAINT proposalcfva_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.proposal_version_custom_field_value_audit
(
  id              serial  not null,
  proposal_version_custom_field_value_id integer not null,
  old_value        text,
  new_value        text,
  date_modified    timestamp without time zone,
  modified_by_id  integer,
  CONSTRAINT proposal_version_custom_field_value_audit_pk primary key (id),
  CONSTRAINT proposalvcfva_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

