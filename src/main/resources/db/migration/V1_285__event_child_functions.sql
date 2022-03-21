CREATE TABLE if not exists flow.process_step_event_action_company_function
(
  id                     serial  not null,
  process_step_event_action_id        integer not null,
  company_function_id    integer not null,
  date_created           timestamp without time zone DEFAULT now(),
  date_modified           timestamp without time zone,
  created_by_id          integer not null,
  modified_by_id         integer,
  archived boolean not null default false,
  display_order         integer not null,
  CONSTRAINT process_step_event_action_company_function_pk PRIMARY KEY (id),
  CONSTRAINT pseacf_process_step_event_action_id_fk FOREIGN KEY (process_step_event_action_id)
    REFERENCES flow.process_step (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT pseacf_company_function_id_fk FOREIGN KEY (company_function_id)
    REFERENCES flow.company_function (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT pseacf_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT pseacf_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists pseacf_process_step_event_action_id_idx ON flow.process_step_event_action_company_function (process_step_event_action_id);
CREATE INDEX if not exists pseacf_company_function_id_idx ON flow.process_step_event_action_company_function (company_function_id);

alter table flow.db_function add column if not exists process_step_actionable boolean not null default false;
alter table flow.db_function add column if not exists event_actionable boolean not null default false;

alter table flow.action_param_dynamic_value add column if not exists process_step_event_action_company_function_id int references flow.process_step_event_action_company_function(id);
alter table flow.action_param_dynamic_value alter column process_step_action_company_function_id drop not null;

update flow.db_function
set process_step_actionable = true
where id != 0;

insert into flow.db_function(function_name, return_data_type_id, db_function_type_id, display_name, event_actionable)
select 'flow.create_child_ps_from_event', 3, 2, 'Create Child Process Step From Event', true
where not exists (
  select id from flow.db_function where function_name = 'flow.create_child_ps_from_event'
  )
;

insert into flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id)
select (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event'), 'Event ID', 0, 6, 1, 5
  where not exists (
    select *
    from flow.db_function_param
    where db_function_id = (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event')
    and parameter_name = 'Event ID'
    );

insert into flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id)
select (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event'), 'Current User ID', 1, 6, 1, 1
where not exists (
  select *
  from flow.db_function_param
  where db_function_id = (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event')
    and parameter_name = 'Current User ID'
  );

insert into flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id)
select (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event'), 'Process Step ID to Create', 2, 6, 2
where not exists (
  select *
  from flow.db_function_param
  where db_function_id = (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event')
    and parameter_name = 'Process Step ID to Create'
  );

insert into flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id)
select (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event'), 'Initial Company Process Step Status Type ID', 3, 6, 2
where not exists (
  select *
  from flow.db_function_param
  where db_function_id = (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event')
    and parameter_name = 'Initial Company Process Step Status Type ID'
  );

insert into flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id)
select (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event'), 'Company Process Step Status Type ID for Existing Active', 4, 6, 2
where not exists (
  select *
  from flow.db_function_param
  where db_function_id = (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event')
    and parameter_name = 'Company Process Step Status Type ID for Existing Active'
  );

insert into flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id)
select (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event'), 'Override Existing Active', 5, 3, 2
where not exists (
  select *
  from flow.db_function_param
  where db_function_id = (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event')
    and parameter_name = 'Override Existing Active'
  );


insert into flow.company_function(company_function_name, db_function_id, company_id)
select 'Create Child Process Step From Event', (select id from flow.db_function where function_name = 'flow.create_child_ps_from_event'), 3
where not exists (
  select id from flow.company_function where company_function_name = 'Create Child Process Step From Event' and company_id = 3
  );


alter table flow.project_process_step add column parent_project_process_step_event_id int references flow.project_process_step_event(id);
drop function if exists flow.insert_project_process_step(integer, integer, integer, integer, integer, integer, integer, integer);
