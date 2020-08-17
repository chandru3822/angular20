CREATE TABLE IF NOT EXISTS brs.design_log
(
  id SERIAL NOT NULL,
  design_date date,
  design json,
  source character varying(255),
  project_id bigint,
  design_nbr integer,
  bom json,
  CONSTRAINT pk_design_log PRIMARY KEY (id)
);

CREATE UNIQUE INDEX IF NOT EXISTS pk_design_log
  ON brs.design_log (id);

CREATE INDEX IF NOT EXISTS design_log_design_date_idx
  ON brs.design_log (design_date);

CREATE TABLE if NOT EXISTS brs.design_log_history
(
  id serial NOT NULL,
  project_id character varying(30),
  reference_nbr character varying(4),
  system_size character varying(30),
  annual_production character varying(30),
  system_offset character varying(30),
  total_number_of_modules character varying(30),
  number_of_modules_mp1 character varying(30),
  azimuth_mp1 character varying(30),
  pitch_mp1 character varying(30),
  tsrf_mp1 character varying(30),
  number_of_modules_mp2 character varying(30),
  azimuth_mp2 character varying(30),
  pitch_mp2 character varying(30),
  tsrf_mp2 character varying(30),
  number_of_modules_mp3 character varying(30),
  azimuth_mp3 character varying(30),
  pitch_mp3 character varying(30),
  tsrf_mp3 character varying(30),
  number_of_modules_mp4 character varying(30),
  azimuth_mp4 character varying(30),
  pitch_mp4 character varying(30),
  tsrf_mp4 character varying(30),
  number_of_modules_mp5 character varying(30),
  azimuth_mp5 character varying(30),
  pitch_mp5 character varying(30),
  tsrf_mp5 character varying(30),
  number_of_modules_mp6 character varying(30),
  azimuth_mp6 character varying(30),
  pitch_mp6 character varying(30),
  tsrf_mp6 character varying(30),
  adder_amount character varying(30),
  date_created timestamp default (now()),
  design_log_date character varying(20),
  bom json,
  CONSTRAINT pk_design_log_history PRIMARY KEY (id)
)
WITH (
OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS  brs.design_log_bom
(
  id SERIAL NOT NULL,
  project_id INTEGER NOT NULL,
  reference_nbr INTEGER NOT NULL,
  bom json,
  note text,
  created_by INTEGER,
  time_submitted TIMESTAMP DEFAULT NOW(),
  delivery_time TIMESTAMP,
  email_sent BOOLEAN default false,
  CONSTRAINT design_log_bom_pk PRIMARY KEY (id),
  CONSTRAINT dlb_created_by_fk FOREIGN KEY (created_by)
    REFERENCES flow."user"
);

CREATE INDEX IF NOT EXISTS design_log_bom_project_id_idx
  ON brs.design_log_bom (project_id);

CREATE UNIQUE INDEX IF NOT EXISTS design_log_bom_id_idx
  ON brs.design_log_bom (id);

CREATE INDEX IF NOT EXISTS design_log_bom_reference_nbr_idx
  ON brs.design_log_bom (reference_nbr);

create sequence if not exists brs.design_nbr_seq
    minvalue 1000
    maxvalue 9999
    cycle;
