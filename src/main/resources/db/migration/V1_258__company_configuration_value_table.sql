-- drop table brs.configuration_value;
CREATE TABLE if not exists flow.company_configuration_value
(
  id                       serial  NOT NULL,
  company_id       integer NOT NULL,
  name       varchar(255),
  code       varchar(255),
  value       text,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT flow_company_configuration_pk PRIMARY KEY (id),
  CONSTRAINT flow_ccv_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_ccv_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_ccv_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

insert into flow.company_configuration_value(company_id, name, code, value, created_by_id)
  select 3,'Closer Position IDs', 'CLOSER_POSITION_IDS', '1,2,3,133,237,517',2350555
    where not exists(select id
                    from flow.company_configuration_value
                    where code = 'CLOSER_POSITION_IDS');

insert into flow.company_configuration_value(company_id, name, code, value, created_by_id)
select 3, 'Setter Position IDs', 'SETTER_POSITION_IDS','4,5,6,573,73', 2350555
where not exists(select id
                 from flow.company_configuration_value
                 where code = 'SETTER_POSITION_IDS');
