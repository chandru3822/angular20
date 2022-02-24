CREATE TABLE if not exists flow.email_sender
(
	id                       serial  NOT NULL,
	email_address varchar(200) NOT NULL,
	sender_name varchar(200),
	company_id       integer NOT NULL,
	is_default boolean not null default false,
	date_created     timestamp without time zone DEFAULT now(),
	created_by_id    integer not null,
	date_modified   timestamp without time zone default now(),
	modified_by_id  integer,
	archived       boolean not null default false,
	CONSTRAINT flow_email_sender_pk PRIMARY KEY (id),
	CONSTRAINT flow_email_company_id_fk FOREIGN KEY (company_id)
	REFERENCES flow.company (id) MATCH SIMPLE
	                           ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT flow_email_created_by_id_fk FOREIGN KEY (created_by_id)
	REFERENCES flow.user (id) MATCH SIMPLE
	                           ON UPDATE NO ACTION ON DELETE NO ACTION,
	CONSTRAINT flow_email_modified_by_id_fk FOREIGN KEY (modified_by_id)
	REFERENCES flow.user (id) MATCH SIMPLE
	                           ON UPDATE NO ACTION ON DELETE NO ACTION
	);

INSERT INTO flow.email_sender (email_address, sender_name, company_id, is_default, created_by_id)
select 'support@blueravensolar.com', 'Blue Raven Support', 3, true, 99999999
	where not exists(select id from flow.email_sender where email_address = 'support@blueravensolar.com')
;

INSERT INTO flow.email_sender (email_address, sender_name, company_id, created_by_id)
select 'salesops@blueravensolar.com', 'Blue Raven Sales', 3, 99999999
	where not exists(select id from flow.email_sender where email_address = 'salesops@blueravensolar.com')
;

INSERT INTO flow.email_sender (email_address, sender_name, company_id, created_by_id)
select 'brs.operations@blueravensolar.com', 'Blue Raven Operations', 3, 99999999
	where not exists(select id from flow.email_sender where email_address = 'brs.operations@blueravensolar.com')
;

INSERT INTO flow.email_sender (email_address, sender_name, company_id, created_by_id)
select 'bugs@blueravensolar.com', 'Blue Raven Bugs', 3, 99999999
	where not exists(select id from flow.email_sender where email_address = 'bugs@blueravensolar.com')
;

INSERT INTO flow.email_sender (email_address, sender_name, company_id, created_by_id)
select 'closers@blueravensolar.com', 'Blue Raven Closers', 3, 99999999
	where not exists(select id from flow.email_sender where email_address = 'closers@blueravensolar.com')
;

INSERT INTO flow.email_sender (email_address, sender_name, company_id, created_by_id)
select 'saleshr@blueravensolar.com', 'Blue Raven Sales HR', 3, 99999999
	where not exists(select id from flow.email_sender where email_address = 'saleshr@blueravensolar.com')
;

DROP TABLE if exists brs.email_sender;
