CREATE TABLE if not exists brs.email_sender
(
    id serial NOT NULL,
    email_address varchar(200) NOT NULL,
    date_created timestamp without time zone,
    created_by_id integer,
    date_modified timestamp without time zone,
    modified_by_id integer,
    archived BOOLEAN DEFAULT false,
    CONSTRAINT email_sender_pkey PRIMARY KEY (id),
    CONSTRAINT email_created_by_id_fkey FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT email_modified_by_id_fkey FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

INSERT INTO brs.email_sender (email_address)
(select 'test.peterson@blueravensolar.com' where not exists (select id from brs.email_sender where email_address = 'test.peterson@blueravensolar.com'));

INSERT INTO brs.email_sender (email_address)
(select 'brs.operations@blueravensolar.com' where not exists (select id from brs.email_sender where email_address = 'brs.operations@blueravensolar.com'));

INSERT INTO brs.email_sender (email_address)
(select 'bugs@blueravensolar.com' where not exists (select id from brs.email_sender where email_address = 'bugs@blueravensolar.com'));

INSERT INTO brs.email_sender (email_address)
(select 'closers@blueravensolar.com' where not exists (select id from brs.email_sender where email_address = 'closers@blueravensolar.com'));

INSERT INTO brs.email_sender (email_address)
(select 'judson.sacco@blueravensolar.com' where not exists (select id from brs.email_sender where email_address = 'judson.sacco@blueravensolar.com'));

INSERT INTO brs.email_sender (email_address)
(select 'katherine.miller@blueravensolar.com' where not exists (select id from brs.email_sender where email_address = 'katherine.miller@blueravensolar.com'));

INSERT INTO brs.email_sender (email_address)
(select 'luone.ingram@blueravensolar.com' where not exists (select id from brs.email_sender where email_address = 'luone.ingram@blueravensolar.com'));

INSERT INTO brs.email_sender (email_address)
(select 'ryan.hightower@blueravensolar.com' where not exists (select id from brs.email_sender where email_address = 'ryan.hightower@blueravensolar.com'));

INSERT INTO brs.email_sender (email_address)
(select 'saleshr@blueravensolar.com' where not exists (select id from brs.email_sender where email_address = 'saleshr@blueravensolar.com'));

INSERT INTO brs.email_sender (email_address)
(select 'salesops@blueravensolar.com' where not exists (select id from brs.email_sender where email_address = 'salesops@blueravensolar.com'));

INSERT INTO brs.email_sender (email_address)
(select 'support@blueravensolar.com' where not exists (select id from brs.email_sender where email_address = 'support@blueravensolar.com'));
