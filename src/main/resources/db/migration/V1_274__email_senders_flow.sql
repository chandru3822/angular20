CREATE TABLE if not exists flow.email_sender
(
	id                       serial  NOT NULL,
	company_id       integer NOT NULL,
	is_default  boolean not null default false,
	date_created     timestamp without time zone DEFAULT now(),
	date_modified   timestamp without time zone,
	created_by_id    integer      not null,
	modified_by_id  integer,
	archived       boolean not null default false,
	CONSTRAINT flow_email_sender_pk PRIMARY KEY (id),
	CONSTRAINT flow_s_company_id_fk FOREIGN KEY (company_id)
		REFERENCES flow.company (id) MATCH SIMPLE
		ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT flow_s_created_by_id_fk FOREIGN KEY (created_by_id)
		REFERENCES flow.user (id) MATCH SIMPLE
		ON UPDATE NO ACTION ON DELETE NO ACTION,
	CONSTRAINT flow_s_modified_by_id_fk FOREIGN KEY (modified_by_id)
		REFERENCES flow.user (id) MATCH SIMPLE
		ON UPDATE NO ACTION ON DELETE NO ACTION
);

INSERT INTO flow.email_sender(email_address, company_id, created_by_id, is_default)
VALUES  ((select 'support@blueravensolar.com' where not exists (select id from flow.email_sender where email_address = 'support@blueravensolar.com')),
         3, 99999999, true);

INSERT INTO flow.email_sender (email_address, company_id, created_by_id)
	VALUES ((select 'salesops@blueravensolar.com'
	         where not exists(select id from flow.email_sender where email_address = 'salesops@blueravensolar.com')),
	        3, 99999999);

