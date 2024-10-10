package com.albatross.api.v1.company.blueraven.services.queries;

public class KlaviyoQuery {
  //language=PostgreSQL
  public final static String getLeadSource = """
    select lov.name
    from flow.contact_custom_field_value ccfv
             inner join flow.list_of_value lov on lov.id = ccfv.int_value
    where ccfv.contact_id = :contactId and
        ccfv.custom_field_group_assignment_id = 395
    """;

  //language=PostgreSQL
  public final static String getDigitalCronContacts = """
    WITH contact_query AS (
        SELECT
            c.id AS contact_id,
            c.email,
            ccfv1.text_value AS "gclid",
            ccfv2.text_value AS "fbclid",
            ccfv3.text_value AS "twclid",
            ccfv4.text_value AS "msclid",
            ccfv5.text_value AS "utmSource",
            ccfv6.text_value AS "utmMedium",
            ccfv7.text_value AS "utmContent",
            ccfv8.text_value AS "utmCampaign",
            pd.project_id,
            pd.closer_appointment_outcome_name,
            pd.company_project_status_type,
            pd.utility_company_name,
            pd.first_appointment_pitched,
            pd.complete_date_booking,
            pd.final_design_signed_date,
            (
                ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE >= current_date - 30
                    AND ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE < current_date - 2
                ) AS isRetargeted,
            (SELECT pa.date_modified
             FROM flow.project_activity pa
             WHERE pa.project_id = pd.project_id
               AND pa.archived IS FALSE
             ORDER BY pa.date_modified DESC
             LIMIT 1) AS latest_activity_note_date,
            (SELECT ((MAX(ppse.start_time) AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE
              FROM flow.project_process_step pps
                       INNER JOIN flow.project_process_step_event ppse ON ppse.project_process_step_id = pps.id
                  AND ppse.process_step_event_id = 14 -- Closer Appointment
              WHERE pps.project_id = pd.project_id
                and ppse.archived is false
                and pps.archived is false) AS primary_appointment_date
        FROM flow.contact c
                 INNER JOIN flow.contact_custom_field_value ccfv ON ccfv.contact_id = c.id
                 INNER JOIN flow.list_of_value lov ON lov.id = ccfv.int_value
                 LEFT JOIN brs.project_details pd ON pd.contact_id = c.id AND pd.cancelled_date IS NULL
                 LEFT JOIN flow.contact_custom_field_value ccfv1 ON ccfv1.contact_id = c.id AND ccfv1.custom_field_group_assignment_id = 23102
                 LEFT JOIN flow.contact_custom_field_value ccfv2 ON ccfv2.contact_id = c.id AND ccfv2.custom_field_group_assignment_id = 26079
                 LEFT JOIN flow.contact_custom_field_value ccfv3 ON ccfv3.contact_id = c.id AND ccfv3.custom_field_group_assignment_id = 26080
                 LEFT JOIN flow.contact_custom_field_value ccfv4 ON ccfv4.contact_id = c.id AND ccfv4.custom_field_group_assignment_id = 26081
                 LEFT JOIN flow.contact_custom_field_value ccfv5 ON ccfv5.contact_id = c.id AND ccfv5.custom_field_group_assignment_id = 26082
                 LEFT JOIN flow.contact_custom_field_value ccfv6 ON ccfv6.contact_id = c.id AND ccfv6.custom_field_group_assignment_id = 26083
                 LEFT JOIN flow.contact_custom_field_value ccfv7 ON ccfv7.contact_id = c.id AND ccfv7.custom_field_group_assignment_id = 26084
                 LEFT JOIN flow.contact_custom_field_value ccfv8 ON ccfv8.contact_id = c.id AND ccfv8.custom_field_group_assignment_id = 26085
        WHERE c.date_created > '2024-09-28'
          AND c.date_modified >= (NOW() - INTERVAL '24 hours')
          AND ccfv.custom_field_group_assignment_id = 395
          AND lov.name IN ('Paid Lead Gen', 'Paid Advertising', 'Organic', 'Organic with Referral')
    ),
         project_query AS (
             SELECT
                 pd.contact_id,
                 pd.contact_email AS email,
                 ccfv1.text_value AS "gclid",
                 ccfv2.text_value AS "fbclid",
                 ccfv3.text_value AS "twclid",
                 ccfv4.text_value AS "msclid",
                 ccfv5.text_value AS "utmSource",
                 ccfv6.text_value AS "utmMedium",
                 ccfv7.text_value AS "utmContent",
                 ccfv8.text_value AS "utmCampaign",
                 pd.project_id,
                 pd.closer_appointment_outcome_name,
                 pd.company_project_status_type,
                 pd.utility_company_name,
                 pd.first_appointment_pitched,
                 pd.complete_date_booking,
                 pd.final_design_signed_date,
                 (
                     ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE >= current_date - 30
                         AND ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE < current_date - 2
                     ) AS isRetargeted,
                 (SELECT pa.date_modified
                  FROM flow.project_activity pa
                  WHERE pa.project_id = pd.project_id
                    AND pa.archived IS FALSE
                  ORDER BY pa.date_modified DESC
                  LIMIT 1) AS latest_activity_note_date,
                  (SELECT ((MAX(ppse.start_time) AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE
                  FROM flow.project_process_step pps
                           INNER JOIN flow.project_process_step_event ppse ON ppse.project_process_step_id = pps.id
                      AND ppse.process_step_event_id = 14 -- Closer Appointment
                  WHERE pps.project_id = pd.project_id
                        and ppse.archived is false
                        and pps.archived is false) AS primary_appointment_date
             FROM brs.project_details pd
                      INNER JOIN flow.contact_custom_field_value ccfv ON ccfv.contact_id = pd.contact_id
                      INNER JOIN flow.list_of_value lov ON lov.id = ccfv.int_value
                      LEFT JOIN flow.contact_custom_field_value ccfv1 ON ccfv1.contact_id = pd.contact_id AND ccfv1.custom_field_group_assignment_id = 23102
                      LEFT JOIN flow.contact_custom_field_value ccfv2 ON ccfv2.contact_id = pd.contact_id AND ccfv2.custom_field_group_assignment_id = 26079
                      LEFT JOIN flow.contact_custom_field_value ccfv3 ON ccfv3.contact_id = pd.contact_id AND ccfv3.custom_field_group_assignment_id = 26080
                      LEFT JOIN flow.contact_custom_field_value ccfv4 ON ccfv4.contact_id = pd.contact_id AND ccfv4.custom_field_group_assignment_id = 26081
                      LEFT JOIN flow.contact_custom_field_value ccfv5 ON ccfv5.contact_id = pd.contact_id AND ccfv5.custom_field_group_assignment_id = 26082
                      LEFT JOIN flow.contact_custom_field_value ccfv6 ON ccfv6.contact_id = pd.contact_id AND ccfv6.custom_field_group_assignment_id = 26083
                      LEFT JOIN flow.contact_custom_field_value ccfv7 ON ccfv7.contact_id = pd.contact_id AND ccfv7.custom_field_group_assignment_id = 26084
                      LEFT JOIN flow.contact_custom_field_value ccfv8 ON ccfv8.contact_id = pd.contact_id AND ccfv8.custom_field_group_assignment_id = 26085
             WHERE pd.project_created_date >  '2024-09-28'
               AND pd.date_modified >= (NOW() - INTERVAL '24 hours')
               AND pd.cancelled_date IS NULL
               AND ccfv.custom_field_group_assignment_id = 395
               AND lov.name IN ('Paid Lead Gen', 'Paid Advertising', 'Organic', 'Organic with Referral')
         )
    SELECT * FROM contact_query
    UNION
    SELECT * FROM project_query
    """;
}
