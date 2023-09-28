alter table if exists flow.postal_code_zone rename to round_robin;
alter table if exists flow.postal_code_zone_audit rename to round_robin_audit;
alter table if exists flow.postal_code_zone_user rename to round_robin_user;
alter table if exists flow.postal_code_zone_user_audit rename to round_robin_user_audit;
alter table if exists flow.postal_code_zone_user_type rename to round_robin_user_type;

ALTER TABLE flow.round_robin
    RENAME COLUMN zone_name TO round_robin_name;

ALTER TABLE flow.round_robin RENAME CONSTRAINT postal_code_zone_pk TO round_robin_pk;
ALTER INDEX if exists flow.pcz_company_id_ix RENAME TO rr_company_id_ix;
ALTER INDEX if exists flow.pcz_company_timezone_id_ix RENAME TO rr_company_timezone_id_ix;

ALTER TABLE flow.round_robin_audit
    RENAME COLUMN zone_name TO round_robin_name;
ALTER TABLE flow.round_robin_audit
    RENAME COLUMN postal_code_zone_id TO round_robin_id;
ALTER TABLE flow.round_robin_audit RENAME CONSTRAINT postal_code_zone_audit_pk TO round_robin_audit_pk;
ALTER INDEX if exists flow.pcza_postal_code_zone_id_idx RENAME TO rr_round_robin_id_idx;

ALTER TABLE flow.round_robin_user_type RENAME CONSTRAINT flow_postal_code_zone_user_type_pk TO round_robin_user_type_pk;

ALTER TABLE flow.round_robin_user
    RENAME COLUMN postal_code_zone_id TO round_robin_id;
ALTER TABLE flow.round_robin_user
    RENAME COLUMN postal_code_zone_user_type_id TO round_robin_user_type_id;
ALTER TABLE flow.round_robin_user RENAME CONSTRAINT postal_code_zone_user_pk TO round_robin_user_pk;
ALTER INDEX if exists flow.pczu_company_timezone_id_ix RENAME TO rru_company_timezone_id_ix;
ALTER INDEX if exists flow.pczu_postal_code_zone_id_ix RENAME TO rru_round_robin_id_ix;
ALTER INDEX if exists flow.pczu_postal_code_zone_user_type_id_ix RENAME TO rru_round_robin_user_type_id_ix;
ALTER INDEX if exists flow.pczu_uniq_idx RENAME TO rru_uniq_idx;
ALTER INDEX if exists flow.pczu_user_id_ix RENAME TO rru_user_id_ix;

ALTER TABLE flow.round_robin_user_audit RENAME COLUMN postal_code_zone_id TO round_robin_id;
ALTER TABLE flow.round_robin_user_audit RENAME COLUMN postal_code_zone_user_id TO round_robin_user_id;
ALTER TABLE flow.round_robin_user_audit RENAME COLUMN postal_code_zone_user_type_id TO round_robin_user_type_id;
ALTER TABLE flow.round_robin_user_audit RENAME CONSTRAINT postal_code_zone_user_audit_pk TO round_robin_user_audit_pk;
ALTER INDEX if exists flow.pczua_postal_code_zone_id_idx RENAME TO rrua_round_robin_id_idx;
ALTER INDEX if exists flow.pczua_postal_code_zone_user_id_idx RENAME TO rrua_round_robin_user_id_idx;

alter table flow.postal_code
add column if not exists round_robin_id bigint references flow.round_robin(id);
CREATE INDEX if not exists pc_round_robin_id_idx ON flow.postal_code (round_robin_id);

--ADD THE MISSING POSTAL CODES THEY HAD MANUALLY ADDED
insert into flow.postal_code(country_code, postal_code, place_name, admin_name1, admin_code1, admin_name2, admin_code2, admin_name3, admin_code3, latitude, longitude, accuracy, round_robin_id)
select 'US', pc.postal_code, 'MIGRATED - PLS NAME', 'MIGRATED', 'MIGRATED', 'MIGRATED', NULL, NULL, NULL, NULL, NULL, NULL, NULL
from flow.postal_code_zone_postal_code pc
where not exists(select p.id
                 from flow.postal_code p
                 where p.postal_code = pc.postal_code);

--UPDATE THE POSTAL CODE TABLE TO POINT TO THE ROUND ROBIN TABLE
update flow.postal_code pc
set round_robin_id = ( select postal_code_zone_id
                       from flow.postal_code_zone_postal_code pczpc
                       where pczpc.postal_code = pc.postal_code
                       and pczpc.archived is false);

--DROP THE POSTAL_CODE_ZONE_POSTAL_CODE TABLE...BUT RENAMING IT FOR NOW IN CASE I NEED IT AGAIN
-- a new table with the same name will be added later but will serve a different purpose
ALTER TABLE IF EXISTS flow.postal_code_zone_postal_code
    RENAME TO deprecated_postal_code_zone_postal_code;

--DO THE METRO AREA STUFF
alter table flow.postal_code
    add column if not exists metro_area_id bigint references flow.list_of_value(id);
