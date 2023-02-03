package com.albatross.api.v1.company.blueraven.services.queries;

public class GenesysQuery {

  //language=PostgreSQL
  public final static String getAgentIdByContactId = """
    select text_value
    from flow.contact_custom_field_value
    where contact_id = :contactId
      and custom_field_group_assignment_id = 19331
    limit 1
    """;

  //language=PostgreSQL
  public final static String getGenesysContactIdByContactId = """
    select text_value
    from flow.contact_custom_field_value
    where contact_id = :contactId
      and custom_field_group_assignment_id = 19357
    limit 1
    """;

  //language=PostgreSQL
  public final static String updateGenesysContactIdByContactId = """
    update flow.contact_custom_field_value
    set text_value = :genesysContactId,
        date_modified = now()
    where contact_id = :contactId
      and custom_field_group_assignment_id = 19357
    """;

  //language=PostgreSQL
  public final static String getContactIdByPhone = """
    select c.id from flow.contact c
    where regexp_replace(c.phone, '[^0-9]', '', 'g') ILIKE '%' || :phone
     and case when :isParent then c.company_id = any (select id
                                                 from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
            else c.company_id = :companyId end
            and c.archived is not true
    order by id desc limit 1
    """;

  //language=PostgreSQL
  public final static String getContactAppointments = """
    SELECT coalesce(array_to_json(array_agg(row_to_json(appt))), '[]')
    FROM (select
          pd.first_appointment_pitched,
          pd.first_appointment,
          pd.closer_appointment_start > now() as future_appointment
        from flow.contact c
        inner join flow.project p on p.contact_id = c.id
        inner join brs.project_details pd on p.id = pd.project_id
        where c.id = :contactId
         and case when :isParent then c.company_id = any (select id
                                         from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
        else c.company_id = :companyId end
        and c.archived is not true) as appt;
    """;

  //language=PostgreSQL
  public final static String upsertCustomFieldValue = """
    insert into flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id, text_value, created_by_id, date_created, modified_by_id, date_modified)
    values (:contactId, :customFieldGroupAssignmentId, :textValue, :leadOwnerUserId, now(), :leadOwnerUserId, now())
    on conflict (contact_id, custom_field_group_assignment_id)
    do update
        set text_value = :textValue,
            modified_by_id = :leadOwnerUserId,
            date_modified = now()
    """;

