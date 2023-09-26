drop function if exists flow.add_system_activity(bigint, bigint, bigint, bigint, bigint, bigint, bigint, bigint);
  CREATE OR REPLACE FUNCTION flow.add_system_activity(p_activity_id bigint,
                                                      p_object_type_id bigint,
                                                      p_source_id bigint,
                                                      p_user_id bigint,
                                                      p_pps_id bigint,
                                                      p_ppse_id bigint,
                                                      p_old_status_id bigint,
                                                      p_new_status_id bigint)
    RETURNS void
    LANGUAGE plpgsql AS
$$
DECLARE
    v_company_activity_note text;
    v_company_activity_id bigint;
    v_new_id bigint;
    v_root_change_only boolean;
    v_old_root_status_id bigint;
    v_old_company_status character varying;
    v_old_root_status character varying;
    v_new_root_status_id bigint;
    v_new_company_status character varying;
    v_new_root_status character varying;
    v_do_insert boolean default true;
    v_prepend_msg text;
    v_append_msg text;
    v_activity_name text;
BEGIN
  --determines if the company has the selected activity enabled
  select ca.id, ca.note, ca.root_change_only
      into v_company_activity_id, v_company_activity_note, v_root_change_only
    from flow.company_activity ca
  where ca.archived is false
  and ca.activity_id = p_activity_id;

  if v_company_activity_id is not null then
    if p_object_type_id = 1 then
      --if the activity is for event status changes then check that shiz here
      if p_activity_id = 1 then
        select event_name from flow.event where id =
          (select process_step_event_id from flow.project_process_step_event where id = p_ppse_id)
        into v_activity_name;

        v_prepend_msg = concat(v_activity_name, ' ');

      end if;

      if p_activity_id = 5 then
        select cest.event_status_type,
               cest.event_status_type_id,
               est.event_status_type
        into v_old_company_status, v_old_root_status_id, v_old_root_status
        from flow.company_event_status_type cest
               inner join flow.event_status_type est on cest.event_status_type_id = est.id
        where cest.id = p_old_status_id;
        select cest.event_status_type,
               cest.event_status_type_id,
               est.event_status_type
        into v_new_company_status, v_new_root_status_id, v_new_root_status
        from flow.company_event_status_type cest
               inner join flow.event_status_type est on cest.event_status_type_id = est.id
        where cest.id = p_new_status_id;

        select event_name from flow.event where id =
          (select process_step_event_id from flow.project_process_step_event where id = p_ppse_id)
          into v_activity_name;

        v_prepend_msg = concat(v_activity_name, ' ');
        v_append_msg = concat(' from ', v_old_company_status, ' (', v_old_root_status, ') to ', v_new_company_status, ' (', v_new_root_status, ')');

        --if the activity is for ROOT only event status change, then we need to compare those instead
        if v_root_change_only is true then
          v_do_insert = (v_old_root_status_id != v_new_root_status_id);
        end if;
      end if;

      --if the activity is for process step status changes then check that shiz here
      if p_activity_id = 6 then
        select cpsst.process_step_status_type,
               cpsst.process_step_status_type_id,
               psst.process_step_status_type
        into v_old_company_status, v_old_root_status_id, v_old_root_status
        from flow.company_process_step_status_type cpsst
               inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
        where cpsst.id = p_old_status_id;
        select cpsst.process_step_status_type,
               cpsst.process_step_status_type_id,
               psst.process_step_status_type
        into v_new_company_status, v_new_root_status_id, v_new_root_status
        from flow.company_process_step_status_type cpsst
               inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
        where cpsst.id = p_new_status_id;

        select process_step_name from flow.process_step where id =
        (select process_step_id from flow.project_process_step where id = p_pps_id)
        into v_activity_name;

        v_prepend_msg = concat(v_activity_name, ' ');
        v_append_msg = concat(' from ', v_old_company_status, ' (', v_old_root_status, ') to ', v_new_company_status, ' (', v_new_root_status, ')');

        --if the activity is for ROOT only event status change, then we need to compare those instead
        if v_root_change_only is true then
          v_do_insert = (v_old_root_status_id != v_new_root_status_id);
        end if;
      end if;

      --if the activity is for project status changes then check that shiz here
      if p_activity_id = 7 then
        select cpst.project_status_type,
               cpst.project_status_type_id,
               pst.project_status_type
        into v_old_company_status, v_old_root_status_id, v_old_root_status
        from flow.company_project_status_type cpst
               inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
        where cpst.id = p_old_status_id;
        select cpst.project_status_type,
               cpst.project_status_type_id,
               pst.project_status_type
        into v_new_company_status, v_new_root_status_id, v_new_root_status
        from flow.company_project_status_type cpst
               inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
        where cpst.id = p_new_status_id;

        v_prepend_msg = concat(' ');
        v_append_msg = concat(' from ', v_old_company_status, ' (', v_old_root_status, ') to ', v_new_company_status, ' (', v_new_root_status, ')');

        --if the activity is for ROOT only event status change, then we need to compare those instead
        if v_root_change_only is true then
          v_do_insert = (v_old_root_status_id != v_new_root_status_id);
        end if;
      end if;

      if p_activity_id = 8 then
        select cpst.project_status_type,
               cpst.project_status_type_id,
               pst.project_status_type
        into v_old_company_status, v_old_root_status_id, v_old_root_status
        from flow.company_project_status_type cpst
               inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
        where cpst.id = p_old_status_id;
        select cpst.project_status_type,
               cpst.project_status_type_id,
               pst.project_status_type
        into v_new_company_status, v_new_root_status_id, v_new_root_status
        from flow.company_project_status_type cpst
               inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
        where cpst.id = p_new_status_id;

        select event_name from flow.event where id =
                                                (select process_step_event_id from flow.project_process_step_event where id = p_ppse_id)
        into v_activity_name;

        v_prepend_msg = concat(v_activity_name, ' ');
        v_append_msg = '';

        --if the activity is for ROOT only event status change, then we need to compare those instead
        if v_root_change_only is true then
          v_do_insert = (v_old_root_status_id != v_new_root_status_id);
        end if;
      end if;




      if p_activity_id = 9 then
        select cpst.project_status_type,
               cpst.project_status_type_id,
               pst.project_status_type
        into v_old_company_status, v_old_root_status_id, v_old_root_status
        from flow.company_project_status_type cpst
               inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
        where cpst.id = p_old_status_id;
        select cpst.project_status_type,
               cpst.project_status_type_id,
               pst.project_status_type
        into v_new_company_status, v_new_root_status_id, v_new_root_status
        from flow.company_project_status_type cpst
               inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
        where cpst.id = p_new_status_id;

        select process_step_name from flow.process_step where id =
                                                              (select process_step_id from flow.project_process_step where id = p_pps_id)
        into v_activity_name;

        v_prepend_msg = concat(v_activity_name, ' ');
        v_append_msg = '';

        --if the activity is for ROOT only event status change, then we need to compare those instead
        if v_root_change_only is true then
          v_do_insert = (v_old_root_status_id != v_new_root_status_id);
        end if;
      end if;

      if p_activity_id = 10 then
        select cpst.project_status_type,
               cpst.project_status_type_id,
               pst.project_status_type
        into v_old_company_status, v_old_root_status_id, v_old_root_status
        from flow.company_project_status_type cpst
               inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
        where cpst.id = p_old_status_id;
        select cpst.project_status_type,
               cpst.project_status_type_id,
               pst.project_status_type
        into v_new_company_status, v_new_root_status_id, v_new_root_status
        from flow.company_project_status_type cpst
               inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
        where cpst.id = p_new_status_id;

        select event_name from flow.event where id =
        (select process_step_event_id from flow.project_process_step_event where id = p_ppse_id)
        into v_activity_name;

        v_prepend_msg = concat(v_activity_name, ' ');
        v_append_msg = '';

        --if the activity is for ROOT only event status change, then we need to compare those instead
        if v_root_change_only is true then
          v_do_insert = (v_old_root_status_id != v_new_root_status_id);
        end if;
      end if;



      if v_do_insert is true then
        --pps wont be null if event is null so we can use that for linked
        insert into flow.project_activity(project_id, note, created_by_id, modified_by_id, activity_type_id, linked, linked_pps_id, linked_ppse_id)
        values (p_source_id, concat(v_prepend_msg, v_company_activity_note, v_append_msg), p_user_id, p_user_id, 1, (p_pps_id is not null), p_pps_id, p_ppse_id)
        returning id into v_new_id;

        --add any necessary hashtags to the system activity
        insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, created_by_id, modified_by_id)
        select v_new_id, cah.hashtag_id, p_user_id, p_user_id
        from flow.company_activity_hashtag cah
        where cah.company_activity_id = v_company_activity_id
          and cah.archived is false;
      end if;
    end if;
  end if;

END
$$
