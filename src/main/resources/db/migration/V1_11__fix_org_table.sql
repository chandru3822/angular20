alter table flow.org drop column if exists color;
alter table flow.org drop column if exists originator_id;
alter table flow.org drop column if exists sales_area_id;
alter table flow.org drop column if exists display_order;
alter table flow.org drop column if exists calendar_oid;
alter table flow.org drop column if exists sales_metro_area_id;

alter table flow.org add column if not exists archived boolean not null default false;
alter table flow.org add column if not exists date_created timestamp without time zone default now();
alter table flow.org add column if not exists date_modified   timestamp without time zone;
alter table flow.org add column if not exists created_by_id     integer;
alter table flow.org add column if not exists modified_by_id    integer;

alter table flow.role drop column if exists is_system;
alter table flow.user_position drop column if exists secondary_org_id;
alter table flow.position drop column if exists secondary_org_type_id;
alter table flow.user_position drop column if exists active;

alter table flow.user_position add column if not exists archived boolean not null default false;
alter table flow.user_position add column if not exists date_created timestamp without time zone default now();
alter table flow.user_position add column if not exists date_modified   timestamp without time zone;
alter table flow.user_position add column if not exists created_by_id     integer;
alter table flow.user_position add column if not exists modified_by_id    integer;

alter table flow.company add column if not exists level integer;

update flow.company set level = 1 where company_name = 'Albatross';
update flow.company set level = 2 where company_name = 'Blue Raven Corporate';
update flow.company set level = 3 where company_name in ('Blue Raven Solar','B+C Electric','Eco Lux Solar','Salient Solar','Solenrgi','Sun Run');

alter table flow.company alter column level set not null;

alter table flow.org
    add CONSTRAINT org_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
alter table flow.org
    add CONSTRAINT org_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;


CREATE unique INDEX uc_comp1_index ON flow.user_company(user_id) WHERE is_default IS TRUE;


