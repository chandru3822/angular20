

create table if not exists flow.user_positions_vw
(
    user_id                      integer,
    first_name                   character varying(100),
    last_name                    character varying(100),
    org_id                       integer,
    org_name                     character varying(100),
    org_level_id                 integer,
    position_level               integer,
    primary_flag                 boolean,
    start_date                   date,
    end_date                     date,
    archived                     boolean,
    state_id                     integer,
    user_archived                boolean,
    position_schedulable         boolean,
    position                     character varying(100),
    position_id                  integer,
    user_position_id             integer,
    company_id                   integer,
    email                        character varying(100),
    phone_number                 character varying(100),
    available_to_children        boolean,
    company_user_status_type_id  integer,
    has_access                   boolean
);

CREATE INDEX upv_user_position_id_idx
    ON flow.user_positions_vw (user_position_id);

CREATE INDEX upv_user_id_idx
    ON flow.user_positions_vw (user_id);

CREATE INDEX upv_position_id_idx
    ON flow.user_positions_vw (position_id);

CREATE INDEX upv_company_id_idx
    ON flow.user_positions_vw (company_id);

CREATE INDEX upv_start_date_idx
    ON flow.user_positions_vw (start_date);

CREATE INDEX upv_end_date_idx
    ON flow.user_positions_vw (end_date);


create table if not exists flow.user_position_hierarchy_vw
(
    user_id                      integer,
    org_id                       integer,
    user_position_id             integer,
    position_id                  integer,
    hierarchy                    jsonb
);

CREATE INDEX uphv_user_position_id_idx
    ON flow.user_position_hierarchy_vw (user_position_id);

CREATE INDEX uphv_user_id_idx
    ON flow.user_position_hierarchy_vw (user_id);

CREATE INDEX uphv_position_id_idx
    ON flow.user_position_hierarchy_vw (position_id);

CREATE INDEX uphv_org_id_idx
    ON flow.user_position_hierarchy_vw (org_id);


insert into flow.user_position_hierarchy_vw
select * from flow.user_position_hierarchy_materialized_vw;


