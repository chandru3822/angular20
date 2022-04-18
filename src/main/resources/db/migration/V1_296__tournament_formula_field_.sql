-- drop table brs.tournament_formula_field_value;
-- drop table brs.tournament_formula_field;
create table if not exists brs.tournament_formula_field
(
  id                    bigserial,
  field_name            character varying not null,
  field_code            character varying not null,
  display_order         int not null,
  tournament_formula_id bigint  not null
    constraint tff_tournament_formula_id_fk references brs.tournament_formula (id),
  data_type_id          integer not null
    constraint tff_data_type_id_fk references flow.data_type (id),
  archived boolean not null default false,
  date_created          timestamp default now(),
  created_by_id         bigint  not null
    constraint tff_created_by_id_fk references flow."user"(id),
  CONSTRAINT tournament_formula_field_pk PRIMARY KEY (id)
);

create index if not exists tff_tournament_formula_id_idx on brs.tournament_formula_field (tournament_formula_id);
create index if not exists tff_data_type_id_idx on brs.tournament_formula_field (data_type_id);

create table if not exists brs.tournament_formula_field_value
(
  id                          bigserial,
  field_value                 character varying,
  tournament_formula_field_id bigint not null
    constraint tffv_tournament_formula_field_id_fk references brs.tournament_formula_field(id),
  tournament_id bigint not null
    constraint tffv_tournament_id_fk references brs.tournament(id),
  date_created                timestamp default now(),
  created_by_id               bigint not null
    constraint tffv_created_by_id_fk references flow."user"(id),
  date_modified          timestamp default now(),
  modified_by_id         bigint
    constraint tff_modified_by_id_fk references flow."user"(id),
  CONSTRAINT tournament_formula_field_value_pk PRIMARY KEY (id)
);

create index if not exists tffv_tournament_formula_field_id_idx on brs.tournament_formula_field_value (tournament_formula_field_id);

create unique index if not exists tffv_uniq_idx
  on brs.tournament_formula_field_value (tournament_formula_field_id, tournament_id);

insert into brs.tournament_formula_field(display_order, field_name, field_code, tournament_formula_id, data_type_id, created_by_id)
select 0, 'Appointment Date', 'APPOINTMENT_DATE', 1, 1, 2417170
where not exists(select *
                 from brs.tournament_formula_field
                 where field_code = 'APPOINTMENT_DATE'
                   and tournament_formula_id = 1);
