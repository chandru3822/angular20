-- V1_550__user_login.sql
CREATE TABLE IF NOT EXISTS flow.user_login (
  id BIGSERIAL,
  user_id BIGINT,
  date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  access_type VARCHAR(10),
  mobile_version VARCHAR(50),
  login_successful BOOLEAN,
  CONSTRAINT fk_user
  FOREIGN KEY(user_id)
  REFERENCES flow.user(id)
  ON DELETE CASCADE
  );
