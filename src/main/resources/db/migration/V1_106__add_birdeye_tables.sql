--------------------------------------------------------------------------------
-- define table to store invitations
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS brs.birdeye_invitations (
  id                  serial NOT NULL,
  project_id          bigserial NOT NULL,
  birdeye_business_id character varying(64),
  birdeye_customer_id character varying(64),
  date_sent           timestamp with time zone,
  raw_invitation      jsonb,
  CONSTRAINT birdeye_invitations_pkey PRIMARY KEY (id),
  CONSTRAINT birdeye_invitations_birdeye_business_id_fkey FOREIGN KEY (birdeye_business_id)
      REFERENCES brs.birdeye_location (business_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT birdeye_invitations_project_id_fkey FOREIGN KEY (project_id)
      REFERENCES flow.project (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);
--------------------------------------------------------------------------------
-- define table to store reviews
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS brs.birdeye_reviews (
  id                  serial NOT NULL,
  birdeye_business_id character varying(64),
  birdeye_customer_id character varying(64),
  birdeye_review_id   character varying(64),
  review_date         date,
  brs_response_date   date,
  review_text         varchar(2048),
  review_score        numeric,
  CONSTRAINT birdeye_reviews_pkey PRIMARY KEY (id),
  CONSTRAINT birdeye_reviews_birdeye_review_id_key UNIQUE (birdeye_review_id)
);
