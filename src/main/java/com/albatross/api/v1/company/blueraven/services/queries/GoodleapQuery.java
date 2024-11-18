package com.albatross.api.v1.company.blueraven.services.queries;

public class GoodleapQuery {
  //language=PostgreSQL
  public final static String setFinancialAgreementSigned = """
    WITH latest_application AS (
        SELECT id
        FROM (
            SELECT plh.id,
                   ROW_NUMBER() OVER (PARTITION BY plh.project_id
                                     ORDER BY plh.goodleap_application_created_date DESC) as rn
            FROM brs.proposal_log_history plh
            WHERE plh.project_id = :projectId
            AND plh.goodleap_application_created_date is not null
        ) ranked
        WHERE rn = 1
    )
    UPDATE brs.proposal_log_history
    SET financial_agreement_signed = :dateValue::timestamp,
        date_modified = now()
    WHERE project_id = :projectId and id IN (SELECT id FROM latest_application);
    """;

  //language=PostgreSQL
  public final static String setApplicationCreatedDate = """
    UPDATE brs.proposal_log_history
    SET goodleap_application_created_date = now(), date_modified = now()
    WHERE project_id = :projectId and proposal_nbr = :proposalNbr
    """;

  //language=PostgreSQL
  public final static String getFinancialAgreementSignedUpdates = """
     select plh.project_id, plh.financial_agreement_signed from brs.proposal_log_history plh where
                            ((plh.financial_agreement_signed AT TIME ZONE 'UTC')
                                    AT TIME ZONE 'US/Mountain')::DATE >= current_date - 1 -- less than a day old
    """;

  //language=PostgreSQL
  public final static String getCountersignedUpdates = """
     select plh.project_id, plh.countersigned from brs.proposal_log_history plh where
                            ((plh.countersigned AT TIME ZONE 'UTC')
                                    AT TIME ZONE 'US/Mountain')::DATE >= current_date - 1 -- less than a day old
    """;

  public final static String upsertCustomFieldValue = """
    insert into flow.project_process_step_custom_field_value (project_process_step_id, custom_field_group_assignment_id, date_value, created_by_id, date_created, modified_by_id, date_modified)
    values (:projectProcessStepId, :customFieldGroupAssignmentId, :dateValue::date, :leadOwnerUserId, now(), :leadOwnerUserId, now())
    on conflict (project_process_step_id, custom_field_group_assignment_id)
    do update
        set date_value = :dateValue::date,
            modified_by_id = :leadOwnerUserId,
            date_modified = now()
    """;

  //language=PostgreSQL
  public final static String getPpsId = """
     select id from flow.project_process_step pps where pps.project_id = :projectId
                                                    and pps.process_step_id = :psId
                                                    and pps.archived is false
                                                    and pps.main is true
    """;
}