CREATE INDEX if not exists pc_metro_area_id_idx ON flow.postal_code (metro_area_id);

update flow.postal_code pc
set metro_area_id = ( select mapc.metro_area_id
                       from brs.metro_area_postal_code mapc
                       where mapc.postal_code = pc.postal_code);

--DROP THE BRS.metro_area_postal_code TABLE...BUT RENAMING IT FOR NOW IN CASE I NEED IT AGAIN
ALTER TABLE IF EXISTS flow.metro_area_postal_code
    RENAME TO deprecated_metro_area_postal_code;

--add archived for postal code
alter table flow.postal_code
    add column if not exists archived boolean not null default false;
alter table flow.postal_code
    add column if not exists modified_by_id bigint references flow.user(id);

--drop old functions
drop function if exists brs.get_allocation_by_zone( bigint,  bigint);

--drop some audit stuffs
drop function if exists flow.concrete_postal_code_zone_audit() cascade;
drop trigger if exists concrete_postal_code_zone_audit_trg ON flow.round_robin;
drop function if exists flow.concrete_postal_code_zone_user_audit() cascade;
drop trigger if exists concrete_postal_code_zone_user_audit_trg ON flow.round_robin_user;

--add postal code notes
alter table flow.postal_code
    add column if not exists notes text;

--set postal codes as active or not
alter table flow.postal_code
    add column if not exists active boolean not null default false;

update flow.postal_code pc
    set active = true
where exists (
    select id
    from flow.deprecated_postal_code_zone_postal_code d
    where pc.postal_code = d.postal_code
    and d.archived is false
);

--add postal code disqualified stuff
alter table flow.postal_code
    add column if not exists disqualified boolean not null default false;

--uniq constraint for postal code
delete from flow.postal_code
    where place_name = 'FPO AA'
    and postal_code in ('96860','96863');
ALTER TABLE flow.postal_code
    ADD CONSTRAINT pc_postal_code_uk UNIQUE (postal_code);

--POSTAL CODE ZONES
drop TABLE if exists flow.postal_code_zone;
CREATE TABLE if not exists flow.postal_code_zone
(
    id             bigserial NOT NULL,
    zone_name      varchar(255),
    metro_area_id  bigint    NOT NULL,
    company_id     bigint    NOT NULL,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified  timestamp without time zone DEFAULT now(),
    created_by_id  integer   not null,
    modified_by_id integer,
    archived       boolean   not null          default false,
    CONSTRAINT flow_postal_code_zone_pk PRIMARY KEY (id),
    CONSTRAINT flow_pcz_metro_area_id_fk FOREIGN KEY (metro_area_id)
        REFERENCES flow.list_of_value (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pcz_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pcz_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_pcz_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists pcz_company_id_idx ON flow.postal_code_zone (company_id);
CREATE INDEX if not exists pcz_created_by_id_idx ON flow.postal_code_zone (created_by_id);
CREATE INDEX if not exists pcz_modified_by_id_idx ON flow.postal_code_zone (modified_by_id);
CREATE INDEX if not exists pcz_metro_area_id_idx ON flow.postal_code_zone (metro_area_id);

-- POSTAL_CODE PERMISSIONS
insert into flow.feature(feature_name, feature_code)
select 'Postal Code', 'POSTAL_CODE'
where not exists (select id from flow.feature where feature_code = 'POSTAL_CODE');

--this default was missing?
ALTER TABLE flow.company_feature ALTER COLUMN home_page SET DEFAULT false;

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Postal Code', 3, (select id from flow.feature where feature_code = 'POSTAL_CODE')
where not exists (select id from flow.company_feature where feature_name = 'Postal Code' and company_id = 3);
;

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
select (select id from flow.feature where feature_code = 'POSTAL_CODE'), ac.id, 2417170
from flow.access_control ac
where ac.id in (1,2,3,4)
  and not exists (
    select id from flow.feature_access_control
    where feature_id = (select id from flow.feature where feature_code = 'POSTAL_CODE')
      and access_control_id = ac.id
);


--postal code zone postal code stuff
CREATE TABLE if not exists flow.postal_code_zone_postal_code
(
    id             bigserial NOT NULL,
    postal_code_zone_id     bigint not null,
    postal_code_id   bigint not null,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified  timestamp without time zone DEFAULT now(),
    created_by_id  integer   not null,
    modified_by_id integer,
    archived       boolean   not null          default false,
    CONSTRAINT flow_postal_code_zone_postal_code_pk PRIMARY KEY (id),
    CONSTRAINT flow_pczpc_zone_id_fk FOREIGN KEY (postal_code_zone_id)
        REFERENCES flow.postal_code_zone (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pczpc_postal_code_id_fk FOREIGN KEY (postal_code_id)
        REFERENCES flow.postal_code (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pczpc_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_pczpc_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists pczpc_postal_code_zone_id_idx ON flow.postal_code_zone_postal_code (postal_code_zone_id);
CREATE INDEX if not exists pczpc_postal_code_id_idx ON flow.postal_code_zone_postal_code (postal_code_id);
