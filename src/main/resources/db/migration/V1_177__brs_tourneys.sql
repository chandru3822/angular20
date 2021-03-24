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
-- add tournament match seeding stuff
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (2, 1, 1, 2);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (4, 1, 1, 4);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (4, 2, 3, 2);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (8, 1, 1, 8);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (8, 2, 4, 5);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (8, 3, 3, 6);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (8, 4, 2, 7);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (16, 1, 1, 16);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (16, 2, 8, 9);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (16, 3, 4, 13);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (16, 4, 5, 12);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (16, 5, 6, 11);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (16, 6, 3, 14);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (16, 7, 7, 10);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (16, 8, 2, 15);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 1, 1, 32);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 2, 16, 17);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 3, 9, 24);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 4, 8, 25);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 5, 4, 29);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 6, 13, 20);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 7, 12, 21);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 8, 5, 28);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 9, 6, 27);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 10, 11, 22);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 11, 14, 19);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 12, 3, 30);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 13, 7, 26);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 14, 10, 23);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 15, 15, 18);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (32, 16, 2, 31);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 1, 1, 64);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 2, 32, 33);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 3, 17, 48);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 4, 16, 49);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 5, 9, 56);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 6, 24, 41);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 7, 25, 40);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 8, 8, 57);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 9, 5, 60);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 10, 28, 37);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 11, 21, 44);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 12, 12, 53);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 13, 13, 52);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 14, 20, 45);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 15, 29, 36);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 16, 4, 61);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 17, 6, 59);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 18, 27, 38);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 19, 22, 43);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 20, 11, 54);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 21, 14, 51);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 22, 19, 46);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 23, 30, 35);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 24, 3, 62);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 25, 7, 58);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 26, 26, 39);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 27, 23, 42);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 28, 10, 55);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 29, 15, 50);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 30, 18, 47);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 31, 31, 34);
insert into brs.tournament_seed_position(number_of_users, match_number, top_seed, bottom_seed)
values (64, 32, 2, 63);
