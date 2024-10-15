create table if not exists brs.tournament_pool_excluded_user
(
    id                 bigserial
        constraint brs_tournament_pool_excluded_user_pk
            primary key,
    user_id            bigint                  not null
        constraint brs_tpeu_user_id_fk
            references flow."user"
            on update restrict on delete restrict,
    tournament_pool_id bigint                  not null
        constraint brs_tpeu_tournament_pool_id_fk
            references brs.tournament_pool
            on update restrict on delete restrict,
    date_created       timestamp default now(),
    date_modified      timestamp default now(),
    created_by_id      bigint                  not null
        constraint brs_tpu_created_by_id_fk
            references flow."user",
    modified_by_id     bigint
        constraint brs_tpu_modified_by_id_fk
            references flow."user",
    archived           boolean   default false not null
);

create index if not exists tournament_pool_excluded_user_tournament_pool_id_ix
    on brs.tournament_pool_excluded_user (tournament_pool_id);

create index if not exists  tournament_pool_excluded_user_user_id_ix
    on brs.tournament_pool_excluded_user (user_id);

create unique index if not exists tpeu_uniq_idx
    on brs.tournament_pool_excluded_user (user_id, tournament_pool_id)
    where (archived IS FALSE);

