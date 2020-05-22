
alter table brs.residual_plan drop column if exists total;
alter table brs.residual_plan drop column if exists nbr_fdc_lower;
alter table brs.residual_plan drop column if exists nbr_fdc_upper;

create table if not exists brs.residual_plan_allocation
(
    id                 serial                   not null
        constraint residual_plan_allocation_pk
            primary key,
    residual_plan_id integer not null,
    name               character varying(50) not null,
    level              integer not null,
    total              numeric(10, 2) default 0 not null,
    nbr_fdc_lower      integer                  not null,
    nbr_fdc_upper      integer                  not null,
    created            timestamp with time zone,
    created_by         integer
        constraint residual_plan_created_by_user_id_fk
            references flow."user",
    CONSTRAINT residual_plan_id_fk FOREIGN KEY (residual_plan_id)
        REFERENCES brs.residual_plan (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);




create table if not exists brs.project_residual
(
    id               serial  not null
        constraint project_residual_pk
            primary key,
    project_id integer not null,
    residual_plan_id integer not null,
    CONSTRAINT pr_project_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pr_residual_plan_id_id_fk FOREIGN KEY (residual_plan_id)
        REFERENCES brs.commission_plan (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pr_comp_uk unique  (residual_plan_id,project_id)
);

alter table brs.payroll alter column selected_project_ids drop not null;

alter table flow.project_process_step_custom_field_value alter column boolean_value drop not null;
