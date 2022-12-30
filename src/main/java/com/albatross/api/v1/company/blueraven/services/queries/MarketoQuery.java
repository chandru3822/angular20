package com.albatross.api.v1.company.blueraven.services.queries;

public class MarketoQuery {

  //language=PostgreSQL
  public final static String projectIdsPreviousDayStatusChange = """
    with updated_projects as (
      -- projects modified in the last 24 hours which have a current status we care about (potential projects of interest)
      select distinct on (pa1.project_id) pa1.project_id, pa1.id, pa1.date_modified, pa1.company_project_status_type_id
      from  flow.project_audit pa1
      inner join flow.project p on pa1.project_id = p.id
      inner join flow.company_process cp on pa1.company_process_id = cp.id
      where pa1.date_modified >= (now() - interval '24 hours') and
            pa1.company_project_status_type_id = any(array[62,64,65,66]::bigint[]) and
            p.archived is not true and
            cp.company_id = 3 and
            pa1.cancelled_date is null and
            cp.process_id = 1
      order by pa1.project_id, pa1.date_modified desc, pa1.id desc
    ), status_change_24_hours as (
      -- projects with multiple edits in the last 24 hours having a status change
      select distinct pa2.project_id
      from flow.project_audit pa2
      inner join updated_projects up1 on up1.project_id = pa2.project_id
      where pa2.id != up1.id and
            pa2.date_modified >= (now() - interval '24 hours') and
            pa2.company_project_status_type_id != up1.company_project_status_type_id
    ), post_24_hours_status as (
      -- status of project's most recent edit older than 24 hours
      select distinct on (pa3.project_id) pa3.project_id, pa3.date_modified, pa3.company_project_status_type_id, pa3.id
      from flow.project_audit pa3
      inner join updated_projects up2 on up2.project_id = pa3.project_id
      where pa3.date_modified < (now() - interval '24 hours')
      order by pa3.project_id, pa3.date_modified desc
    )
    select project_id
    from status_change_24_hours
    union
    select up3.project_id
    from updated_projects up3
    inner join status_change_24_hours sc24h1 on sc24h1.project_id != up3.project_id
    inner join post_24_hours_status p24hs on p24hs.project_id = up3.project_id
    where up3.company_project_status_type_id != p24hs.company_project_status_type_id
    """;

  //language=PostgreSQL
  public final static String projectsToRemove = """
    -- projects marked 'do not solicit review' in the past 24 hours
    select p.id
    from flow.project p
    inner join flow.company_process cp on p.company_process_id = cp.id
    left join flow.project_custom_field_value pcfv on p.id = pcfv.project_id
    where pcfv.custom_field_group_assignment_id = 21067 and
          pcfv.boolean_value = true and
          pcfv.date_modified >= (now() - interval '24 hours') and
          cp.company_id = 3 and
          cp.process_id = 1
    union
    -- projects cancelled in the past 24 hours (and still cancelled)
    select p.id
    from flow.project p
    inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
    inner join flow.company_process cp on p.company_process_id = cp.id
    where p.cancelled_date >= (now() - interval '24 hours') and
          cpst.project_status_type_id = 2 and
          p.archived is not true and
          cp.company_id = 3 and
          cp.process_id = 1
    union
    -- pre-booking projects ('Installation Agreement Signed' in the 'Booking' step is null) and closer appointment > 30 days ago
    select p.id
    from flow.project p
    inner join flow.company_process cp on p.company_process_id = cp.id
    inner join brs.project_details pd on p.id = pd.project_id
    where pd.installation_agreement_signed_date is null and
          pd.closer_appointment_start < (now() - interval '30 days') and
          pd.closer_appointment_start > (now() - interval '37 days') and
          p.archived is not true and
          cp.company_id = 3 and
          cp.process_id = 1
    """;

  //language=PostgreSQL
  public final static String projectsToReactivate = """
    with updated_projects as (
      -- projects modified in the last 24 hours which are active
      select distinct on (pa1.project_id) pa1.project_id, pa1.id, pa1.date_modified, cpst1.project_status_type_id
      from  flow.project_audit pa1
      inner join flow.project p on pa1.project_id = p.id
      inner join flow.company_process cp on pa1.company_process_id = cp.id
      inner join flow.company_project_status_type cpst1 on pa1.company_project_status_type_id = cpst1.id
      where pa1.date_modified >= (now() - interval '24 hours') and
            cpst1.project_status_type_id = 1 and
            p.archived is not true and
            cp.company_id = 3 and
            cp.process_id = 1 and
            pa1.cancelled_date is null
      order by pa1.project_id, pa1.date_modified desc, pa1.id desc
    ), post_24_hours_status as (
      -- status of those project's most recent edit older than 24 hours
      select distinct on (pa3.project_id) pa3.project_id, pa3.date_modified, cpst3.project_status_type_id, pa3.id
      from flow.project_audit pa3
      inner join updated_projects up2 on up2.project_id = pa3.project_id
      inner join flow.company_project_status_type cpst3 on pa3.company_project_status_type_id = cpst3.id
      where pa3.date_modified < (now() - interval '24 hours')
      order by pa3.project_id, pa3.date_modified desc
    )
    select up3.project_id
    from updated_projects up3
    inner join post_24_hours_status p24hs on p24hs.project_id = up3.project_id
    where p24hs.project_status_type_id = 2
    """;

