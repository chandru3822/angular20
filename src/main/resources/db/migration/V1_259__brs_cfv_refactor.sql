-- Commission Override
-- AHJ Design
-- AHJ Permit
-- Proposals
-- AHJ Inspection
-- AHJ Utility

-- drop table if exists brs.commission_override_custom_field_value;
-- drop table if exists brs.ahj_design;
-- drop table if exists brs.ahj_permit;
-- drop table if exists brs.ahj_inspection;
-- drop table if exists brs.ahj_utility;

CREATE TABLE if not exists brs.commission_override_custom_field_value
(
  id              serial  not null,
  override_plan_id       integer not null,
  date_value      date,
  custom_field_group_assignment_id integer not null,
  timestamp_value timestamp,
  boolean_value   boolean,
  text_value      text,
  numeric_value   numeric,
  int_value       integer,
  int_array_value integer[],
  date_created    timestamp without time zone DEFAULT now(),
  date_modified    timestamp without time zone,
  created_by_id   integer not null,
  modified_by_id  integer,
  CONSTRAINT brs_commission_override_custom_field_value_pk PRIMARY KEY (id),
  CONSTRAINT brs_cocfv_custom_field_id_fk FOREIGN KEY (custom_field_group_assignment_id)
    REFERENCES brs.custom_field_group_assignment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_cocfv_override_plan_id_fk FOREIGN KEY (override_plan_id)
    REFERENCES brs.override_plan (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_cocfv_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_cocfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.ahj_design_custom_field_value
(
  id              serial  not null,
  ahj_design_id       integer not null,
  date_value      date,
  custom_field_group_assignment_id integer not null,
  timestamp_value timestamp,
  boolean_value   boolean,
  text_value      text,
  numeric_value   numeric,
  int_value       integer,
  int_array_value integer[],
  date_created    timestamp without time zone DEFAULT now(),
  date_modified    timestamp without time zone,
  created_by_id   integer not null,
  modified_by_id  integer,
  CONSTRAINT brs_ahj_design_custom_field_value_pk PRIMARY KEY (id),
  CONSTRAINT brs_adcfv_custom_field_id_fk FOREIGN KEY (custom_field_group_assignment_id)
    REFERENCES brs.custom_field_group_assignment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_adcfv_ahj_design_id_fk FOREIGN KEY (ahj_design_id)
    REFERENCES brs.ahj_design (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_adcfv_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_adcfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.ahj_permit_custom_field_value
(
  id              serial  not null,
  ahj_permit_id       integer not null,
  date_value      date,
  custom_field_group_assignment_id integer not null,
  timestamp_value timestamp,
  boolean_value   boolean,
  text_value      text,
  numeric_value   numeric,
  int_value       integer,
  int_array_value integer[],
  date_created    timestamp without time zone DEFAULT now(),
  date_modified    timestamp without time zone,
  created_by_id   integer not null,
  modified_by_id  integer,
  CONSTRAINT brs_ahj_permit_custom_field_value_pk PRIMARY KEY (id),
  CONSTRAINT brs_apcfv_custom_field_id_fk FOREIGN KEY (custom_field_group_assignment_id)
    REFERENCES brs.custom_field_group_assignment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_apcfv_ahj_permit_id_fk FOREIGN KEY (ahj_permit_id)
    REFERENCES brs.ahj_permit (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_apcfv_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_apcfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.ahj_inspection_custom_field_value
(
  id              serial  not null,
  ahj_inspection_id       integer not null,
  date_value      date,
  custom_field_group_assignment_id integer not null,
  timestamp_value timestamp,
  boolean_value   boolean,
  text_value      text,
  numeric_value   numeric,
  int_value       integer,
  int_array_value integer[],
  date_created    timestamp without time zone DEFAULT now(),
  date_modified    timestamp without time zone,
  created_by_id   integer not null,
  modified_by_id  integer,
  CONSTRAINT brs_ahj_inspection_custom_field_value_pk PRIMARY KEY (id),
  CONSTRAINT brs_aicfv_custom_field_id_fk FOREIGN KEY (custom_field_group_assignment_id)
    REFERENCES brs.custom_field_group_assignment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_aicfv_ahj_inspection_id_fk FOREIGN KEY (ahj_inspection_id)
    REFERENCES brs.ahj_inspection (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_aicfv_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_aicfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.ahj_utility_custom_field_value
(
  id              serial  not null,
  ahj_utility_id       integer not null,
  date_value      date,
  custom_field_group_assignment_id integer not null,
  timestamp_value timestamp,
  boolean_value   boolean,
  text_value      text,
  numeric_value   numeric,
  int_value       integer,
  int_array_value integer[],
  date_created    timestamp without time zone DEFAULT now(),
  date_modified    timestamp without time zone,
  created_by_id   integer not null,
  modified_by_id  integer,
  CONSTRAINT brs_ahj_utility_custom_field_value_pk PRIMARY KEY (id),
  CONSTRAINT brs_aucfv_custom_field_id_fk FOREIGN KEY (custom_field_group_assignment_id)
    REFERENCES brs.custom_field_group_assignment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_aucfv_ahj_utility_id_fk FOREIGN KEY (ahj_utility_id)
    REFERENCES brs.ahj_utility (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_aucfv_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_aucfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);



-- commission override field migration
insert into brs.commission_override_custom_field_value(override_plan_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, date_created, date_modified, created_by_id, modified_by_id)
select source_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, cfv.date_created, cfv.date_modified, cfv.created_by_id, cfv.modified_by_id
       from brs.custom_field_value cfv
inner join brs.custom_field_group_assignment cfga on cfv.custom_field_group_assignment_id = cfga.id
inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
where cfg.object_type_id = 9;

-- ahj permit field migration
insert into brs.ahj_permit_custom_field_value(ahj_permit_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, date_created, date_modified, created_by_id, modified_by_id)
select source_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, cfv.date_created, cfv.date_modified, cfv.created_by_id, cfv.modified_by_id
from brs.custom_field_value cfv
       inner join brs.custom_field_group_assignment cfga on cfv.custom_field_group_assignment_id = cfga.id
       inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
where cfg.object_type_id = 4;

-- ahj utility field migration
insert into brs.ahj_utility_custom_field_value(ahj_utility_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, date_created, date_modified, created_by_id, modified_by_id)
select source_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, cfv.date_created, cfv.date_modified, cfv.created_by_id, cfv.modified_by_id
from brs.custom_field_value cfv
       inner join brs.custom_field_group_assignment cfga on cfv.custom_field_group_assignment_id = cfga.id
       inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
where cfg.object_type_id = 2;

-- ahj design field migration
insert into brs.ahj_design_custom_field_value(ahj_design_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, date_created, date_modified, created_by_id, modified_by_id)
select source_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, cfv.date_created, cfv.date_modified, cfv.created_by_id, cfv.modified_by_id
from brs.custom_field_value cfv
       inner join brs.custom_field_group_assignment cfga on cfv.custom_field_group_assignment_id = cfga.id
       inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
where cfg.object_type_id = 1;

-- ahj inspection field migration
insert into brs.ahj_inspection_custom_field_value(ahj_inspection_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, date_created, date_modified, created_by_id, modified_by_id)
select source_id, date_value, custom_field_group_assignment_id, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, cfv.date_created, cfv.date_modified, cfv.created_by_id, cfv.modified_by_id
from brs.custom_field_value cfv
       inner join brs.custom_field_group_assignment cfga on cfv.custom_field_group_assignment_id = cfga.id
       inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
where cfg.object_type_id = 3;

-- drop table brs.custom_field_value;
