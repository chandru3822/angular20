CREATE TABLE if NOT EXISTS flow.company_object_type
(
    id          serial                NOT NULL,
    object_type_id integer            NOT NULL,
    company_id  integer               NOT NULL,
    archived boolean not null default false,
    CONSTRAINT company_object_type_pk PRIMARY KEY (id),
    CONSTRAINT cot_company_id FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cot_object_type_id FOREIGN KEY (object_type_id)
        REFERENCES flow.object_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);


-- change custom_field_group.object_type_id to look at company_object_type_id
alter table flow.custom_field_group drop constraint if exists cfgt_object_type_id_fk;

alter table flow.custom_field_group
    rename column object_type_id to company_object_type_id;

--drop constraint in case it is already there
alter table flow.custom_field_group drop constraint if exists cfgt_company_object_type_id_fk;
alter table flow.custom_field_group
    add constraint cfgt_company_object_type_id_fk FOREIGN KEY (company_object_type_id)
        REFERENCES flow.company_object_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
;

-- change object_attachment_type.object_type_id to look at company_object_type_id
alter table flow.object_attachment_type drop constraint if exists oat_object_type_id_fk;

alter table flow.object_attachment_type
    rename column object_type_id to company_object_type_id;

--drop constraint in case it is already there
alter table flow.object_attachment_type drop constraint if exists oat_company_object_type_id_fk;
alter table flow.object_attachment_type
    add constraint oat_company_object_type_id_fk FOREIGN KEY (company_object_type_id)
        REFERENCES flow.company_object_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
;

-- change custom_field_object_type.object_type_id to look at company_object_type_id
alter table flow.custom_field_object_type drop constraint if exists cf_object_type_id_fk;

alter table flow.custom_field_object_type
    rename column object_type_id to company_object_type_id;

--drop constraint in case it is already there
alter table flow.custom_field_object_type drop constraint if exists cf_company_object_type_id_fk;
alter table flow.custom_field_object_type
    add constraint cf_company_object_type_id_fk FOREIGN KEY (company_object_type_id)
        REFERENCES flow.company_object_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
;

