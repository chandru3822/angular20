package com.albatross.api.v1.company.blueraven.services.queries;

public class GoodleapQuery {
  //language=PostgreSQL
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
  public final static String getProjectIdForProposalId = """
     select plh.project_id
      from brs.proposal_log_history plh
      where plh.id = :proposalId::bigint
    """;

  //language=PostgreSQL
  public final static String getDesignAndFinancingPpsId = """
     select id from flow.project_process_step pps where pps.project_id = :projectId
                                                    and pps.process_step_id = 3355
                                                    and pps.archived is false
                                                    and pps.main is true
    """;
}
