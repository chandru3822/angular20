CREATE TABLE IF NOT EXISTS brs.birdeye_locations (
  business_id character varying(64) NOT NULL,
  alias       character varying(64),
  CONSTRAINT  birdeye_locations_pkey PRIMARY KEY (business_id)
);
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
      REFERENCES brs.birdeye_locations (business_id) MATCH SIMPLE
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

--------------------------------------------------------------------------------
-- define initial birdeye locations
--------------------------------------------------------------------------------
INSERT INTO brs.birdeye_locations(business_id, alias)
VALUES  ('154540949381855','Idaho Falls, ID'),
        ('154083883574631', 'Las Vegas, NV'),
        ('154083879730694', 'Summerville, SC'),
        ('154083812211952', 'Raleigh, NC'),
        ('154083800579313', 'Denver, CO'),
        ('158040957051268', 'Colorado Springs, CO'),
        ('152812570758145', 'Orem (Headquarters)'),
        ('159778522934825', 'Zebulon'),
        ('159778516029465', 'Denver'),
        ('159346178852351', 'Layton, UT'),
        ('159768604385031', 'Orem, UT'),
        ('159656219546838', 'Blue Raven Solar'),
        ('159250265045609', 'Colorado Springs, CO'),
        ('158387271750536', 'Raleigh, NC'),
        ('158162106994044', 'Columbus, OH'),
        ('158023703945612', 'Orlando, FL'),
        ('157592140092680', 'North Charleston, SC'),
        ('156158405011057', 'Centennial, CO'),
        ('156158396429842', 'Charlotte, NC'),
        ('154083893178495', 'Hanover Park, IL'),
        ('154083821523512', 'Boise, ID'),
        ('152812626770861', 'Portland, OR');
