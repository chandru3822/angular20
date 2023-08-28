--i am manually going to populate this in prod and stage. this fw is just so the table gets created locally
CREATE TABLE if not exists brs.message_type
(
  id              bigserial NOT NULL,
  title           text,
  content         text,
  description     text,
  include_manager boolean   not null          default false,
  date_created    timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone DEFAULT now(),
  created_by_id   integer   not null,
  modified_by_id  integer,
  archived        boolean   not null          default false,
  CONSTRAINT flow_hashtag_type_pk PRIMARY KEY (id),
  CONSTRAINT flow_ht_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_ht_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);
