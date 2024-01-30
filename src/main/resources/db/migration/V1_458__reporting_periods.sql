CREATE TABLE if NOT EXISTS brs.reporting_period
(
  id        bigserial                NOT NULL,
  year integer not null,
  quarter integer not null,
  period integer not null,
  week integer not null,
  start_date date,
  end_date date,
  date_created        timestamp not null default now(),
  created_by_id       bigint not null
    references flow."user",
  date_modified       timestamp not null default now(),
  modified_by_id      bigint not null
    references flow."user",
  CONSTRAINT reporting_period_id_pk PRIMARY KEY (id)
);
