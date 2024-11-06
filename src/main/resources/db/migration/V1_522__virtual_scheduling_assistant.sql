CREATE TABLE if not exists flow.virtual_resource_slot_capacity
(
	id                       serial  NOT NULL,
	company_id       integer NOT NULL,
	org_id integer NOT NULL,
	max_capacity integer not null,
	start_time   time not null,
	end_time   time not null,
	day_of_week_id  integer not null,
	daylight_savings boolean not null default false,
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
	CONSTRAINT flow_vrsc_day_of_week_id_fk FOREIGN KEY (day_of_week_id)
	REFERENCES flow.day_of_week (id) MATCH SIMPLE
	                          ON UPDATE RESTRICT ON DELETE RESTRICT,
	REFERENCES flow.user (id) MATCH SIMPLE
	                          ON UPDATE NO ACTION ON DELETE NO ACTION,
	CONSTRAINT flow_vrsc_modified_by_id_fk FOREIGN KEY (modified_by_id)
	REFERENCES flow.user (id) MATCH SIMPLE
	                          ON UPDATE NO ACTION ON DELETE NO ACTION
	);

