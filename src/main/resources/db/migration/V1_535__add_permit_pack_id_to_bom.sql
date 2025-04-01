ALTER TABLE brs.bill_of_materials_non_parts_master_parts
	ADD permit_pack_id integer REFERENCES brs.permit_pack_log_history (id);

DROP TABLE if exists brs.bill_of_materials_non_parts_master_parts;
DROP TABLE if exists brs.non_parts_master_parts;

CREATE TABLE if not exists brs.custom_parts(
	                                           id                       serial  NOT NULL,
	                                           name                    VARCHAR(1000),
	part_number             VARCHAR(100) NOT NULL,
	usage                   INT,
	date_created            timestamp without time zone DEFAULT now(),
	date_modified           timestamp without time zone,
	created_by_id           integer      not null,
	modified_by_id          integer,
	archived                boolean not null default false,
	CONSTRAINT brs_custom_parts_pk PRIMARY KEY (id)
	);

CREATE TABLE if not exists brs.bill_of_materials_custom_parts
(
	id                              serial  NOT NULL,
	quantity                        integer NOT NULL CHECK (quantity > 0), -- Ensuring positive quantity
	custom_part_id       bigInt NOT NULL,
	project_id                      integer NOT NULL,
	supplier_id                     integer,
	supplier_confirmed              boolean default false,
	date_created                    timestamp without time zone DEFAULT now(),
	date_modified                   timestamp without time zone,
	created_by_id                   integer      not null,
	modified_by_id                  integer,
	archived                        boolean not null default false,
	CONSTRAINT brs_bill_of_materials_custom_parts_pk PRIMARY KEY (id),
	CONSTRAINT brs_custom_parts_id_fk FOREIGN KEY (custom_part_id)
	REFERENCES brs.custom_parts (id) MATCH SIMPLE
	                                          ON UPDATE RESTRICT ON DELETE RESTRICT ,
	CONSTRAINT flow_project_id_fk FOREIGN KEY (project_id)
	REFERENCES flow.project (id) MATCH SIMPLE
	                                          ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT brs_supplier_id_fk FOREIGN KEY (supplier_id)
	REFERENCES brs.feat_db_supplier (id) MATCH SIMPLE
	                                          ON UPDATE RESTRICT ON DELETE RESTRICT
	);

CREATE INDEX if not exists brs_custom_parts_id_idx ON brs.bill_of_materials_custom_parts (custom_part_id);
CREATE INDEX if not exists flow_project_id_idx ON brs.bill_of_materials_custom_parts (project_id);