  //language=PostgreSQL
  public final static String getProject = """
    select p.id,
           p.contact_id,
           p.project_name,
           p.company_project_status_type_id,
           cpst.project_status_type,
           c.first_name,
           c.last_name,
           c.street1,
           s.state,
           co.country,
           p.postal_code,
           c.phone,
           c.email,
           (
             select lov.name
             from flow.contact_custom_field_value ccfv
             inner join flow.list_of_value lov on lov.id = ccfv.int_value
             where ccfv.contact_id = p.contact_id and
                   ccfv.custom_field_group_assignment_id = 399
           ) "leadStatus",
           (
             select lov.name
             from flow.contact_custom_field_value ccfv
             inner join flow.list_of_value lov on lov.id = ccfv.int_value
             where ccfv.contact_id = p.contact_id and
                   ccfv.custom_field_group_assignment_id = 395
           ) "leadSource",
           coalesce((
             select pcfv.boolean_value
             from flow.project_custom_field_value pcfv
             where pcfv.project_id = p.id and
                   pcfv.custom_field_group_assignment_id = 21067
           ), false) "doNotSolicitReview",
           pd.installation_start_time,
           pd.energized_date,
           pd.final_design_signed_date "finalDesignApprovedDate",
           pd.final_design_sent_to_homeowner_date,
           pd.closer_appointment_start "closerAppointmentStartTime",
           pd.ahj_inspection_start_time "inspectionStartTime",
           pd.substantial_completion_date,
           pd.ahj_final_inspection_verified "inspectionPassedDate"
    from flow.project p
    inner join flow.contact c on c.id = p.contact_id
    inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
    inner join flow.company_process cp on p.company_process_id = cp.id
    inner join brs.project_details pd on pd.project_id = p.id
    left join flow.company_state cs on cs.id = p.company_state_id
    left join flow.state s on s.id = cs.state_id
    left join flow.company_country cc on cc.id = p.company_country_id
    left join flow.country co on co.id = cc.country_id
    where p.id = :projectId and
          cp.company_id = 3 and
          cp.process_id = 1
    """;

  //language=PostgreSQL
  public final static String getProjects = """
    select p.id,
           p.contact_id,
           p.project_name,
           p.company_project_status_type_id,
           cpst.project_status_type,
           c.first_name,
           c.last_name,
           c.street1,
           s.state,
           co.country,
           p.postal_code,
           c.phone,
           c.email,
           (
             select lov.name
             from flow.contact_custom_field_value ccfv
             inner join flow.list_of_value lov on lov.id = ccfv.int_value
             where ccfv.contact_id = p.contact_id and
                   ccfv.custom_field_group_assignment_id = 399
           ) "leadStatus",
           (
             select lov.name
             from flow.contact_custom_field_value ccfv
             inner join flow.list_of_value lov on lov.id = ccfv.int_value
             where ccfv.contact_id = p.contact_id and
                   ccfv.custom_field_group_assignment_id = 395
           ) "leadSource",
           coalesce((
             select pcfv.boolean_value
             from flow.project_custom_field_value pcfv
             where pcfv.project_id = p.id and
                   pcfv.custom_field_group_assignment_id = 21067
           ), false) "doNotSolicitReview",
           pd.installation_start_time,
           pd.energized_date,
           pd.final_design_signed_date "finalDesignApprovedDate",
           pd.final_design_sent_to_homeowner_date,
           pd.closer_appointment_start "closerAppointmentStartTime",
           pd.ahj_inspection_start_time "inspectionStartTime",
           pd.substantial_completion_date,
           pd.ahj_final_inspection_verified "inspectionPassedDate"
    from flow.project p
    inner join flow.contact c on c.id = p.contact_id
    inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
    inner join flow.company_process cp on p.company_process_id = cp.id
    inner join brs.project_details pd on pd.project_id = p.id
    left join flow.company_state cs on cs.id = p.company_state_id
    left join flow.state s on s.id = cs.state_id
    left join flow.company_country cc on cc.id = p.company_country_id
    left join flow.country co on co.id = cc.country_id
    where p.id = any(array[ :projectIds ]::bigint[]) and
          cp.company_id = 3 and
          cp.process_id = 1
    """;
}
