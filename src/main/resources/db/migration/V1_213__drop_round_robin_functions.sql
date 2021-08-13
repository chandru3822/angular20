drop FUNCTION if exists flow.set_closer_appointment(p_project_id integer,
                                          p_current_user_id integer,
                                          p_project_process_step_id integer,
                                          p_appointment_start_time timestamp,
                                          p_users integer array);

drop FUNCTION if exists brs.get_total_lead_allocation(p_postal_code_zone_id integer,
                                            p_run_manual_allocation boolean);
