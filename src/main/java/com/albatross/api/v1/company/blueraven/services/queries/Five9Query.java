package com.albatross.api.v1.company.blueraven.services.queries;

public class Five9Query {
  //language=PostgreSQL
  public final static String getFirstAppointmentPitchedDate = """
    select pd.first_appointment_pitched
        from flow.contact c
        inner join brs.project_details pd on c.id = pd.contact_id
        where c.id = :contactId and pd.archived is false
        order by pd.first_appointment_pitched desc limit 1
    """;

  //language=PostgreSQL
  public final static String getBookingDate = """
    select pd.complete_date_booking
        from flow.contact c
        inner join brs.project_details pd on c.id = pd.contact_id
        where c.id = :contactId and pd.archived is false
        order by pd.complete_date_booking desc limit 1
    """;

  //language=PostgreSQL
  public final static String getContactIdsDigitalSalDevRetargets = """
    select pd.contact_id as id
    from brs.project_details pd
    where pd.first_appointment_pitched IS NULL
      AND pd.cancelled_date IS NULL
      AND (pd.closer_appointment_outcome_name not in
              ('Pitched - Proposal Shown', 'Pitched - Proposal Not Shown') or
              pd.closer_appointment_outcome_name IS NULL)
        AND pd.source_name in ('Paid Lead Gen', 'Paid Advertising', 'Organic', 'Organic with Referral', 'Sold - Paid Advertising', 'Sold - Paid Lead Gen', 'Sold - Organic')
      AND ((select ccfv.int_value
            from flow.contact_custom_field_value ccfv
            where ccfv.custom_field_group_assignment_id = 399
              and ccfv.contact_id = pd.contact_id) in
           (700, 19205, 697)) -- contacts that are new, scheduled, or attempted contact
      AND (COALESCE((select ccfv.int_value
                       from flow.contact_custom_field_value ccfv
                       where ccfv.custom_field_group_assignment_id = 20977
                       and ccfv.contact_id = pd.contact_id), 0) in
                       (0, 1, 2, 3, 7, 40)) -- contacts with certain lead level
    AND ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE >= current_date - 30 -- Closer appointment within past 30 days
      and ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE < current_date - 2 -- Closer appointment at least 2 days old
      and (select ppscfv.int_value
            from flow.project_process_step_custom_field_value ppscfv
            where ppscfv.custom_field_group_assignment_id = 26698 -- Appointment Type
              and ppscfv.project_process_step_id =
                  (select id from flow.project_process_step pps where pps.project_id = pd.project_id
                                                                  and pps.process_step_id = 1
                                                                  and pps.archived is false
                                                                  and pps.main is true)
          ) is null -- Appointment Type is null
    order by pd.contact_id
    """;

  //language=PostgreSQL
  public final static String getContactIdsVirtualSalDevRetargets = """
    select pd.contact_id as id
    from brs.project_details pd
    where pd.first_appointment_pitched IS NULL
      AND pd.cancelled_date IS NULL
      AND (pd.closer_appointment_outcome_name not in
              ('Pitched - Proposal Shown', 'Pitched - Proposal Not Shown') or
              pd.closer_appointment_outcome_name IS NULL)
      AND ((select ccfv.int_value
            from flow.contact_custom_field_value ccfv
            where ccfv.custom_field_group_assignment_id = 399
              and ccfv.contact_id = pd.contact_id) in
           (700, 19205, 697)) -- contacts that are new, scheduled, or attempted contact
    AND ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE >= current_date - 30 -- Closer appointment within past 30 days
      and ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE < current_date - 2 -- Closer appointment at least 2 day old
      AND pd.lead_source_detail_name not in ('Sunset')
      and (select ppscfv.int_value
            from flow.project_process_step_custom_field_value ppscfv
            where ppscfv.custom_field_group_assignment_id = 26698 -- Appointment Type
              and ppscfv.project_process_step_id =
                  (select id from flow.project_process_step pps where pps.project_id = pd.project_id
                                                                  and pps.process_step_id = 1
                                                                  and pps.archived is false
                                                                  and pps.main is true)
              ) is not null -- Appointment Type is not null
    order by pd.contact_id
    """;

