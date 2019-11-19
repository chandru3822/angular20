alter table flow.org
    add column if not exists schedulable boolean not null default false;

alter table flow.org
    add column if not exists state_id integer references flow.state(id);

alter table flow.process_step_requirement
    add column if not exists immutable boolean not null default false;

alter table flow."user"
    add column if not exists schedulable boolean not null default false;

CREATE TABLE if not exists flow.schedule_field_type
(
    id         serial  NOT NULL,
    field_type varchar(30) NOT NULL,
    required_data_type_id integer not null,
    archived   boolean not null default false,
    CONSTRAINT flow_schedule_field_type_pk PRIMARY KEY (id),
    CONSTRAINT flow_sft_required_data_type_id_fk FOREIGN KEY (required_data_type_id)
        REFERENCES flow.data_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
);



alter table flow.custom_field_group_assignment
    add column if not exists schedule_field_type_id integer references flow.schedule_field_type(id);

alter table flow.custom_field_group
    add column if not exists schedulable boolean not null default false;



