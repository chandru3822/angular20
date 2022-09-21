drop function if exists flow.update_project_process_step_status(p_project_id bigint, p_process_step_id bigint,
                                                                p_project_process_step_id bigint,
                                                                p_company_process_step_status_typeId bigint,
                                                                p_process_step_status_type_id bigint,
                                                                p_user_id bigint,
                                                                p_cancelled_company_status_id bigint);
  CREATE OR REPLACE FUNCTION flow.update_project_process_step_status(p_project_id bigint, p_process_step_id bigint,
                                                                   p_project_process_step_id bigint,
                                                                   p_company_process_step_status_typeId bigint,
                                                                   p_process_step_status_type_id bigint,
                                                                   p_user_id bigint,
                                                                   p_cancelled_company_status_id bigint)
    RETURNS void
    LANGUAGE plpgsql AS
$$
DECLARE
    v_count      bigint;
    v_company_id bigint;
BEGIN

    -- Get count of active PPS other than the one we're updating
    select count(pps.id), cpsst.company_id
    into v_count, v_company_id
    from flow.project_process_step pps
             inner join flow.company_process_step_status_type cpsst
                        on cpsst.id = pps.company_process_step_status_type_id
    where pps.id != p_project_process_step_id
      and pps.project_id = p_project_id
      and pps.process_step_id = p_process_step_id
      and pps.archived is not true
      and cpsst.process_step_status_type_id = 1
    group by cpsst.id;

-- If updating to active status (process_step_status_type = 1), then cancel all active PPS
    IF v_count > 0 and p_process_step_status_type_id = 1
    THEN
        -- Grab the cancelled status for this company

-- cancel existing pps using the param passed in for p_cancelled_company_status_id -- unless called from an action updating itself which can only happen on active pps so this shouldn't matter
-- also un-set the main flag of any cancelled steps
        update flow.project_process_step
        set company_process_step_status_type_id = case
                                                      when p_cancelled_company_status_id is not null
                                                          then p_cancelled_company_status_id
                                                      else
                                                          (select status.id
                                                           from flow.company_process_step_status_type status
                                                           where status.company_id = v_company_id
                                                             and status.process_step_status_type_id = 3
                                                           limit 1) end, --just in case,
            date_modified                       = now(),
            modified_by_id                      = p_user_id,
            main                                = false
        where project_id = p_project_id
          and process_step_id = p_process_step_id;

    END IF;

-- Update the status and set the completion date if status is set to 2 (complete)
    update flow.project_process_step
    set company_process_step_status_type_id = p_company_process_step_status_typeId,
        modified_by_id                      = p_user_id,
        date_modified                       = now(),
        process_step_complete_date          = (case when p_process_step_status_type_id = 2 then now() end)
    where id = p_project_process_step_id;

-- If we just updated the PPS to cancelled status, unset the primary/main flag
    IF p_process_step_status_type_id = 3
    THEN
        update flow.project_process_step
        set main           = false,
            date_modified  = now(),
            modified_by_id = p_user_id
        where id = p_project_process_step_id;
    end if;

-- if status is set to 2 (complete) check for a primary flag = true, if there isn't one then set it to true
    IF p_process_step_status_type_id = 2 and (select count(1)
                                              from flow.project_process_step pps
                                              where project_id = p_project_id
                                                and pps.process_step_id = p_process_step_id
                                                and pps.main is true
                                                and pps.archived is not true) = 0
    THEN
        update flow.project_process_step pps
        set main = true
        where pps.id = p_project_process_step_id;
    end if;

-- If we just updated the PPS to active status, it must now be the only primary/main PPS
    IF p_process_step_status_type_id = 1
    THEN

        update flow.project_process_step
        set main           = false,
            date_modified  = now(),
            modified_by_id = p_user_id
        where project_id = p_project_id
          and process_step_id = p_process_step_id
          and main = true;

        update flow.project_process_step
        set main           = true,
            date_modified  = now(),
            modified_by_id = p_user_id
        where project_process_step.id = p_project_process_step_id;

    END IF;

-- if after all this there are no primary/main pps and there is only 1 non-cancelled pps, make it main
    IF (select count(1)
        from flow.project_process_step pps
        where project_id = p_project_id
          and pps.process_step_id = p_process_step_id
          and pps.main is true
          and pps.archived is not true) = 0
        AND
       (select count(1)
        from flow.project_process_step pps
                 INNER JOIN flow.company_process_step_status_type cpsst
                            on pps.company_process_step_status_type_id = cpsst.id
        where pps.project_id = p_project_id
          and pps.process_step_id = p_process_step_id
          AND cpsst.process_step_status_type_id != 3
          and pps.main is FALSE
          and pps.archived is not true) = 1
    THEN
        update flow.project_process_step pps
        set main = true
        from flow.company_process_step_status_type cpsst
        where pps.company_process_step_status_type_id = cpsst.id
          AND cpsst.process_step_status_type_id != 3
          and pps.project_id = p_project_id
          and pps.process_step_id = p_process_step_id
          and pps.main is FALSE
          and pps.archived is not true;
    END IF;

END;
$$
