package com.albatross.api.v1.company.blueraven.services.queries;

public class Five9Query {
  //language=PostgreSQL
  public final static String getFirstAppointmentPitchedDate = """
    select pd.first_appointment_pitched
        from flow.contact c
        inner join brs.project_details pd on c.id = pd.contact_id
        where c.id = :contactId
    """;

  //language=PostgreSQL
  public final static String getBookingDate = """
    select pd.complete_date_booking
        from flow.contact c
        inner join brs.project_details pd on c.id = pd.contact_id
        where c.id = :contactId
    """;

  //language=PostgreSQL
  public final static String getContactIdsSalDevRetargets = """
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
            where ccfv.custom_field_group_assignment_id = 399
              and ccfv.contact_id = pd.contact_id) in
           (700, 19205, 697)) -- contacts that are new, scheduled, or attempted contact
      AND ((select ccfv.int_value
            from flow.contact_custom_field_value ccfv
            where ccfv.custom_field_group_assignment_id = 20977
              and ccfv.contact_id = pd.contact_id) in
           (40, 201, 202, 203, 204, 205, 206, 207, 208, 209)) -- contacts with certain lead level
    AND ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE >= current_date - 45
      and ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE < current_date - ( case when pd.closer_appointment_outcome_name is null then 7 else 2 end)
    order by pd.contact_id
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
              (40, 201, 202, 203, 204, 205, 206, 207, 208, 209)) -- Contact lead level is 40 or between 201-209
         AND ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE >= current_date - 2
         AND pd.contact_id = 3076572
    )
    """;
}
