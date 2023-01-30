drop function if exists flow.get_value_for_data_view_field(bigint, bigint);

insert into flow.flow_type(flow_type)
select 'Data View' where not exists(select id from flow.flow_type as ft where flow_type = 'Data View');

insert into flow.object_type (object_type, object_code, flow_type_id, archived, reference_table, smartlist)
select 'Data View', 'DATA_VIEW', (select id from flow.flow_type as ft where flow_type = 'Data View'), false, null, false where not exists(select id from flow.object_type ot where ot.object_code = 'DATA_VIEW');

insert into flow.company_object_type (object_type_id, company_id, created_by_id)
select (select id from flow.object_type ot where ot.object_code = 'DATA_VIEW'), 3, 2417170 where not exists (select id from flow.company_object_type as cot where cot.company_id =  3 and cot.object_type_id = (select id from flow.object_type ot where ot.object_code = 'DATA_VIEW'));

alter table flow.custom_field_group_assignment
  add column if not exists data_view_field_config_id integer references flow.data_view_field_config(id);

CREATE INDEX IF NOT EXISTS cfga_data_view_field_config_idx
  ON flow.custom_field_group_assignment (data_view_field_config_id);

alter table flow.custom_field_group_assignment drop constraint if exists null_custom_ancillary_default_check;
alter table flow.custom_field_group_assignment
  add constraint null_custom_ancillary_default_check
    check ((custom_field_id IS NOT NULL)
             OR (ancillary_custom_field_group_assignment_id IS NOT NULL)
             OR (default_field_id IS NOT NULL)
             OR (data_view_field_config_id IS NOT NULL)
      );
