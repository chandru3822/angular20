CREATE TABLE if not exists brs.bill_of_materials
(
	id                  serial NOT NULL,
	project_id          bigint unique not null,
	date_created        timestamp without time zone DEFAULT now(),
	date_modified       timestamp without time zone,
	created_by_id       integer not null,
	modified_by_id      integer,
	archived            boolean not null default false,
	CONSTRAINT brs_bill_of_materials_pk PRIMARY KEY (id),
	CONSTRAINT flow_project_id_fk FOREIGN KEY (project_id)
	REFERENCES flow.project (id) MATCH SIMPLE
	                              ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT brs_bom_created_by_id_fk FOREIGN KEY (created_by_id)
	REFERENCES flow.user (id) MATCH SIMPLE
	                              ON UPDATE NO ACTION ON DELETE NO ACTION,
	CONSTRAINT brs_bom_modified_by_id_fk FOREIGN KEY (modified_by_id)
	REFERENCES flow.user (id) MATCH SIMPLE
	                              ON UPDATE NO ACTION ON DELETE NO ACTION
	);

CREATE INDEX if not exists flow_project_id_idx ON brs.bill_of_materials (project_id);



CREATE TABLE if not exists brs.bill_of_materials_parts
(
	id                       serial  NOT NULL,
	quantity integer NOT NULL CHECK (quantity > 0), -- Ensuring positive quantity
	parts_master_id bigInt NOT NULL,
	bom_id integer NOT NULL,
	supplier_id integer,
	supplier_confirmed boolean default false,
	date_created     timestamp without time zone DEFAULT now(),
	date_modified   timestamp without time zone,
	created_by_id    integer      not null,
	modified_by_id  integer,
	archived       boolean not null default false,
	CONSTRAINT brs_bill_of_materials_parts_pk PRIMARY KEY (id),
	CONSTRAINT brs_parts_master_id_fk FOREIGN KEY (parts_master_id)
	REFERENCES brs.parts_master_version_custom_field_group (id) MATCH SIMPLE
	                           ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT brs_bom_id_fk FOREIGN KEY  (bom_id)
	REFERENCES brs.bill_of_materials (id) MATCH SIMPLE
	                           ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT brs_supplier_id_fk FOREIGN KEY (supplier_id)
	REFERENCES brs.feat_db_supplier (id) MATCH SIMPLE
	                           ON UPDATE RESTRICT ON DELETE RESTRICT
	);

CREATE INDEX if not exists brs_parts_master_id_idx ON brs.bill_of_materials_parts (parts_master_id);
CREATE INDEX if not exists brs_bom_id_idx ON brs.bill_of_materials_parts (bom_id);
