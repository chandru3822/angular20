package com.albatross.api.v1.company.blueraven.services.queries;

public class AwsQuery {

  //language=PostgreSQL
  public final static String updateProjectWithUtilityBillInfo = """
INSERT INTO flow.project_process_step_custom_field_value (
             project_process_step_id,
             custom_field_group_assignment_id,
             date_value,
             text_value,
             created_by_id,
             date_created,
             modified_by_id,
             date_modified
         )
         SELECT
             (SELECT pps.id
              FROM flow.attachment a
                       JOIN flow.project_process_step_attachment ppsa ON a.id = ppsa.attachment_id
                       JOIN flow.project_process_step pps ON pps.id = ppsa.project_process_step_id
              WHERE a.uuid = :fileUuid::UUID AND a.attachment_type_id = 47),
             unnest(array[629, 738, 739, 737, 22533, 27003, 1091]), -- Field IDs, need to match order of values below
             unnest(array[now(), NULL, NULL, NULL, NULL, NULL, NULL]),  -- Date values
             unnest(array[NULL, :customerName, :meterNumber, :accountNumber, :serviceAddress, :otherNotes, :premiseNumber]), -- Text values
             :userId,
             now(),
             :userId,
             now()
         ON CONFLICT (project_process_step_id, custom_field_group_assignment_id)
             DO UPDATE
             SET
                 date_value = COALESCE(EXCLUDED.date_value, flow.project_process_step_custom_field_value.date_value),
                 text_value = COALESCE(EXCLUDED.text_value, flow.project_process_step_custom_field_value.text_value),
                 modified_by_id = EXCLUDED.modified_by_id,
                 date_modified = now()
    """;
}
