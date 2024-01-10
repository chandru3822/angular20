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
  public final static String getContact = """
      select c.id,
             c.contact_type_id,
             cc.country_id,
             c.first_name,
             c.last_name,
             c.street1,
             c.street2,
             c.phone,
             c.mobile,
             c.city,
             c.postal_code,
             c.email,
             s.state,
             c.date_created
      from flow.contact c
        left outer join flow.company_state cs on cs.id = c.company_state_id
        left outer join flow.state s on s.id = cs.state_id
        left outer join flow.company_country cc on cc.id = c.company_country_id
        left join flow.country ctr on ctr.id = cc.country_id
      where c.id = :contactId
      and case when :isParent then c.company_id = any (select id
                                                   from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
                                                               else c.company_id = :companyId end
              and c.archived is not true
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
        inner join brs.project_details pd on c.id = pd.contact_id
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
  public final static String getContactIdsSalDevRetargets = """
    select pd.contact_id as id
    from brs.project_details pd
    where pd.first_appointment_pitched IS NULL
      AND pd.cancelled_date IS NULL
      AND pd.lead_source_detail_name != 'Inside Sales'
      AND pd.source_name != 'Setter Gen'
      AND pd.sales_dev_representative is not null
      AND (pd.closer_appointment_outcome_name not in
           ('Pitched - Proposal Shown', 'Pitched - Proposal Not Shown', 'No-Go', 'Low TSRF') or
           pd.closer_appointment_outcome_name IS NULL)
      AND ((select ccfv.int_value
            from flow.contact_custom_field_value ccfv
            where ccfv.custom_field_group_assignment_id = 399
              and ccfv.contact_id = pd.contact_id) in
           (700, 19205, 697)) -- contacts that are new, scheduled, or attempted contact
    AND ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE >= current_date - 45
      and ((pd.closer_appointment_start AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE < current_date - ( case when pd.closer_appointment_outcome_name is null then 7 else 2 end)
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
                             where ppse.process_step_event_id = 14
                               and ppse.company_event_status_type_id NOT IN (3,4,24)
                             group by pps.project_id) as next_event,
                            (select ccfv.int_value
                             from flow.contact_custom_field_value ccfv
                             where ccfv.custom_field_group_assignment_id = 399
                               and ccfv.contact_id = pd.contact_id) as lead_status_id
                     from brs.project_details pd
                     where pd.first_appointment_pitched is not null
                       and (((pd.closer_appointment_start at time zone 'UTC') at time zone
                             'US/Mountain') :: date between current_date - 180 and current_date - 30)
                       and pd.company_project_status_type in ('Project Consultation')
                       and pd.source_name not in ('Closer Gen', 'Referrals')
                       and pd.installation_agreement_signed_date IS NULL)
    select id
    from results
    where (next_event is null or next_event < current_date)
      and lead_status_id not in (698, 19595, 699)  -- 'Cold', 'Unqualified', 'Do Not Call'
    """;

  //language=PostgreSQL
  public final static String getContactAppointmentDate = """
    select appointment_date as "Appointment Date"
    from (SELECT ((MAX(ppse.start_time) AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::DATE AS appointment_date
          FROM flow.project p
                   INNER JOIN flow.project_process_step pps ON pps.project_id = p.id
                   INNER join flow.project_process_step_event ppse ON ppse.project_process_step_id = pps.id
              AND ppse.process_step_event_id = 14
          WHERE p.contact_id = :contactId
          GROUP BY pps.project_id
          limit 1)
             as foo
    where foo.appointment_date >= current_date - 45;
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
