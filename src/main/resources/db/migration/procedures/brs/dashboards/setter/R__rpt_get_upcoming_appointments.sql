
drop function if exists brs.rpt_get_upcoming_appointments(p_user_position_ids bigint[],
                                                          p_org_ids bigint[]);
CREATE OR REPLACE FUNCTION brs.rpt_get_upcoming_appointments(p_user_position_ids bigint[],
                                                             p_org_ids bigint[])
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_whole_company boolean;
BEGIN

  select -1 = any (p_user_position_ids) into v_whole_company;
  return query select array_to_json(array_agg(row_to_json(upcoming_appointments)))
   from (select pd.setter_name,
                pd.project_name,
                pd.project_id,
                (pd.prioritized_closer_dashboard_start_time at time zone 'UTC') as appointment_start_time,
                pd.closer_name,
                u.phone_number,
                (pd.first_time_appointment_created at time zone 'UTC') as date_created
         from brs.project_details pd
                inner join flow.user_position up on up.id = pd.setter_user_position_id
                inner join flow.org o on o.id = up.org_id
                inner join flow.user u on u.id = pd.closer_user_id
         where case
                 when v_whole_company is false then
                   (pd.setter_user_position_id = any (p_user_position_ids)
                     and (case
                            when array_length(p_org_ids, 1) > 0
                              then o.id = any (p_org_ids)
                            else 1 = 1 end)
                     )
                 else true end
           and ((prioritized_closer_dashboard_start_time at time zone 'UTC') at time zone 'US/Mountain')::date =
               (now() at time zone 'US/Mountain' + interval '1 day')::date)  as upcoming_appointments;


END
$function$
