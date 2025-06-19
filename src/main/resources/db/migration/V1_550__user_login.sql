CREATE TABLE IF NOT EXISTS flow.user_login (
  id BIGSERIAL NOT NULL,
  user_id BIGINT NOT NULL,
  access_type VARCHAR(10) NOT NULL,
  mobile_version VARCHAR(50),
  login_successful BOOLEAN NOT NULL,
  created_by_id INTEGER NOT NULL,
  modified_by_id INTEGER,
  date_created TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  date_modified TIMESTAMP WITHOUT TIME ZONE,
  CONSTRAINT fk_user
   FOREIGN KEY(user_id) REFERENCES flow.user(id) ON DELETE CASCADE,
  CONSTRAINT fk_created_by
   FOREIGN KEY(created_by_id) REFERENCES flow.user(id),
  CONSTRAINT fk_modified_by
   FOREIGN KEY(modified_by_id) REFERENCES flow.user(id)
);