  //language=PostgreSQL
  public final static String getContactIdsInsideSalesPitchedNotBooked = """
    with results as (select pd.contact_id             as id,
                            pd.closer_appointment_start,
                            (SELECT max(start_time) next_event
                             FROM flow.project_process_step_event ppse
                                      inner join flow.project_process_step pps
                                                 on ppse.project_process_step_id = pps.id and pps.project_id = pd.project_id
                             where ppse.process_step_event_id = 14 -- Closer Appointment
                               and ppse.company_event_status_type_id NOT IN (3,4,24) -- Cancelled, Complete, Rescheduled
                               and ppse.archived is false
                             group by pps.project_id) as next_event,
                            (select ccfv.int_value
                             from flow.contact_custom_field_value ccfv
                             where ccfv.custom_field_group_assignment_id = 399 -- lead status
                               and ccfv.contact_id = pd.contact_id) as lead_status_id
                     from brs.project_details pd
                     where pd.first_appointment_pitched is not null
                       and (((pd.closer_appointment_start at time zone 'UTC') at time zone
                             'US/Mountain') :: date between current_date - 180 and current_date - 30)
                       and
                        (
                          pd.source_name in ('Paid Lead Gen', 'Paid Advertising', 'Organic', 'Organic with Referral', 'Setter Gen',
                                             'Breeze', 'Retargeted', 'Virtual Lead', 'BRS-Display')
                            OR
                          (COALESCE((select ccfv.int_value
                               from flow.contact_custom_field_value ccfv
                               where ccfv.custom_field_group_assignment_id = 20977
                               and ccfv.contact_id = pd.contact_id), 0) in
                               (0, 1, 2, 3, 7, 40)) -- contacts with certain lead level
                          )
                       AND pd.complete_date_booking is null
                       AND (select ppscfv.int_value
                            from flow.project_process_step_custom_field_value ppscfv
                            where ppscfv.custom_field_group_assignment_id = 26698 -- Appointment Type
                              and ppscfv.project_process_step_id =
                                  (select id from flow.project_process_step pps where pps.project_id = pd.project_id
                                                                                  and pps.process_step_id = 1
                                                                                  and pps.archived is false
                                                                                  and pps.main is true)
                            ) is null -- Appointment Type is null
                       )
    select id
    from results
    where (next_event is null or next_event >= current_date - 30) -- Make sure latest Closer Appointment is greater than or equal to 30 days old
    """;

  //language=PostgreSQL
  public final static String getContactIdsInsideSalesPitchedNotBookedBreeze = """
    with results as (select pd.contact_id             as id,
                            pd.closer_appointment_start,
                            (SELECT max(start_time) next_event
                             FROM flow.project_process_step_event ppse
                                      inner join flow.project_process_step pps
                                                 on ppse.project_process_step_id = pps.id and pps.project_id = pd.project_id
                             where ppse.process_step_event_id = 14 -- Closer Appointment
                               and ppse.company_event_status_type_id NOT IN (3,4,24) -- Cancelled, Complete, Rescheduled
                               and ppse.archived is false
                             group by pps.project_id) as next_event,
                            (select ccfv.int_value
                             from flow.contact_custom_field_value ccfv
                             where ccfv.custom_field_group_assignment_id = 399 -- lead status
                               and ccfv.contact_id = pd.contact_id) as lead_status_id
                     from brs.project_details pd
                     where pd.first_appointment_pitched is not null
                       and (((pd.closer_appointment_start at time zone 'UTC') at time zone
                             'US/Mountain') :: date between current_date - 180 and current_date - 30)
                       and pd.source_name in ('Paid Lead Gen', 'Paid Advertising', 'Organic', 'Organic with Referral', 'Setter Gen')
                       AND (COALESCE((select ccfv.int_value
                               from flow.contact_custom_field_value ccfv
                               where ccfv.custom_field_group_assignment_id = 20977
                               and ccfv.contact_id = pd.contact_id), 0) in
                               (0, 1, 2, 3, 7, 40)) -- contacts with certain lead level
                       AND pd.complete_date_booking is null
                       AND pd.closer_user_id not in (select unnest(string_to_array(value, ',')::bigint[])
                                                         from flow.company_configuration_value
                                                      where code = 'PNB_EXCLUDED_USER_IDS')
                       AND (select ppscfv.int_value
                            from flow.project_process_step_custom_field_value ppscfv
                            where ppscfv.custom_field_group_assignment_id = 26698 -- Appointment Type
                              and ppscfv.project_process_step_id =
                                  (select id from flow.project_process_step pps where pps.project_id = pd.project_id
                                                                                  and pps.process_step_id = 1
                                                                                  and pps.archived is false
                                                                                  and pps.main is true)
                            ) is null -- Appointment Type is null
                       )
    select id
    from results
    where (next_event is null or next_event >= current_date - 30) -- Make sure latest Closer Appointment is greater than or equal to 30 days old
    """;

