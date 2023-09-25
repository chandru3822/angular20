CREATE TABLE if NOT EXISTS flow.org_structure_refresh
(
  id        bigserial                NOT NULL,
  org_id    bigint,
  user_position_id bigint,
  CONSTRAINT org_structure_refresh_pk PRIMARY KEY (id)
);






