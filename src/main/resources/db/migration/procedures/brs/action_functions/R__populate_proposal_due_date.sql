drop function if exists brs.populate_proposal_due_date(integer, integer);
CREATE OR REPLACE FUNCTION brs.populate_proposal_due_date(p_project_id integer, p_project_process_step_id integer)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_due_date timestamp;
BEGIN

      with records as (
        select ppse.start_time,
               case when start_time > now() then start_time - now() else now() - start_time end as diff,
               start_time > now() as is_greater
        from flow.project_process_step_event ppse
          inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
        where ppse.process_step_event_id = 14
          and ppse.project_process_step_id = p_project_process_step_id
          and ppse.start_time is not null
          and cest.event_status_type_id = 1
        order by is_greater desc, diff
        limit 1
      )
      select start_time into v_due_date
      from records;


    IF(v_due_date is not null)
      THEN
        --for flux
--         perform flow.set_pps_cfv(p_project_id, 99999999, 22851::integer, v_due_date::text);
        --for prod
        perform flow.set_pps_cfv(p_project_id, 99999999, 22680::integer, v_due_date::text);
    END IF;


END
$function$


