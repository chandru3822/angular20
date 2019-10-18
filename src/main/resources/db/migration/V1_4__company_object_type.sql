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


insert into flow.company_object_type (object_type_id, company_id)
select 1, 1 where not exists (select id from flow.company_object_type where object_type_id = 1 and company_id = 1 );

insert into flow.company_object_type (object_type_id, company_id)
select 2, 1 where not exists (select id from flow.company_object_type where object_type_id = 2 and company_id = 1 );

insert into flow.company_object_type (object_type_id, company_id)
select 3, 1 where not exists (select id from flow.company_object_type where object_type_id = 3 and company_id = 1 );

insert into flow.company_object_type (object_type_id, company_id)
select 4, 1 where not exists (select id from flow.company_object_type where object_type_id = 4 and company_id = 1 );

insert into flow.company_object_type (object_type_id, company_id)
select 5, 1 where not exists (select id from flow.company_object_type where object_type_id = 5 and company_id = 1 );

-- remove company_id and constraint from object_type
alter table flow.object_type drop column if exists company_id;

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