  //language=PostgreSQL
  public final static String getContactIdsInsideSalesPitchedNotBookedOrganic = """
    with results as (select pd.contact_id             as id,
                            pd.closer_appointment_start,
                            (SELECT max(start_time) next_event
                             FROM flow.project_process_step_event ppse
                                      inner join flow.project_process_step pps
                                                 on ppse.project_process_step_id = pps.id and pps.project_id = pd.project_id
                             where ppse.process_step_event_id = 14 -- Closer Appointment
                               and ppse.company_event_status_type_id NOT IN (3,4,24) -- Cancelled, Complete, Rescheduled
                               and ppse.archived is false
                             group by pps.project_id) as next_event,
                            (select ccfv.int_value
                             from flow.contact_custom_field_value ccfv
                             where ccfv.custom_field_group_assignment_id = 399 -- lead status
                               and ccfv.contact_id = pd.contact_id) as lead_status_id
                     from brs.project_details pd
                     where pd.first_appointment_pitched is not null
                       and (((pd.closer_appointment_start at time zone 'UTC') at time zone
                             'US/Mountain') :: date between current_date - 180 and current_date - 30)
                       and pd.source_name in ('Organic', 'Organic with Referral','Setter Gen')
                       AND (COALESCE((select ccfv.int_value
                               from flow.contact_custom_field_value ccfv
                               where ccfv.custom_field_group_assignment_id = 20977
                               and ccfv.contact_id = pd.contact_id), 0) in
                               (0, 1, 2, 40)) -- contacts with certain lead level
                       AND pd.complete_date_booking is null
                       AND pd.closer_user_id not in (select unnest(string_to_array(value, ',')::bigint[])
                                                         from flow.company_configuration_value
                                                      where code = 'PNB_EXCLUDED_USER_IDS')
                       AND (select ppscfv.int_value
                            from flow.project_process_step_custom_field_value ppscfv
                            where ppscfv.custom_field_group_assignment_id = 26698 -- Appointment Type
                              and ppscfv.project_process_step_id =
                                  (select id from flow.project_process_step pps where pps.project_id = pd.project_id
                                                                                  and pps.process_step_id = 1
                                                                                  and pps.archived is false
                                                                                  and pps.main is true)
                            ) is null -- Appointment Type is null
                       )
    select id
    from results
    where (next_event is null or next_event >= current_date - 30) -- Make sure latest Closer Appointment is greater than or equal to 30 days old
    """;

  //language=PostgreSQL
  public final static String getContactIdsBreezePostFDA = """
    select pd.contact_id             as id
     from brs.project_details pd
     where pd.cancelled_date is not null
       and (((pd.cancelled_date at time zone 'UTC') at time zone
             'US/Mountain') :: date between current_date - 180 and current_date - 10)  -- Make sure latest Cancelled Date is between 10-180 days old
       and pd.final_design_signed_date is not null  -- Final Design Agreement date is not null
       and pd.source_name in ('Paid Lead Gen', 'Paid Advertising', 'Setter Gen', 'Organic', 'Organic with Referral')
    """;

  //language=PostgreSQL
  public final static String getRetargetValue = """
    SELECT EXISTS(
       select pd.contact_id as id
       from brs.project_details pd
       where pd.first_appointment_pitched IS NULL
         AND pd.cancelled_date IS NULL
         AND (pd.closer_appointment_outcome_name not in
              ('Pitched - Proposal Shown', 'Pitched - Proposal Not Shown') or
              pd.closer_appointment_outcome_name IS NULL)
        AND pd.source_name in ('Paid Lead Gen', 'Paid Advertising', 'Organic', 'Organic with Referral')
         AND ((select ccfv.int_value
               from flow.contact_custom_field_value ccfv
               where ccfv.custom_field_group_assignment_id = 20977
                 and ccfv.contact_id = pd.contact_id) in
              (1, 2, 40, 201, 202, 203, 204, 205, 206, 207, 208, 209)) -- Contact lead level is 40 or between 201-209
         AND ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE >= current_date - 2
         AND pd.contact_id = 3076572
    )
    """;

  //language=PostgreSQL
  public final static String getContactAppointmentDate = """
    select appointment_date as "Appointment Date"
    from (SELECT distinct on (p.contact_id) p.contact_id, ((ppse.start_time AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE AS appointment_date
    FROM flow.project p
             INNER JOIN flow.project_process_step pps ON pps.project_id = p.id
             INNER join flow.project_process_step_event ppse ON ppse.project_process_step_id = pps.id
        AND ppse.process_step_event_id = 14
    WHERE p.contact_id = :contactId and ((ppse.start_time AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE >= current_date - 45
    order by 1,2 desc) as foo
    """;
}
