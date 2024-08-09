drop table if exists flow.company_holiday;
create table if not exists company_holiday (
  id BIGSERIAL PRIMARY KEY,
  name TEXT,
  date DATE,
  date_created TIMESTAMP NOT NULL DEFAULT now(),
  date_modified TIMESTAMP NOT NULL DEFAULT now(),
  created_by_id BIGINT,
  modified_by_id BIGINT,
  company_id BIGINT NOT NULL ,
  archived BOOLEAN NOT NULL DEFAULT false,
  CONSTRAINT ch_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

create table if not exists company_holiday_audit (
  id BIGSERIAL,
  name TEXT,
  date DATE,
  date_created TIMESTAMP NOT NULL DEFAULT now(),
  date_modified TIMESTAMP NOT NULL DEFAULT now(),
  created_by_id BIGINT,
  modified_by_id BIGINT,
  company_id BIGINT NOT NULL,
  archived BOOLEAN NOT NULL DEFAULT false,
  CONSTRAINT ch_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

