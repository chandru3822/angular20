-- drop table if exists flow.object_category cascade;
-- drop table if exists flow.object_category_company_project_status_type cascade;
-- drop table if exists flow.object_category_attachment_type cascade;

CREATE TABLE if not exists flow.object_category
(
    id                   bigserial,
    object_category      CHARACTER VARYING(100)                    not null,
    object_category_code CHARACTER VARYING(50)                     not null,
    object_type_id       bigint                                    not null,
    date_created         timestamp without time zone DEFAULT now() not null,
    date_modified        timestamp without time zone DEFAULT now() not null,
    created_by_id        integer,
    modified_by_id       integer,
    archived             boolean                                   not null default false,
    CONSTRAINT object_category_pk PRIMARY KEY (id),
    CONSTRAINT oc_object_type_id_id_fk FOREIGN KEY (object_type_id)
        REFERENCES flow.object_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

insert into flow.object_category(object_category, object_category_code, date_created, date_modified, created_by_id,
                                 modified_by_id, archived, object_type_id)
    (select 'Residential Standard',
            'RESIDENTIAL_STANDARD',
            now(),
            now(),
            2384850,
            2384850,
            false,
            1
     where not exists (select id from flow.object_category oc where oc.object_category_code = 'RESIDENTIAL_STANDARD'));

insert into flow.object_category(object_category, object_category_code, date_created, date_modified, created_by_id,
                                 modified_by_id, archived, object_type_id)
    (select 'Retrofit',
            'RETROFIT',
            now(),
            now(),
            2384850,
            2384850,
            false,
            1
     where not exists (select id from flow.object_category oc where oc.object_category_code = 'RETROFIT'));

insert into flow.object_category(object_category, object_category_code, date_created, date_modified, created_by_id,
                                 modified_by_id, archived, object_type_id)
    (select 'Battery Only',
            'BATTERY_ONLY',
            now(),
            now(),
            2384850,
            2384850,
            false,
            1
     where not exists (select id from flow.object_category oc where oc.object_category_code = 'BATTERY_ONLY'));

insert into flow.object_category(object_category, object_category_code, date_created, date_modified, created_by_id,
                                 modified_by_id, archived, object_type_id)
    (select 'Removal and Reinstallation',
            'REMOVAL_REINSTALLATION',
            now(),
            now(),
            2384850,
            2384850,
            false,
            1
     where not exists (select id
                       from flow.object_category oc
                       where oc.object_category_code = 'REMOVAL_REINSTALLATION'));
insert into flow.object_category(object_category, object_category_code, date_created, date_modified, created_by_id,
                                 modified_by_id, archived, object_type_id)
    (select 'Community',
            'COMMUNITY',
            now(),
            now(),
            2384850,
            2384850,
            false,
            1
     where not exists (select id from flow.object_category oc where oc.object_category_code = 'COMMUNITY'));

insert into flow.object_category(object_category, object_category_code, date_created, date_modified, created_by_id,
                                 modified_by_id, archived, object_type_id)
    (select 'New Home',
            'NEW_HOME',
            now(),
            now(),
            2384850,
            2384850,
            false,
            1
     where not exists (select id from flow.object_category oc where oc.object_category_code = 'NEW_HOME'));


insert into flow.object_category(object_category, object_category_code, date_created, date_modified, created_by_id,
                                 modified_by_id, archived, object_type_id)
    (select 'Builder (new homes builder)',
            'BUILDER_NEW_HOMES_BUILDER',
            now(),
            now(),
            2384850,
            2384850,
            false,
            2
     where not exists (select id
                       from flow.object_category oc
                       where oc.object_category_code = 'BUILDER_NEW_HOMES_BUILDER'));

insert into flow.object_category(object_category, object_category_code, date_created, date_modified, created_by_id,
                                 modified_by_id, archived, object_type_id)
    (select 'Primary Homeowner (Homeowner who is purchasing solar)',
            'PRIMARY_HOMEOWNER',
            now(),
            now(),
            2384850,
            2384850,
            false,
            2
     where not exists (select id from flow.object_category oc where oc.object_category_code = 'PRIMARY_HOMEOWNER'));

insert into flow.object_category(object_category, object_category_code, date_created, date_modified, created_by_id,
                                 modified_by_id, archived, object_type_id)
    (select 'Secondary Homeowner (spouse or co-owner of home,may also be a co-borrower)',
            'SECONDARY_HOMEOWNER',
            now(),
            now(),
            2384850,
            2384850,
            false,
            2
     where not exists (select id from flow.object_category oc where oc.object_category_code = 'SECONDARY_HOMEOWNER'));

insert into flow.object_category(object_category, object_category_code, date_created, date_modified, created_by_id,
                                 modified_by_id, archived, object_type_id)
    (select 'New Homeowner (someone who buys a home with a BRS system and may or may not assume the loan',
            'NEW_HOMEOWNER',
            now(),
            now(),
            2384850,
            2384850,
            false,
            2
     where not exists (select id from flow.object_category oc where oc.object_category_code = 'NEW_HOMEOWNER'));


alter table flow.process
    add column if not exists object_category_id bigint;

alter table flow.process
    add CONSTRAINT process_object_category_id_fk
        FOREIGN KEY (object_category_id)
            REFERENCES flow.object_category (id) MATCH SIMPLE
            ON UPDATE NO ACTION ON DELETE NO ACTION;

update flow.process
set object_category_id = (select id from flow.object_category where object_category_code = 'RESIDENTIAL_STANDARD')
where id = 1;

update flow.process
set object_category_id = (select id from flow.object_category where object_category_code = 'RETROFIT')
where id = 18;

update flow.process
set object_category_id = (select id from flow.object_category where object_category_code = 'BATTERY_ONLY')
where id = 20;

update flow.process
set object_category_id = (select id from flow.object_category where object_category_code = 'REMOVAL_REINSTALLATION')
where id = 23;

-- update flow.process
-- set object_category_id = (select id from flow.object_category where object_category_code = 'REMOVAL_REINSTALLATION')
-- where id = 21;

alter table flow.project
    add column if not exists object_category_id bigint;

-- DO
--$do$
  --  declare
    --    x             record;
    --    v_count       bigint = 0;
    --     v_total_count bigint = 0;
--
  --   BEGIN
--
    --    SET session_replication_role = replica;
    --    for x in select p2.object_category_id, p.id
    --             from flow.project p
      --                    inner join flow.company_process cp on cp.id = p.company_process_id
      --                    inner join flow.process p2 on p2.id = cp.process_id
    --             where cp.company_id = 3
--                    and p.archived is false
    --               and p.object_category_id is null
      --       loop
--
        --        v_count = v_count + 1;
        --        v_total_count = v_total_count + 1;
        --        update flow.project p2
        --        set object_category_id = x.object_category_id
        --         where id = x.id;
--
        --        if v_count = 5000 then
          --          commit;
          --          v_count = 0;
          --          raise notice 'v_total_count = %',v_total_count;
        --         end if;
--
      --      end loop;
-- update flow.project p
-- set object_category_id =1
-- where object_category_id is null;
    --    SET session_replication_role = default;
  --   end
-- $do$;

-- ALTER TABLE flow.project
--     ALTER COLUMN object_category_id SET NOT NULL;

alter table flow.project
    drop constraint if exists c_project_object_category_id_fk;
alter table flow.project
    add CONSTRAINT c_project_object_category_id_fk
        FOREIGN KEY (object_category_id)
            REFERENCES flow.object_category (id) MATCH SIMPLE
            ON UPDATE NO ACTION ON DELETE NO ACTION;

CREATE INDEX if not exists project_object_category_id_idx ON flow.project (object_category_id);

alter table flow.contact
    add column if not exists object_category_id bigint;

-- DO
--$do$
  --  declare
    --    x             record;
    --    v_count       bigint = 0;
    --    v_total_count bigint = 0;
    --    v_id          bigint;
  --  BEGIN
    --    select id
    --    into v_id
    --    from flow.object_category oc
    --     where oc.object_category_code = 'PRIMARY_HOMEOWNER';
--
    --    for x in select id
    --             from flow.contact c
    --             where object_category_id is null
      --      loop
        --        SET session_replication_role = replica;
        --        v_count = v_count + 1;
        --        v_total_count = v_total_count + 1;
        --        update flow.contact
        --        set object_category_id = v_id
        --         where id = x.id;
--
        --        if v_count = 5000 then
          --          commit;
          --          v_count = 0;
          --          raise notice 'v_total_count = %',v_total_count;
        --         end if;
--
      --      end loop;
    --    SET session_replication_role = default;
  --   end
-- $do$;

-- ALTER TABLE flow.contact
--     ALTER COLUMN object_category_id SET NOT NULL;

alter table flow.contact
    drop constraint if exists c_contact_object_category_id_fk;
alter table flow.contact
    add CONSTRAINT c_contact_object_category_id_fk
        FOREIGN KEY (object_category_id)
            REFERENCES flow.object_category (id) MATCH SIMPLE
            ON UPDATE NO ACTION ON DELETE NO ACTION;

CREATE INDEX if not exists contact_object_category_id_idx ON flow.contact (object_category_id);

CREATE TABLE if not exists flow.contact_project_group
(
    id             bigserial,
    project_id     bigint                                    not null,
    contact_id     bigint                                    not null,
    date_created   timestamp without time zone DEFAULT now() not null,
    date_modified  timestamp without time zone DEFAULT now() not null,
    created_by_id  integer,
    modified_by_id integer,
    archived       boolean                                   not null default false,
    CONSTRAINT contact_project_group_pk PRIMARY KEY (id),
    CONSTRAINT c_contact_project_group_project_id_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT c_contact_project_group_contact_id_id_fk FOREIGN KEY (contact_id)
        REFERENCES flow.contact (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists contact_project_group_project_id_idx ON flow.contact_project_group (project_id);
CREATE INDEX if not exists contact_project_group_contact_id_idx ON flow.contact_project_group (contact_id);


CREATE TABLE if not exists flow.object_category_custom_field_group
(
    id                    bigserial,
    object_category_id    bigint                                    not null,
    custom_field_group_id bigint                                    not null,
    date_created          timestamp without time zone DEFAULT now() not null,
    date_modified         timestamp without time zone DEFAULT now() not null,
    created_by_id         integer,
    modified_by_id        integer,
    archived              boolean                                   not null default false,
    CONSTRAINT object_category_custom_field_group_pk PRIMARY KEY (id),
    CONSTRAINT occfg_object_category_id_fk FOREIGN KEY (object_category_id)
        REFERENCES flow.object_category (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT occfg_custom_field_group_id_id_fk FOREIGN KEY (custom_field_group_id)
        REFERENCES flow.custom_field_group (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE unique INDEX if not exists occfg_object_category_id_custom_field_group_id_idx ON flow.object_category_custom_field_group (object_category_id, custom_field_group_id);


insert into flow.object_category_custom_field_group(object_category_id, custom_field_group_id, created_by_id,
                                                    modified_by_id)
    (select oc.id, cfg.id, 2384850, 2384850
     from flow.custom_field_group cfg
              cross join flow.object_category as oc
     where cfg.company_object_type_id = 1
       and cfg.archived is false
       and oc.object_type_id = 1
       and oc.object_category_code in ('REMOVAL_REINSTALLATION', 'BATTERY_ONLY', 'RETROFIT', 'RESIDENTIAL_STANDARD'))
on conflict do nothing;


CREATE TABLE if not exists flow.object_category_attachment_type
(
    id                 bigserial,
    object_category_id bigint                                    not null,
    attachment_type_id bigint                                    not null,
    date_created       timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone DEFAULT now() not null,
    created_by_id      integer,
    modified_by_id     integer,
    archived           boolean                                   not null default false,
    CONSTRAINT object_category_attachment_type_pk PRIMARY KEY (id),
    CONSTRAINT ocat_object_category_id_fk FOREIGN KEY (object_category_id)
        REFERENCES flow.object_category (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ocat_attachment_type_id_fk FOREIGN KEY (attachment_type_id)
        REFERENCES flow.attachment_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE unique INDEX if not exists ocat_object_category_attachment_type_idx ON flow.object_category_attachment_type (object_category_id, attachment_type_id);

insert into flow.object_category_attachment_type(object_category_id, attachment_type_id, created_by_id, modified_by_id)
    (select oc.id, at2.id, 2384850, 2384850
     from flow.attachment_type at2
              cross join flow.object_category as oc
     where at2.company_id = 3
       and at2.archived is false
       and oc.object_type_id = 1
       and oc.object_category_code in ('REMOVAL_REINSTALLATION', 'BATTERY_ONLY', 'RETROFIT', 'RESIDENTIAL_STANDARD'))
on conflict do nothing;


CREATE TABLE if not exists flow.object_category_company_project_status_type
(
    id                             bigserial,
    object_category_id             bigint                                    not null,
    company_project_status_type_id bigint                                    not null,
    date_created                   timestamp without time zone DEFAULT now() not null,
    date_modified                  timestamp without time zone DEFAULT now() not null,
    created_by_id                  integer,
    modified_by_id                 integer,
    archived                       boolean                                   not null default false,
    CONSTRAINT occpst_pk PRIMARY KEY (id),
    CONSTRAINT occpst_object_category_id_fk FOREIGN KEY (object_category_id)
        REFERENCES flow.object_category (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT occpst_company_project_status_type_id_fk FOREIGN KEY (company_project_status_type_id)
        REFERENCES flow.company_project_status_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE unique INDEX if not exists occpst_object_category_id_project_status_type_id_idx ON flow.object_category_company_project_status_type (object_category_id, company_project_status_type_id);

insert into flow.object_category_company_project_status_type(object_category_id, company_project_status_type_id,
                                                             created_by_id, modified_by_id)
    (select oc.id, cpst.id, 2384850, 2384850
     from flow.company_project_status_type as cpst
              cross join flow.object_category as oc
     where cpst.company_id = 3
       and cpst.archived is false
       and oc.object_type_id = 1
       and oc.object_category_code in ('REMOVAL_REINSTALLATION', 'BATTERY_ONLY', 'RETROFIT', 'RESIDENTIAL_STANDARD','NEW_HOME', 'BUILDER_NEW_HOMES_BUILDER'))
on conflict do nothing;


--proposal template object categories
create table if not exists brs.object_category_proposal_template
(
    object_category_id   bigint                                    not null references flow.object_category (id),
    proposal_template_id bigint                                    not null references brs.proposal_template (id),
    date_created         timestamp without time zone DEFAULT now() not null,
    created_by_id        integer references flow."user" (id),

    primary key (object_category_id, proposal_template_id)
);
CREATE INDEX if not exists ocpt_proposal_template_id_ix on brs.object_category_proposal_template (proposal_template_id);

insert into brs.object_category_proposal_template (object_category_id, proposal_template_id)
select oc.id, pt.id
from brs.proposal_template pt
         cross join flow.object_category oc
on conflict do nothing;


alter table flow.project add column  if not exists parent_id bigint;

alter table flow.project
  drop constraint if exists p_parent_id_fk;
alter table flow.project
  add CONSTRAINT p_parent_id_fk
    FOREIGN KEY (parent_id)
      REFERENCES flow.project (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

CREATE INDEX if not exists project_parent_id_idx ON flow.project (parent_id);

alter table flow.object_category add column if not exists is_default boolean not null default false;

update flow.object_category oc
set is_default = true
where object_category_code = 'RESIDENTIAL_STANDARD';

update flow.object_category oc
set is_default = true
where object_category_code = 'PRIMARY_HOMEOWNER';

CREATE UNIQUE INDEX if not exists unique_default_object_type_idx
  ON flow.object_category (object_type_id)
  WHERE is_default is TRUE AND archived is FALSE;











-- AHJ - NEW HOME STUFF
drop table if exists brs.feat_db_ahj_new_home;
create table if not exists brs.feat_db_ahj_new_home
(
    id             bigserial not null
        constraint ahj_new_home_pkey
            primary key,
    ahj_id         bigint                                                           not null
        constraint ahj_new_home_ahj_id_key
            unique
        constraint ahj_new_home_ahj_id_fkey
            references brs.feat_db_ahj,
    archived       boolean   default false                                          not null,
    date_created   timestamp,
    created_by_id  bigint
        constraint ahj_new_home_created_by_id_fkey
            references flow."user",
    date_modified  timestamp default now(),
    modified_by_id bigint
        constraint ahj_new_home_modified_by_id_fkey
            references flow."user"
);

drop table if exists brs.feat_db_ahj_new_home_contact;
create table if not exists brs.feat_db_ahj_new_home_contact
(
    ahj_new_home_id bigint                                 not null
        constraint ahj_new_home_contact_ahj_new_home_id_fkey
            references brs.feat_db_ahj_new_home
        constraint anhc1_ahj_new_home_id_fk
            references brs.feat_db_ahj_new_home,
    ahj_contact_id    bigint                                 not null
        constraint ahj_new_home_contact_ahj_contact_id_fkey
            references brs.feat_db_contact
        constraint anhc_ahj_contact_id_fk
            references brs.feat_db_contact,
    date_modified     timestamp with time zone default now() not null,
    constraint ahj_new_home_contact_ahj_new_home_id_ahj_contact_id_key
        primary key (ahj_new_home_id, ahj_contact_id)
);

create index ahj_new_home_contact_ahj_contact_id_idx
    on brs.feat_db_ahj_new_home_contact (ahj_contact_id);


drop table if exists brs.feat_db_ahj_new_home_custom_field_value;
create table if not exists brs.feat_db_ahj_new_home_custom_field_value
(
    id                               bigserial not null
        constraint brs_ahj_new_home_custom_field_value_pk
            primary key,
    ahj_new_home_id                bigint                                                                              not null
        constraint brs_anhcfv_ahj_new_home_id_fk
            references brs.feat_db_ahj_new_home,
    date_value                       date,
    custom_field_group_assignment_id bigint                                                                              not null
        constraint brs_anhcfv_custom_field_id_fk
            references brs.custom_field_group_assignment,
    timestamp_value                  timestamp,
    boolean_value                    boolean,
    text_value                       text,
    numeric_value                    numeric,
    int_value                        bigint,
    int_array_value                  bigint[],
    date_created                     timestamp default now(),
    date_modified                    timestamp default now(),
    created_by_id                    bigint                                                                              not null
        constraint brs_anhcfv_created_by_id_fk
            references flow."user",
    modified_by_id                   bigint
        constraint brs_anhcfv_modified_by_id_fk
            references flow."user",
    rich_text_value                  text,
    constraint anhcfv_ahj_new_home_id_cfga_id
        unique (ahj_new_home_id, custom_field_group_assignment_id)
);

create index fki_anhcfv_ahj_new_home_id
    on brs.feat_db_ahj_new_home_custom_field_value (ahj_new_home_id);
create index fki_anhcfv_custom_field_group_assignment_id
    on brs.feat_db_ahj_new_home_custom_field_value (custom_field_group_assignment_id);

drop table if exists brs.feat_db_ahj_new_home_custom_field_value_audit;
create table if not exists brs.feat_db_ahj_new_home_custom_field_value_audit
(
    id                                   bigserial not null
        constraint ahj_new_home_custom_field_value_audit_pk
            primary key,
    ahj_new_home_custom_field_value_id bigint                                                                                 not null,
    old_value                            text,
    new_value                            text,
    date_modified                        timestamp,
    modified_by_id                       bigint
        constraint ahj_nhcfva_modified_by_id_fk
            references flow."user"
);

create index anhcfva_ahj_new_home_custom_field_value_id_idx
    on brs.feat_db_ahj_new_home_custom_field_value_audit (ahj_new_home_custom_field_value_id);

drop table if exists brs.feat_db_ahj_new_home_link;
create table if not exists brs.feat_db_ahj_new_home_link
(
    id                bigserial not null
        constraint ahj_new_home_link_pkey
            primary key,
    ahj_new_home_id bigint                                                                not null
        constraint ahj_new_home_link_ahj_new_home_id_fkey
            references brs.feat_db_ahj_new_home,
    name              varchar(100)                                                          not null,
    link              varchar(255)                                                          not null,
    username          varchar(255),
    password          varchar(255),
    notes             text,
    archived          boolean   default false                                               not null,
    date_created      timestamp,
    created_by_id     bigint
        constraint ahj_new_home_link_created_by_id_fkey
            references flow."user",
    date_modified     timestamp default now(),
    modified_by_id    bigint
        constraint ahj_new_home_link_modified_by_id_fkey
            references flow."user",
    link_type_id      bigint
        constraint ahj_new_home_link_link_type_id_fkey
            references brs.feat_db_link_type
);

create index ahj_new_home_link_ahj_new_home_id_idx
    on brs.feat_db_ahj_new_home_link (ahj_new_home_id);

create index ahj_new_home_link_link_type_id_idx
    on brs.feat_db_ahj_new_home_link (link_type_id);

--I already inserted the object type in prod so that I could ensure the ID didn't change
--I didn't want them to see it though, so just need to unarchive it in the release
update brs.object_type
set archived = false
where object_code = 'AHJ_NEW_HOME';

alter table flow.company_process
    add column if not exists allow_contact_initiate boolean not null default false;

--todo @randa @keller @kaleb - we will need to verify that 27 is the "lot" process
update flow.company_process
set allow_contact_initiate = true
where process_id != 27;

CREATE TABLE if not exists flow.company_process_child_company_process
(
    id             bigserial NOT NULL,
    company_process_id bigint not null,
    child_company_process_id bigint not null,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified  timestamp without time zone DEFAULT now(),
    created_by_id  integer   not null,
    modified_by_id integer,
    archived       boolean   not null          default false,
    CONSTRAINT flow_company_process_child_process_pk PRIMARY KEY (id),
    CONSTRAINT flow_cpccp_company_process_id_fk FOREIGN KEY (company_process_id)
        REFERENCES flow.company_process (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_cpccp_child_company_process_id_fk FOREIGN KEY (child_company_process_id)
        REFERENCES flow.company_process (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_cpccp_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_cpccp_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cpccp_company_process_id_idx ON flow.company_process_child_company_process (company_process_id);
CREATE INDEX if not exists cpccp_child_company_process_id_idx ON flow.company_process_child_company_process (child_company_process_id);

--todo @randa @keller @kaleb - we will need to verify that 26 is the "community" process
insert into flow.company_process_child_company_process(company_process_id, child_company_process_id, created_by_id)
select 26, (select id from flow.company_process where allow_contact_initiate is false and archived is false limit 1), 2417170;



alter table flow.contact add column  if not exists nw_migration_id   VARCHAR(18);
CREATE INDEX if not exists c_nw_account_id_idx ON flow.contact (nw_migration_id);

alter table flow.project add column  if not exists nw_migration_id   VARCHAR(18);
CREATE INDEX if not exists c_nw_project_idx ON flow.project (nw_migration_id);

CREATE INDEX if not exists lov_name_idx ON flow.list_of_value (name);
