-- drop table brs.tournament_owner_type;
-- drop table brs.tournament_formula;
-- drop table brs.tournament;
-- drop table brs.tournament_bracket;
-- drop table brs.tournament_round;
-- drop table brs.tournament_match;
-- drop table brs.tournament_pool_type;
-- drop table brs.tournament_pool;
-- drop table brs.tournament_pool_user;
-- drop table brs.tournament_pool_position;
-- drop table brs.tournament_seed_position;

CREATE TABLE if not exists brs.tournament_owner_type
(
    id             serial      NOT NULL,
    owner_type     varchar(25) NOT NULL,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified  timestamp without time zone,
    created_by_id  integer     not null,
    modified_by_id integer,
    archived       boolean     not null        default false,
    CONSTRAINT brs_tournament_owner_type_pk PRIMARY KEY (id),
    CONSTRAINT brs_totp_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_totp_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

insert into brs.tournament_owner_type(owner_type, created_by_id)
values ('Project', 2350555),
       ('Contact', 2350555);

CREATE TABLE if not exists brs.tournament_formula
(
    id                       serial            NOT NULL,
    formula_title            character varying NOT NULL,
    formula_description      text,
    tournament_owner_type_id integer           NOT NULL,
    date_created             timestamp without time zone DEFAULT now(),
    date_modified            timestamp without time zone,
    created_by_id            integer           not null,
    modified_by_id           integer,
    active                   boolean           not null  default false,
    archived                 boolean           not null  default false,
    CONSTRAINT brs_tournament_formula_pk PRIMARY KEY (id),
    CONSTRAINT brs_tf_tournament_owner_type_id_fk FOREIGN KEY (tournament_owner_type_id)
        REFERENCES brs.tournament_owner_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_tf_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_tf_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

insert into brs.tournament_formula(formula_title, formula_description, tournament_owner_type_id, created_by_id)
values ('Standard Closer Scoring', 'The standard scoring formula for closers', 1, 2417170);

CREATE TABLE if not exists brs.tournament
(
    id                       serial            NOT NULL,
    tournament_name          character varying NOT NULL,
    tournament_owner_type_id integer           NOT NULL,
    tournament_formula_id    integer           NOT NULL,
    start_date               date,
    end_date                 date,
    date_created             timestamp without time zone DEFAULT now(),
    date_modified            timestamp without time zone,
    created_by_id            integer           not null,
    modified_by_id           integer,
    active                   boolean           not null  default false,
    archived                 boolean           not null  default false,
    CONSTRAINT brs_tournament_pk PRIMARY KEY (id),
    CONSTRAINT brs_t_tournament_owner_type_id_fk FOREIGN KEY (tournament_owner_type_id)
        REFERENCES brs.tournament_owner_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_t_tournament_formula_id_fk FOREIGN KEY (tournament_formula_id)
        REFERENCES brs.tournament_formula (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_t_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_t_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.tournament_bracket
(
    id                serial  NOT NULL,
    tournament_id     integer NOT NULL,
    number_of_users   integer not null,
    matches_generated boolean not null            default false,
    date_created      timestamp without time zone DEFAULT now(),
    date_modified     timestamp without time zone,
    created_by_id     integer not null,
    modified_by_id    integer,
    archived          boolean not null            default false,
    CONSTRAINT brs_tournament_bracket_pk PRIMARY KEY (id),
    CONSTRAINT brs_tr_tournament_id_fk FOREIGN KEY (tournament_id)
        REFERENCES brs.tournament (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_tb_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_tb_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.tournament_round
(
    id                    serial  NOT NULL,
    tournament_bracket_id integer NOT NULL,
    start_date            date,
    end_date              date,
    date_created          timestamp without time zone DEFAULT now(),
    date_modified         timestamp without time zone,
    created_by_id         integer not null,
    modified_by_id        integer,
    advanced              boolean not null            default false,
    archived              boolean not null            default false,
    CONSTRAINT brs_tournament_round_pk PRIMARY KEY (id),
    CONSTRAINT brs_tr_tournament_bracket_id_fk FOREIGN KEY (tournament_bracket_id)
        REFERENCES brs.tournament_bracket (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_tr_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_tr_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);



CREATE TABLE if not exists brs.tournament_match
(
    id                  serial  NOT NULL,
    tournament_round_id integer NOT NULL,
    parent_match_id     integer,
    user_1_id           integer,
    user_2_id           integer,
    user_1_score        integer,
    user_2_score        integer,
    date_created        timestamp without time zone DEFAULT now(),
    date_modified       timestamp without time zone,
    created_by_id       integer not null,
    modified_by_id      integer,
    match_advanced      boolean not null            default false,
    archived            boolean not null            default false,
    CONSTRAINT brs_tournament_match_pk PRIMARY KEY (id),
    CONSTRAINT brs_tm_parent_match_id_fk FOREIGN KEY (parent_match_id)
        REFERENCES brs.tournament_match (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_tm_tournament_round_id_fk FOREIGN KEY (tournament_round_id)
        REFERENCES brs.tournament_round (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_tm_user_1_id_fk FOREIGN KEY (user_1_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_tm_user_2_id_fk FOREIGN KEY (user_2_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_tm_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_tm_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.tournament_pool_type
(
    id             serial      NOT NULL,
    pool_type      varchar(25) NOT NULL,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified  timestamp without time zone,
    created_by_id  integer     not null,
    modified_by_id integer,
    archived       boolean     not null        default false,
    CONSTRAINT brs_tournament_pool_type_pk PRIMARY KEY (id),
    CONSTRAINT brs_tpt_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_tpt_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

insert into brs.tournament_pool_type(pool_type, created_by_id)
values ('Qualifying', 2350555),
       ('Last Chance', 2350555),
       ('Winner', 2350555);

CREATE TABLE if not exists brs.tournament_pool
(
    id                      serial  NOT NULL,
    custom_name             varchar(255),
    tournament_id           integer NOT NULL,
    tournament_pool_type_id integer NOT NULL,
    start_date              date,
    end_date                date,
    advanced                boolean not null            default false,
    date_created            timestamp without time zone DEFAULT now(),
    date_modified           timestamp without time zone,
    created_by_id           integer not null,
    modified_by_id          integer,
    archived                boolean not null            default false,
    CONSTRAINT brs_tournament_pool_pk PRIMARY KEY (id),
    CONSTRAINT brs_tp_tournament_id_fk FOREIGN KEY (tournament_id)
        REFERENCES brs.tournament (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_tp_tournament_pool_type_id_fk FOREIGN KEY (tournament_pool_type_id)
        REFERENCES brs.tournament_pool_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_tp_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_tp_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.tournament_pool_user
(
    id                 serial  NOT NULL,
    user_id            integer NOT NULL,
    tournament_pool_id integer NOT NULL,
    qualified          boolean not null            default false,
    score              integer,
    date_created       timestamp without time zone DEFAULT now(),
    date_modified      timestamp without time zone,
    created_by_id      integer not null,
    modified_by_id     integer,
    archived           boolean not null            default false,
    CONSTRAINT brs_tournament_pool_user_pk PRIMARY KEY (id),
    CONSTRAINT brs_tpu_tournament_pool_id_fk FOREIGN KEY (tournament_pool_id)
        REFERENCES brs.tournament_pool (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_tpu_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_tpu_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_tpu_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.tournament_pool_position
(
    id                 serial  NOT NULL,
    position_id        integer NOT NULL,
    tournament_pool_id integer NOT NULL,
    date_created       timestamp without time zone DEFAULT now(),
    date_modified      timestamp without time zone,
    created_by_id      integer not null,
    modified_by_id     integer,
    archived           boolean not null            default false,
    CONSTRAINT brs_tournament_pool_position_pk PRIMARY KEY (id),
    CONSTRAINT brs_tpp_tournament_pool_id_fk FOREIGN KEY (tournament_pool_id)
        REFERENCES brs.tournament_pool (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_tpp_position_id_fk FOREIGN KEY (position_id)
        REFERENCES flow.position (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT brs_tpp_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT brs_tpp_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);


insert into flow.feature(feature_name, feature_code, feature_path)
values ('Tournaments', 'TOURNAMENTS', null);

insert into flow.company_feature(feature_name, company_id, feature_id, home_page)
values ('Tournaments', 3, (select id from flow.feature where feature_code = 'TOURNAMENTS'), false);

CREATE TABLE if not exists brs.tournament_seed_position
(
    id              serial  NOT NULL,
    number_of_users integer NOT NULL,
    match_number    integer NOT NULL,
    top_seed        integer NOT NULL,
    bottom_seed     integer NOT NULL,
    CONSTRAINT brs_tournament_seed_position_pk PRIMARY KEY (id)
);
