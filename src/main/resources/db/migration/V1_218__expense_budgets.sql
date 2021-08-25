insert into flow.feature (feature_name, feature_code, feature_path, is_system)
select 'Expenses', 'EXPENSES', null, true
where not exists ( select id
                   from flow.feature where feature_code = 'EXPENSES' );

insert into flow.company_feature (feature_name, company_id, feature_id, home_page, hidden)
select 'Expenses', 3,
       (select id from flow.feature where feature_code = 'EXPENSES' and archived is false),
       false, true
where not exists ( select id
                   from flow.company_feature where feature_name = 'Expenses' );

create table if not exists brs.gl_code
(
  id serial not null,
  code         text                                                            not null,
  description  text                                                            not null,
  active       boolean not null default true,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT brs_gl_code_pk PRIMARY KEY (id),
  CONSTRAINT brs_gc_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_gc_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

