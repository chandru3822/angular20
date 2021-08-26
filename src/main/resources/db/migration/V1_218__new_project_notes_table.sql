create table flow.project_production_stats_type
(
    id                       serial                not null,
    production_stats_type varchar(100)           not null,
    archived                 boolean default false not null,
    CONSTRAINT project_production_stats_type_pk PRIMARY KEY (id)
);

insert into flow.project_production_stats_type (production_stats_type) values ('Substantial Completions');
insert into flow.project_production_stats_type (production_stats_type) values ('Same-week Closeout %');
insert into flow.project_production_stats_type (production_stats_type) values ('On-time Closeout %');
insert into flow.project_production_stats_type (production_stats_type) values ('Inspection Pass Rate');


CREATE TABLE if not exists flow.project_prod_stats_note
(
    id                      serial  not null,
    project_id integer not null,
    project_production_stats_type_id integer not null,
    note_id                 integer not null,
    CONSTRAINT project_prod_stats_note_pk PRIMARY KEY (id),
    CONSTRAINT ppsn_project_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ppsn_project_production_stats_type_id FOREIGN KEY (project_production_stats_type_id)
        REFERENCES flow.project_production_stats_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ppsn_note_id FOREIGN KEY (note_id)
    REFERENCES flow.note (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
