create index po_project_id_idx
    on brs.project_override (project_id);
create index po_override_plan_id_idx
    on brs.project_override (override_plan_id);

create index pc_project_id_idx
    on brs.project_commission (project_id);
create index pc_commission_plan_id_idx
    on brs.project_commission (commission_plan_id);


create index pps_process_step_complete_date_idx
    on flow.project_process_step (process_step_complete_date);

create index pps_comp1_idx
    on flow.project_process_step (process_step_id,process_step_complete_date);


