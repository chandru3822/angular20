drop table if exists flow.hashtag_type;
CREATE TABLE if not exists flow.hashtag_type
(
  id             bigserial NOT NULL,
  hashtag_type   varchar(100),
  is_system      boolean   not null          default false,
  date_created   timestamp without time zone DEFAULT now(),
  date_modified  timestamp without time zone DEFAULT now(),
  created_by_id  integer   not null,
  modified_by_id integer,
  archived       boolean   not null          default false,
  CONSTRAINT flow_hashtag_type_pk PRIMARY KEY (id),
  CONSTRAINT flow_ht_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_ht_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

insert into flow.hashtag_type(hashtag_type, created_by_id, modified_by_id)
select 'Activity', 2417170, 2417170
where not exists (select id from flow.hashtag_type as ht where hashtag_type = 'Activity');

insert into flow.hashtag_type(hashtag_type, created_by_id, modified_by_id)
select 'Note', 2417170, 2417170
where not exists (select id from flow.hashtag_type as ht where hashtag_type = 'Note');

CREATE TABLE if not exists flow.hashtag
(
  id             bigserial NOT NULL,
  hashtag   varchar(255),
  hashtag_type_id bigint not null,
  company_id     bigint    NOT NULL,
  date_created   timestamp without time zone DEFAULT now(),
  date_modified  timestamp without time zone DEFAULT now(),
  created_by_id  integer   not null,
  modified_by_id integer,
  archived       boolean   not null          default false,
  CONSTRAINT flow_hashtag_pk PRIMARY KEY (id),
  CONSTRAINT flow_h_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_h_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_h_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ht_hashtag_type_id_idx ON flow.hashtag (hashtag_type_id);

insert into flow.hashtag(hashtag, hashtag_type_id, company_id, created_by_id, modified_by_id)
select 'event', 1, 3, 2417170, 2417170
where not exists (select id from flow.hashtag as h where hashtag = 'event');
insert into flow.hashtag(hashtag, hashtag_type_id, company_id, created_by_id, modified_by_id)
select 'process-step', 1, 3, 2417170, 2417170
where not exists (select id from flow.hashtag as h where hashtag = 'process-step');
insert into flow.hashtag(hashtag, hashtag_type_id, company_id, created_by_id, modified_by_id)
select 'project', 1, 3, 2417170, 2417170
where not exists (select id from flow.hashtag as h where hashtag = 'project');
