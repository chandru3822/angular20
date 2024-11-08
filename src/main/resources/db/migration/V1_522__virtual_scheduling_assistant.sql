CREATE TABLE if not exists flow.virtual_resource_slot_capacity
(
	id                       serial  NOT NULL,
	company_id       integer NOT NULL,
	org_id integer NOT NULL,
	max_capacity integer not null,
	start_time timestamp not null,
	end_time timestamp not null,
	date_created     timestamp without time zone DEFAULT now(),
	date_modified   timestamp without time zone,
	created_by_id    integer      not null,
	modified_by_id  integer,
	archived       boolean not null default false,
	CONSTRAINT flow_virtual_resource_slot_capacity_pk PRIMARY KEY (id),
    CONSTRAINT flow_vrsc_company_id_fk FOREIGN KEY (company_id)
	REFERENCES flow.company (id) MATCH SIMPLE
	                          ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT flow_vrsc_org_id_fk FOREIGN KEY (org_id)
	REFERENCES flow.org (id) MATCH SIMPLE
	                          ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT flow_vrsc_created_by_id_fk FOREIGN KEY (created_by_id)
	REFERENCES flow.user (id) MATCH SIMPLE
	                          ON UPDATE NO ACTION ON DELETE NO ACTION,
	CONSTRAINT flow_vrsc_modified_by_id_fk FOREIGN KEY (modified_by_id)
	REFERENCES flow.user (id) MATCH SIMPLE
	                          ON UPDATE NO ACTION ON DELETE NO ACTION
    CONSTRAINT flow_vrsc_org_id_start_time_end_time_id_key
        UNIQUE(org_id, start_time, end_time)
	);