  //language=PostgreSQL
  public final static String getContactIdsWeek1Level1 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=1
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 2)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsWeek2Level1 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=1
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 7)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsAgedLevel1 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=1
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 14)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsWeek1Level2 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=2
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 2)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsWeek2Level2 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=2
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 7)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsAgedLevel2 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=2
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 14)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsWeek1Level3 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=3
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 2)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsWeek2Level3 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=3
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 7)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsAgedLevel3 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=3
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 14)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsWeek1Level10 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=10
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 2)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsWeek2Level10 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=10
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 7)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsAgedLevel10 = """
    select contact_id as id from flow.contact_custom_field_value where custom_field_group_assignment_id=20977 and int_value=10
        and contact_id in (
          select contact_id
          from flow.contact_custom_field_value
          where custom_field_group_assignment_id = 399
            and int_value in (697,700)
            and date_created::date = ((now() at time zone 'US/Mountain')::date - 14)
    )
    """;

  //language=PostgreSQL
  public final static String getContactIdsSalDevRetargets = """
    with cfv AS (
    SELECT
        ccfv.contact_id
         , MAX(CASE WHEN custom_field_group_assignment_id = 20977 THEN 'Level ' || int_value END) AS lead_level
         , MAX(CASE WHEN custom_field_group_assignment_id = 395 THEN lov.name END) AS lead_source
         , MAX(CASE WHEN custom_field_group_assignment_id = 396 THEN lov.name END) AS lead_source_detail
         , MAX(CASE WHEN custom_field_group_assignment_id = 399 THEN lov.name END) AS lead_status
    FROM flow.contact_custom_field_value ccfv
             LEFT JOIN flow.list_of_value lov ON ccfv.int_value = lov.id
    WHERE custom_field_group_assignment_id IN (395, 396, 399, 20977)
    GROUP BY ccfv.contact_id
    ),

    caller_id as (select min(cg.call_group_name) call_group_name, min(cgpn.phone_number) phone_number, cgpc.postal_code
                  from brs.call_group cg
                           left join brs.call_group_postal_code cgpc on cgpc.call_group_id = cg.id
                           left join brs.call_group_phone_number cgpn on cgpn.call_group_id = cg.id
                  where cg.company_id = 3
                    AND cgpc.archived = false
                    AND cg.archived = false
                    AND cgpn.archived = false
                    AND cgpn.active = true
                  group by cgpc.postal_code),

    latest_closer_event AS (SELECT pps.project_id,
                                   ((MAX(ppse.start_time) AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE AS appointment_start_time
                            FROM flow.project_process_step_event ppse
                                     INNER JOIN flow.project_process_step pps ON ppse.project_process_step_id = pps.id
                                AND ppse.process_step_event_id = 14
                            GROUP BY pps.project_id)

    select c.id
    from flow.contact c
             left join caller_id ci on ci.postal_code = c.postal_code
             left join flow.project p on p.contact_id = c.id
             left join brs.project_details pd on pd.project_id = p.id
             left join cfv on cfv.contact_id = c.id
             left join latest_closer_event lse on lse.project_id = p.id AND lse.appointment_start_time >= current_date - 45
    where case
              when pd.closer_appointment_outcome_name IS NULL then lse.appointment_start_time < current_date - 7
              else lse.appointment_start_time < current_date - 2
          end
      AND pd.first_appointment_pitched IS NULL
      AND pd.cancelled_date IS NULL
      AND p.id is not null
      AND cfv.lead_source_detail not like 'Inside Sales'
      AND cfv.lead_source not like 'Setter Gen'
      AND pd.sales_dev_representative is not null
      AND (pd.closer_appointment_outcome_name not in
           ('Pitched - Proposal Shown', 'Pitched - Proposal Not Shown', 'No-Go', 'Low TSRF') or
           pd.closer_appointment_outcome_name IS NULL)
      AND cfv.lead_status in ('New', 'Scheduled', 'Attempted Contact')
    order by c.id;
    """;

  //language=PostgreSQL
  public final static String getContactIdsInsideSalesPitchedNotBooked = """
    with lead_source as (
         select c.id, lov.name
         from flow.contact_custom_field_value ccfv
                  inner join flow.custom_field_group_assignment cfga on cfga.id = ccfv.custom_field_group_assignment_id
                  inner join flow.contact c on c.id = ccfv.contact_id
                  inner join flow.list_of_value lov on lov.id = ccfv.int_value
         where cfga.id = 395
           and c.company_id = 3
     ),
    lead_status as (
         select c.id, lov.name
         from flow.contact_custom_field_value ccfv
                  inner join flow.custom_field_group_assignment cfga on cfga.id = ccfv.custom_field_group_assignment_id
                  inner join flow.contact c on c.id = ccfv.contact_id
                  inner join flow.list_of_value lov on lov.id = ccfv.int_value
         where cfga.id = 399
           and c.company_id = 3
    ),
    closer_rep as (
         SELECT p.id, u.first_name || ' ' || u.last_name as closer_name
         from flow.project p
                  inner join brs.project_details pd on pd.project_id = p.id
                  inner join flow.user u on u.id = pd.closer_user_id
    ),
    future_events as (
        SELECT pps.project_id, max(start_time) next_event
            FROM flow.project_process_step_event ppse
                join flow.project_process_step pps on ppse.project_process_step_id = pps.id
                join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
        where ppse.process_step_event_id = 14 and cest.event_status_type NOT IN ('Cancelled', 'Complete', 'Rescheduled')
        group by pps.project_id
    )
    select c.id
    from flow.contact c
             left join lead_source ls on ls.id = c.id
             left join flow.project p on p.contact_id = c.id
             left join brs.project_details pd on pd.project_id = p.id
             left join lead_status lst on lst.id = c.id
             left join closer_rep cr on cr.id = p.id
             left join future_events fe on p.id = fe.project_id
    where pd.first_appointment_pitched is not null
      and (((pd.closer_appointment_start at time zone 'UTC') at time zone
                  'US/Mountain') :: date between current_date - 180 and current_date - 10)
      and lst.name not in ('Cold', 'Unqualified', 'Do Not Call')
      and pd.company_project_status_type in ('Active', 'Pitched', 'Appointment Scheduled')
      and ls.name not in ('Closer Gen', 'Referrals')
      and (fe.next_event is null or fe.next_event < current_date)
      and pd.installation_agreement_signed_date IS NULL
    ORDER BY pd.closer_appointment_start
    """;

  //language=PostgreSQL
  public final static String getContactAppointmentDate = """
    with latest_closer_event AS (SELECT pps.project_id,
                                   ((MAX(ppse.start_time) AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE AS appointment_start_time
                            FROM flow.project_process_step_event ppse
                                     INNER JOIN flow.project_process_step pps ON ppse.project_process_step_id = pps.id
                                     left join flow.project p on p.contact_id = :contactId and p.id = pps.project_id
                                AND ppse.process_step_event_id = 14
                            GROUP BY pps.project_id)
    select lse.appointment_start_time as "Appointment Date"
    from flow.project p
             left join latest_closer_event lse on lse.project_id = p.id AND lse.appointment_start_time >= current_date - 45
    where p.contact_id = :contactId ORDER BY lse.appointment_start_time DESC NULLS LAST limit 1
    """;

  //language=PostgreSQL
  public final static String getContactCloserAppointmentOutcome = """
    select case when pd.closer_appointment_outcome_name IS NULL
            then 'Not Dispositioned'
            else pd.closer_appointment_outcome_name
           end
    from flow.project p inner join brs.project_details pd on pd.project_id = p.id
    where p.contact_id = :contactId order by p.id desc limit 1
    """;

  //language=PostgreSQL
  public final static String getContactPitchedNotBooked = """
    with pitched_not_booked as (
         select p.id, pcfv.boolean_value as "checked"
         from flow.project_custom_field_value pcfv
                  inner join flow.custom_field_group_assignment cfga on cfga.id = pcfv.custom_field_group_assignment_id
                  inner join flow.project p on p.id = pcfv.project_id
         where cfga.id = 22673
           and pcfv.boolean_value is true
           and p.contact_id = :contactId
     )
    select CASE
           WHEN pnb.checked is null THEN false
            ELSE pnb.checked
           END as "PNB"
    from flow.project p left join pitched_not_booked pnb on pnb.id = p.id
    where p.contact_id = :contactId order by p.id desc limit 1
    """;
}
