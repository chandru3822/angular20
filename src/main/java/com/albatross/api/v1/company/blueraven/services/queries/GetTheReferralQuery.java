package com.albatross.api.v1.company.blueraven.services.queries;

public class GetTheReferralQuery {
  //language=PostgreSQL
  public final static String getProjectCreatedMilestoneContacts = """
    select pd.contact_email, pd.contact_id, cfv2.text_value as "leadId"
        from brs.project_details pd
              left join flow.contact_custom_field_value cfv
                        on pd.contact_id = cfv.contact_id and cfv.custom_field_group_assignment_id = 27364 -- GtR Lead Status
              left join flow.contact_custom_field_value cfv2
                        on pd.contact_id = cfv2.contact_id and cfv2.custom_field_group_assignment_id = 19613 -- Lead ID
        where pd.project_created_date is not null
        AND pd.lead_source_detail_name in ('GetTheReferral')
        AND pd.archived is false
        AND cfv.int_value IS NULL
        AND cfv2.text_value is not null
    """;

  //language=PostgreSQL
  public final static String getPitchedMilestoneContacts = """
    select pd.contact_email, pd.contact_id, cfv2.text_value as "leadId"
        from brs.project_details pd
                  left join flow.contact_custom_field_value cfv
                        on pd.contact_id = cfv.contact_id and cfv.custom_field_group_assignment_id = 27364 -- GtR Lead Status
                  left join flow.contact_custom_field_value cfv2
                        on pd.contact_id = cfv2.contact_id and cfv2.custom_field_group_assignment_id = 19613 -- Lead ID
        where pd.first_appointment_pitched is not null
        AND pd.lead_source_detail_name in ('GetTheReferral')
        AND pd.archived is false
        AND (cfv.int_value IS NOT NULL AND cfv.int_value = 1)
        AND cfv2.text_value is not null
    """;

  //language=PostgreSQL
  public final static String getSubstantiallyCompleteMilestoneContacts = """
    select pd.contact_email, pd.contact_id, cfv2.text_value as "leadId"
        from brs.project_details pd
                  left join flow.contact_custom_field_value cfv
                        on pd.contact_id = cfv.contact_id and cfv.custom_field_group_assignment_id = 27364 -- GtR Lead Status
                  left join flow.contact_custom_field_value cfv2
                        on pd.contact_id = cfv2.contact_id and cfv2.custom_field_group_assignment_id = 19613 -- Lead ID
        where pd.substantial_completion_approved_date is not null
        AND pd.lead_source_detail_name in ('GetTheReferral')
        AND pd.archived is false
        AND (cfv.int_value IS NOT NULL AND cfv.int_value = 2)
        AND cfv2.text_value is not null
    """;

  //language=PostgreSQL
  public final static String getProjectCompleteMilestoneContacts = """
    select pd.contact_email, pd.contact_id, cfv2.text_value as "leadId"
        from brs.project_details pd
                  left join flow.contact_custom_field_value cfv
                        on pd.contact_id = cfv.contact_id and cfv.custom_field_group_assignment_id = 27364 -- GtR Lead Status
                  left join flow.contact_custom_field_value cfv2
                        on pd.contact_id = cfv2.contact_id and cfv2.custom_field_group_assignment_id = 19613 -- Lead ID
        where pd.energized_date is not null
        AND pd.lead_source_detail_name in ('GetTheReferral')
        AND pd.archived is false
        AND (cfv.int_value IS NOT NULL AND cfv.int_value = 3)
        AND cfv2.text_value is not null
    """;

  //language=PostgreSQL
  public final static String upsertCustomFieldValue = """
    insert into flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id, text_value, int_value, created_by_id, date_created, modified_by_id, date_modified)
    values (:contactId, :customFieldGroupAssignmentId, :textValue, :intValue, :userId, now(), :userId, now())
    on conflict (contact_id, custom_field_group_assignment_id)
    do update
        set text_value = :textValue,
            int_value = :intValue,
            modified_by_id = :userId,
            date_modified = now()
    """;

  //language=PostgreSQL
  public final static String getContactIdByAdvocateId = """
    select contact_id from flow.contact_custom_field_value
    where custom_field_group_assignment_id = 27363
      and text_value = :advocateId
    limit 1
    """;

  //language=PostgreSQL
  public final static String getContactIdByEmail = """
    select id from flow.contact where email = :email
    limit 1
    """;

  //language=PostgreSQL
  public final static String getContactReferralsByContactId = """
    select text_value from flow.contact_custom_field_value
    where custom_field_group_assignment_id = 996
      and contact_id = :contactId
    """;

  //language=PostgreSQL
  public final static String getAdvocateProjectStatusUpdates = """
    SELECT DISTINCT ON (pa.project_id)
        c.email as contactEmail,
        pa.company_project_status_type_id
      FROM flow.project_audit pa
      INNER JOIN flow.contact c on pa.contact_id = c.id
      WHERE contact_id IN (
        SELECT contact_id
        FROM flow.contact_custom_field_value
        WHERE custom_field_group_assignment_id = 27363
        AND text_value IS NOT NULL
      )
      AND pa.date_modified > now() - interval '1 day'
      ORDER BY pa.project_id, pa.date_modified DESC;
    """;
}
