--update send text to closer to be event actionable
update flow.db_function set event_actionable = true where id = 17;

--update this fn to accept a cfga id instead of hard coding
drop function if exists flow.populate_pps_value_from_event(integer,  integer,  text);

insert into flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id, description)
select 64, 'Process Step CFGA ID', 2, 6, 2, null, 'The ID for the PPS Custom Field Group Assignment where you want to save the value to.'
where not exists (
  select id from flow.db_function_param
  where parameter_name = 'Process Step CFGA ID'
  and db_function_id = 64
  );

update flow.db_function_param
set display_order = 3
where parameter_name = 'Property to Save'
and db_function_id = 64;

--and the action param dynamic values
insert into flow.action_param_dynamic_value(db_function_param_id, process_step_action_company_function_id, dynamic_value, created_by_id, process_step_event_action_company_function_id)
select (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Process Step CFGA ID'),
       null, '22680', 2417170,
       (select id from flow.process_step_event_action_company_function cseacf
       where company_function_id = 334 and process_step_event_action_id =
             (select id from flow.process_step_event_action
              where process_step_event_id = 14 and action_name = 'Schedule'))
where not exists (
  select apdv.id
  from flow.action_param_dynamic_value apdv
         inner join flow.process_step_event_action_company_function pseacf on apdv.process_step_event_action_company_function_id = pseacf.id
         inner join flow.process_step_event_action psea on pseacf.process_step_event_action_id = psea.id
         inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
         inner join flow.process_step ps on pse.process_step_id = ps.id
  where company_function_id = 334
    and apdv.db_function_param_id = (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Process Step CFGA ID')
    and psea.action_name = 'Schedule'
  );

insert into flow.action_param_dynamic_value(db_function_param_id, process_step_action_company_function_id, dynamic_value, created_by_id, process_step_event_action_company_function_id)
select (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Property to Save'),
       null, 'start_time', 2417170,
       (select id from flow.process_step_event_action_company_function cseacf
        where company_function_id = 334 and process_step_event_action_id =
                                            (select id from flow.process_step_event_action
                                             where process_step_event_id = 14 and action_name = 'Schedule'))
where not exists (
  select apdv.id
  from flow.action_param_dynamic_value apdv
         inner join flow.process_step_event_action_company_function pseacf on apdv.process_step_event_action_company_function_id = pseacf.id
         inner join flow.process_step_event_action psea on pseacf.process_step_event_action_id = psea.id
         inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
         inner join flow.process_step ps on pse.process_step_id = ps.id
  where company_function_id = 334
    and apdv.db_function_param_id = (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Property to Save')
    and psea.action_name = 'Schedule'
  );

insert into flow.action_param_dynamic_value(db_function_param_id, process_step_action_company_function_id, dynamic_value, created_by_id, process_step_event_action_company_function_id)
select (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Process Step CFGA ID'),
       null, '22680', 2417170,
       (select id from flow.process_step_event_action_company_function cseacf
        where company_function_id = 334 and process_step_event_action_id =
                                            (select id from flow.process_step_event_action
                                             where process_step_event_id = 14 and action_name = 'Request Pre-Design Rework'))
where not exists (
  select apdv.id
  from flow.action_param_dynamic_value apdv
         inner join flow.process_step_event_action_company_function pseacf on apdv.process_step_event_action_company_function_id = pseacf.id
         inner join flow.process_step_event_action psea on pseacf.process_step_event_action_id = psea.id
         inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
         inner join flow.process_step ps on pse.process_step_id = ps.id
  where company_function_id = 334
    and apdv.db_function_param_id = (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Process Step CFGA ID')
    and psea.action_name = 'Request Pre-Design Rework'
  );

insert into flow.action_param_dynamic_value(db_function_param_id, process_step_action_company_function_id, dynamic_value, created_by_id, process_step_event_action_company_function_id)
select (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Property to Save'),
       null, 'start_time', 2417170,
       (select id from flow.process_step_event_action_company_function cseacf
        where company_function_id = 334 and process_step_event_action_id =
                                            (select id from flow.process_step_event_action
                                             where process_step_event_id = 14 and action_name = 'Request Pre-Design Rework'))
where not exists (
  select apdv.id
  from flow.action_param_dynamic_value apdv
         inner join flow.process_step_event_action_company_function pseacf on apdv.process_step_event_action_company_function_id = pseacf.id
         inner join flow.process_step_event_action psea on pseacf.process_step_event_action_id = psea.id
         inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
         inner join flow.process_step ps on pse.process_step_id = ps.id
  where company_function_id = 334
    and apdv.db_function_param_id = (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Property to Save')
    and psea.action_name = 'Request Pre-Design Rework'
  );

insert into flow.action_param_dynamic_value(db_function_param_id, process_step_action_company_function_id, dynamic_value, created_by_id, process_step_event_action_company_function_id)
select (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Process Step CFGA ID'),
       null, '22680', 2417170,
       (select id from flow.process_step_event_action_company_function cseacf
        where company_function_id = 334 and process_step_event_action_id =
                                            (select id from flow.process_step_event_action
                                             where process_step_event_id = 14 and action_name = 'Request Proposal'))
where not exists (
  select apdv.id
  from flow.action_param_dynamic_value apdv
         inner join flow.process_step_event_action_company_function pseacf on apdv.process_step_event_action_company_function_id = pseacf.id
         inner join flow.process_step_event_action psea on pseacf.process_step_event_action_id = psea.id
         inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
         inner join flow.process_step ps on pse.process_step_id = ps.id
  where company_function_id = 334
    and apdv.db_function_param_id = (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Process Step CFGA ID')
    and psea.action_name = 'Request Proposal'
  );

insert into flow.action_param_dynamic_value(db_function_param_id, process_step_action_company_function_id, dynamic_value, created_by_id, process_step_event_action_company_function_id)
select (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Property to Save'),
       null, 'start_time', 2417170,
       (select id from flow.process_step_event_action_company_function cseacf
        where company_function_id = 334 and process_step_event_action_id =
                                            (select id from flow.process_step_event_action
                                             where process_step_event_id = 14 and action_name = 'Request Proposal'))
where not exists (
  select apdv.id
  from flow.action_param_dynamic_value apdv
         inner join flow.process_step_event_action_company_function pseacf on apdv.process_step_event_action_company_function_id = pseacf.id
         inner join flow.process_step_event_action psea on pseacf.process_step_event_action_id = psea.id
         inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
         inner join flow.process_step ps on pse.process_step_id = ps.id
  where company_function_id = 334
    and apdv.db_function_param_id = (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Property to Save')
    and psea.action_name = 'Request Proposal'
  );

insert into flow.action_param_dynamic_value(db_function_param_id, process_step_action_company_function_id, dynamic_value, created_by_id, process_step_event_action_company_function_id)
select (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Process Step CFGA ID'),
       null, '22680', 2417170,
       (select id from flow.process_step_event_action_company_function cseacf
        where company_function_id = 334 and process_step_event_action_id =
                                            (select id from flow.process_step_event_action
                                             where process_step_event_id = 14 and action_name = 'Request Regen'))
where not exists (
  select apdv.id
  from flow.action_param_dynamic_value apdv
         inner join flow.process_step_event_action_company_function pseacf on apdv.process_step_event_action_company_function_id = pseacf.id
         inner join flow.process_step_event_action psea on pseacf.process_step_event_action_id = psea.id
         inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
         inner join flow.process_step ps on pse.process_step_id = ps.id
  where company_function_id = 334
    and apdv.db_function_param_id = (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Process Step CFGA ID')
    and psea.action_name = 'Request Regen'
  );

insert into flow.action_param_dynamic_value(db_function_param_id, process_step_action_company_function_id, dynamic_value, created_by_id, process_step_event_action_company_function_id)
select (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Property to Save'),
       null, 'start_time', 2417170,
       (select id from flow.process_step_event_action_company_function cseacf
        where company_function_id = 334 and process_step_event_action_id =
                                            (select id from flow.process_step_event_action
                                             where process_step_event_id = 14 and action_name = 'Request Regen'))
where not exists (
  select apdv.id
  from flow.action_param_dynamic_value apdv
         inner join flow.process_step_event_action_company_function pseacf on apdv.process_step_event_action_company_function_id = pseacf.id
         inner join flow.process_step_event_action psea on pseacf.process_step_event_action_id = psea.id
         inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
         inner join flow.process_step ps on pse.process_step_id = ps.id
  where company_function_id = 334
    and apdv.db_function_param_id = (select id from flow.db_function_param where db_function_id = 64 and parameter_name = 'Property to Save')
    and psea.action_name = 'Request Regen'
  );
