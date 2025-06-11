package com.albatross.api.v1.company.blueraven.services.queries;

public class KlaviyoQuery {
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
            ccfv9.text_value AS "vendorId",
            ccfv10.numeric_value AS "leadPrice",
            ccfv11.text_value AS "tier",
            ccfv12.numeric_value AS "electricMonthly",
            ccfv13.text_value AS "roofMaterial",
            ccfv14.text_value AS "sunExposure",
            ccfv15.text_value AS "homeowner",
            ccfv16.int_value AS "leadLevel",
            ccfv17.int_value AS "creditScore",
            ccfv18.timestamp_value AS "leadCreatedDate",
            sv19.name AS "aidaformRecipient",
            ccfv20.numeric_value as "householdIncome",
            ccfv21.text_value as "roofDesign",
            ccfv22_lov.name as "leadStatus",
            ccfv23_lov.name as "companyBrand",
            pd.project_created_date,
            pd.lead_source_detail_name,
            pd.source_name as lead_source,
            pd.company_project_status_type,
            pd.final_design_complete_date,
            pd.substantial_completion_date,
            pd.system_size,
            (SELECT string_agg(lov.name, ', ')
              FROM flow.list_of_value lov
              WHERE lov.id = ANY (
                  SELECT unnest(ccfv.int_array_value)
                  FROM flow.contact_custom_field_value ccfv
                  WHERE ccfv.custom_field_group_assignment_id = 18770
                    and ccfv.contact_id = c.id)) as unqualified_reason,
            pd.project_id,
            pd.closer_appointment_outcome_name,
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
                 LEFT JOIN brs.project_details pd ON pd.contact_id = c.id AND pd.cancelled_date IS NULL
                 LEFT JOIN flow.contact_custom_field_value ccfv1 ON ccfv1.contact_id = c.id AND ccfv1.custom_field_group_assignment_id = 23102 -- GCLID
                 LEFT JOIN flow.contact_custom_field_value ccfv2 ON ccfv2.contact_id = c.id AND ccfv2.custom_field_group_assignment_id = 26079 -- FBCLID
                 LEFT JOIN flow.contact_custom_field_value ccfv3 ON ccfv3.contact_id = c.id AND ccfv3.custom_field_group_assignment_id = 26080 -- TWCLID
                 LEFT JOIN flow.contact_custom_field_value ccfv4 ON ccfv4.contact_id = c.id AND ccfv4.custom_field_group_assignment_id = 26081 -- MSCLID
                 LEFT JOIN flow.contact_custom_field_value ccfv5 ON ccfv5.contact_id = c.id AND ccfv5.custom_field_group_assignment_id = 26082 -- UTM Source
                 LEFT JOIN flow.contact_custom_field_value ccfv6 ON ccfv6.contact_id = c.id AND ccfv6.custom_field_group_assignment_id = 26083 -- UTM Medium
                 LEFT JOIN flow.contact_custom_field_value ccfv7 ON ccfv7.contact_id = c.id AND ccfv7.custom_field_group_assignment_id = 26084 -- UTM Content
                 LEFT JOIN flow.contact_custom_field_value ccfv8 ON ccfv8.contact_id = c.id AND ccfv8.custom_field_group_assignment_id = 26085 -- UTM Campaign
                 LEFT JOIN flow.contact_custom_field_value ccfv9 ON ccfv9.contact_id = c.id AND ccfv9.custom_field_group_assignment_id = 19601 -- Vendor ID
                 LEFT JOIN flow.contact_custom_field_value ccfv10 ON ccfv10.contact_id = c.id AND ccfv10.custom_field_group_assignment_id = 19695 -- Lead Price
                 LEFT JOIN flow.contact_custom_field_value ccfv11 ON ccfv11.contact_id = c.id AND ccfv11.custom_field_group_assignment_id = 19602 -- Tier
                 LEFT JOIN flow.contact_custom_field_value ccfv12 ON ccfv12.contact_id = c.id AND ccfv12.custom_field_group_assignment_id = 19612 -- Electric Monthly
                 LEFT JOIN flow.contact_custom_field_value ccfv13 ON ccfv13.contact_id = c.id AND ccfv13.custom_field_group_assignment_id = 19609 -- Roof Material
                 LEFT JOIN flow.contact_custom_field_value ccfv14 ON ccfv14.contact_id = c.id AND ccfv14.custom_field_group_assignment_id = 19610 -- Sun Exposure
                 LEFT JOIN flow.contact_custom_field_value ccfv15 ON ccfv15.contact_id = c.id AND ccfv15.custom_field_group_assignment_id = 19618 -- Homeowner
                 LEFT JOIN flow.contact_custom_field_value ccfv16 ON ccfv16.contact_id = c.id AND ccfv16.custom_field_group_assignment_id = 20977 -- Lead Level
                 LEFT JOIN flow.contact_custom_field_value ccfv17 ON ccfv17.contact_id = c.id AND ccfv17.custom_field_group_assignment_id = 19615 -- Credit Score
                 LEFT JOIN flow.contact_custom_field_value ccfv18 ON ccfv18.contact_id = c.id AND ccfv18.custom_field_group_assignment_id = 1218 -- Lead Created Date
                 LEFT JOIN flow.contact_custom_field_value ccfv19 ON ccfv19.contact_id = c.id AND ccfv19.custom_field_group_assignment_id = 24223 -- AidaForm Recipient
                 LEFT JOIN flow.custom_field cf19 ON cf19.id = (SELECT custom_field_id FROM flow.custom_field_group_assignment WHERE id = 24223)
                 LEFT JOIN LATERAL flow.get_system_list_option_value(cf19.company_system_list_id, ccfv19.int_value) sv19 ON true
                 LEFT JOIN flow.contact_custom_field_value ccfv20 ON ccfv20.contact_id = c.id AND ccfv20.custom_field_group_assignment_id = 19616 -- Household Income
                 LEFT JOIN flow.contact_custom_field_value ccfv21 ON ccfv21.contact_id = c.id AND ccfv21.custom_field_group_assignment_id = 19614 -- Roof Design
                 LEFT JOIN flow.contact_custom_field_value ccfv22 ON ccfv22.contact_id = c.id AND ccfv22.custom_field_group_assignment_id = 399 -- Lead Status
                 LEFT JOIN flow.list_of_value ccfv22_lov ON ccfv22_lov.id = ccfv22.int_value
                 LEFT JOIN flow.contact_custom_field_value ccfv23 ON ccfv23.contact_id = c.id AND ccfv23.custom_field_group_assignment_id = 31423 -- Company Brand
                 LEFT JOIN flow.list_of_value ccfv23_lov ON ccfv23_lov.id = ccfv23.int_value
        WHERE c.date_created > '2024-09-28'
          AND c.date_modified >= (NOW() - INTERVAL '24 hours')
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
               ccfv9.text_value AS "vendorId",
               ccfv10.numeric_value AS "leadPrice",
               ccfv11.text_value AS "tier",
               ccfv12.numeric_value AS "electricMonthly",
               ccfv13.text_value AS "roofMaterial",
               ccfv14.text_value AS "sunExposure",
               ccfv15.text_value AS "homeowner",
               ccfv16.int_value AS "leadLevel",
               ccfv17.int_value AS "creditScore",
               ccfv18.timestamp_value AS "leadCreatedDate",
               sv19.name AS "aidaformRecipient",
               ccfv20.numeric_value as "householdIncome",
               ccfv21.text_value as "roofDesign",
               ccfv22_lov.name as "leadStatus",
               ccfv23_lov.name as "companyBrand",
               pd.project_created_date,
               pd.lead_source_detail_name,
               pd.source_name as lead_source,
               pd.company_project_status_type,
               pd.final_design_complete_date,
               pd.substantial_completion_date,
               pd.system_size,
               (SELECT string_agg(lov.name, ', ')
                FROM flow.list_of_value lov
                WHERE lov.id = ANY (
                    SELECT unnest(ccfv.int_array_value)
                    FROM flow.contact_custom_field_value ccfv
                    WHERE ccfv.custom_field_group_assignment_id = 18770
                      and ccfv.contact_id = pd.contact_id)) as unqualified_reason,
             pd.project_id,
             pd.closer_appointment_outcome_name,
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
                      LEFT JOIN flow.contact_custom_field_value ccfv1 ON ccfv1.contact_id = pd.contact_id AND ccfv1.custom_field_group_assignment_id = 23102 -- GCLID
                      LEFT JOIN flow.contact_custom_field_value ccfv2 ON ccfv2.contact_id = pd.contact_id AND ccfv2.custom_field_group_assignment_id = 26079 -- FBCLID
                      LEFT JOIN flow.contact_custom_field_value ccfv3 ON ccfv3.contact_id = pd.contact_id AND ccfv3.custom_field_group_assignment_id = 26080 -- TWCLID
                      LEFT JOIN flow.contact_custom_field_value ccfv4 ON ccfv4.contact_id = pd.contact_id AND ccfv4.custom_field_group_assignment_id = 26081 -- MSCLID
                      LEFT JOIN flow.contact_custom_field_value ccfv5 ON ccfv5.contact_id = pd.contact_id AND ccfv5.custom_field_group_assignment_id = 26082 -- UTM Source
                      LEFT JOIN flow.contact_custom_field_value ccfv6 ON ccfv6.contact_id = pd.contact_id AND ccfv6.custom_field_group_assignment_id = 26083 -- UTM Medium
                      LEFT JOIN flow.contact_custom_field_value ccfv7 ON ccfv7.contact_id = pd.contact_id AND ccfv7.custom_field_group_assignment_id = 26084 -- UTM Content
                      LEFT JOIN flow.contact_custom_field_value ccfv8 ON ccfv8.contact_id = pd.contact_id AND ccfv8.custom_field_group_assignment_id = 26085 -- UTM Campaign
                      LEFT JOIN flow.contact_custom_field_value ccfv9 ON ccfv9.contact_id = pd.contact_id AND ccfv9.custom_field_group_assignment_id = 19601 -- Vendor ID
                      LEFT JOIN flow.contact_custom_field_value ccfv10 ON ccfv10.contact_id = pd.contact_id AND ccfv10.custom_field_group_assignment_id = 19695 -- Lead Price
                      LEFT JOIN flow.contact_custom_field_value ccfv11 ON ccfv11.contact_id = pd.contact_id AND ccfv11.custom_field_group_assignment_id = 19602 -- Tier
                      LEFT JOIN flow.contact_custom_field_value ccfv12 ON ccfv12.contact_id = pd.contact_id AND ccfv12.custom_field_group_assignment_id = 19612 -- Electric Monthly
                      LEFT JOIN flow.contact_custom_field_value ccfv13 ON ccfv13.contact_id = pd.contact_id AND ccfv13.custom_field_group_assignment_id = 19609 -- Roof Material
                      LEFT JOIN flow.contact_custom_field_value ccfv14 ON ccfv14.contact_id = pd.contact_id AND ccfv14.custom_field_group_assignment_id = 19610 -- Sun Exposure
                      LEFT JOIN flow.contact_custom_field_value ccfv15 ON ccfv15.contact_id = pd.contact_id AND ccfv15.custom_field_group_assignment_id = 19618 -- Homeowner
                      LEFT JOIN flow.contact_custom_field_value ccfv16 ON ccfv16.contact_id = pd.contact_id AND ccfv16.custom_field_group_assignment_id = 20977 -- Lead Level
                      LEFT JOIN flow.contact_custom_field_value ccfv17 ON ccfv17.contact_id = pd.contact_id AND ccfv17.custom_field_group_assignment_id = 19615 -- Credit Score
                      LEFT JOIN flow.contact_custom_field_value ccfv18 ON ccfv18.contact_id = pd.contact_id AND ccfv18.custom_field_group_assignment_id = 1218 -- Lead Created Date
                      LEFT JOIN flow.contact_custom_field_value ccfv19 ON ccfv19.contact_id = pd.contact_id AND ccfv19.custom_field_group_assignment_id = 24223 -- AidaForm Recipient
                      LEFT JOIN flow.custom_field cf19 ON cf19.id = (SELECT custom_field_id FROM flow.custom_field_group_assignment WHERE id = 24223)
                      LEFT JOIN LATERAL flow.get_system_list_option_value(cf19.company_system_list_id, ccfv19.int_value) sv19 ON true
                      LEFT JOIN flow.contact_custom_field_value ccfv20 ON ccfv20.contact_id = pd.contact_id AND ccfv20.custom_field_group_assignment_id = 19616 -- Household Income
                      LEFT JOIN flow.contact_custom_field_value ccfv21 ON ccfv21.contact_id = pd.contact_id AND ccfv21.custom_field_group_assignment_id = 19614 -- Roof Design
                      LEFT JOIN flow.contact_custom_field_value ccfv22 ON ccfv22.contact_id = pd.contact_id AND ccfv22.custom_field_group_assignment_id = 399 -- Lead Status
                      LEFT JOIN flow.list_of_value ccfv22_lov ON ccfv22_lov.id = ccfv22.int_value
                      LEFT JOIN flow.contact_custom_field_value ccfv23 ON ccfv23.contact_id = pd.contact_id AND ccfv23.custom_field_group_assignment_id = 31423 -- Company Brand
                      LEFT JOIN flow.list_of_value ccfv23_lov ON ccfv23_lov.id = ccfv23.int_value
             WHERE pd.project_created_date >  '2024-09-28'
               AND pd.date_modified >= (NOW() - INTERVAL '24 hours')
               AND pd.cancelled_date IS NULL
         )
    SELECT * FROM contact_query
    UNION
    SELECT * FROM project_query
    """;

  //language=PostgreSQL
  public final static String getAppointmentSetEventProperties = """
    select pd.closer_name,
           pd.sales_dev_representative,
           pd.first_appointment_pitched,
           pd.closer_appointment_start as "primaryAppointmentDate",
           pd.contact_email as "email"
        from brs.project_details pd
        where pd.project_id = :projectId
         and pd.archived is false
    """;

  //language=PostgreSQL
  public final static String getPitchedEventProperties = """
    select pd.closer_name,
           pd.sales_dev_representative,
           pd.contact_email as "email"
        from brs.project_details pd
        where pd.project_id = :projectId
         and pd.archived is false
    """;

  //language=PostgreSQL
  public final static String getBookedEventProperties = """
    select pd.system_size,
           pd.first_appointment_pitched,
           pd.closer_appointment_outcome_name,
           pd.closer_name as "closer",
           pd.sales_dev_representative,
           pd.contact_email as "email"
        from brs.project_details pd
        where pd.project_id = :projectId
         and pd.archived is false
    """;

  //language=PostgreSQL
  public final static String getFinalDesignCompletedEventProperties = """
    select pd.system_size,
           pd.closer_name as "closer",
           pd.sales_dev_representative,
           pd.contact_email as "email"
        from brs.project_details pd
        where pd.project_id = :projectId
         and pd.archived is false
    """;

  //language=PostgreSQL
  public final static String getSubstantialCompletionEventProperties = """
    select pd.system_size,
           pd.closer_name as "closer",
           pd.sales_dev_representative,
           pd.contact_email as "email"
        from brs.project_details pd
        where pd.project_id = :projectId
         and pd.archived is false
    """;

  //language=PostgreSQL
  public final static String getUnqualifiedEventProperties = """
    WITH contact_cte AS (
        SELECT p.contact_id
        FROM flow.project p
        WHERE p.id = :projectId
    ),
    email_cte AS (
        SELECT c.email
        FROM flow.contact c
        JOIN contact_cte cc ON c.id = cc.contact_id
    ),
    sales_dev_rep_cte AS (
        SELECT concat(u.first_name, ' ', u.last_name) AS salesDevRep
        FROM flow.contact_custom_field_value ccfv2
        JOIN flow."user" u ON u.id = ccfv2.modified_by_id
        JOIN contact_cte cc ON ccfv2.contact_id = cc.contact_id
        WHERE ccfv2.custom_field_group_assignment_id = 18770
    )
    SELECT
        string_agg(lov.name, ', ') AS "unqualifiedReason",
        (SELECT salesDevRep FROM sales_dev_rep_cte) AS "salesDevRep",
        (SELECT email FROM email_cte) AS "email"
    FROM flow.list_of_value lov
    WHERE lov.id = ANY (
        SELECT unnest(ccfv.int_array_value)
        FROM flow.contact_custom_field_value ccfv
        JOIN contact_cte cc ON ccfv.contact_id = cc.contact_id
        WHERE ccfv.custom_field_group_assignment_id = 18770
    )
    """;

}
