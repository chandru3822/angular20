package com.albatross.api.v1.company.blueraven.services.queries;

public class CloserDashboardQuery {

  //language=PostgreSQL
  public final static String getIncentiveFdcCounts = """
    WITH quarters AS (
            select (extract('year' from now()) || '-01-01')::date as q1_start,
                   (extract('year' from now()) || '-03-31')::date as q1_end,
                   (extract('year' from now()) || '-04-01')::date as q2_start,
                   (extract('year' from now()) || '-06-30')::date as q2_end,
                   (extract('year' from now()) || '-07-01')::date as q3_start,
                   (extract('year' from now()) || '-09-30')::date as q3_end,
                   (extract('year' from now()) || '-10-01')::date as q4_start,
                   (extract('year' from now()) || '-12-31')::date as q4_end
          ), q1_self_gen AS (
            select case when count(1) > 0 then true else false end qualification_met
            from brs.project_details pd
            where pd.final_design_complete_date is not null
              and pd.final_design_complete_date::date between (select q1_start from quarters) and (select q1_end from quarters)
              and pd.source in (523, 524, 530, 20016) --(Closer Gen, Referral, Events - Closer Gen) (these are all self-gen sources)
              and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date::date > (select q1_end from quarters)))
              and (pd.company_project_status_type_id is null or pd.company_project_status_type_id != 3)
              and pd.closer_user_id = :currentUserId
              and pd.company_id = 3
          ), q2_self_gen AS (
            select case when count(1) > 0 then true else false end qualification_met
            from brs.project_details pd
            where pd.final_design_complete_date is not null
              and pd.final_design_complete_date::date between (select q2_start from quarters) and (select q2_end from quarters)
              and pd.source in (523, 524, 530, 20016) --(Closer Gen, Referral, Events - Closer Gen) (these are all self-gen sources)
              and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date::date > (select q2_end from quarters)))
              and (pd.company_project_status_type_id is null or pd.company_project_status_type_id != 3)
              and pd.closer_user_id = :currentUserId
              and pd.company_id = 3
          ), q3_self_gen AS (
            select case when count(1) > 0 then true else false end qualification_met
            from brs.project_details pd
            where pd.final_design_complete_date is not null
              and pd.final_design_complete_date::date between (select q3_start from quarters) and (select q3_end from quarters)
              and pd.source in (523, 524, 530, 20016) --(Closer Gen, Referral, Events - Closer Gen) (these are all self-gen sources)
              and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date::date > (select q3_end from quarters)))
              and (pd.company_project_status_type_id is null or pd.company_project_status_type_id != 3)
              and pd.closer_user_id = :currentUserId
              and pd.company_id = 3
          ), q4_self_gen AS (
            select case when count(1) > 0 then true else false end qualification_met
            from brs.project_details pd
            where pd.final_design_complete_date is not null
              and pd.final_design_complete_date::date between (select q4_start from quarters) and (select q4_end from quarters)
              and pd.source in (523, 524, 530, 20016) --(Closer Gen, Referral, Events - Closer Gen) (these are all self-gen sources)
              and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date::date > (select q4_end from quarters)))
              and (pd.company_project_status_type_id is null or pd.company_project_status_type_id != 3)
              and pd.closer_user_id = :currentUserId
              and pd.company_id = 3
          )
          SELECT (select qualification_met from q1_self_gen) q1_qualification_met,
                 (select count(1)
                  from brs.project_details pd
                  where pd.final_design_complete_date is not null
                    and pd.final_design_complete_date::date between (select q1_start from quarters) and (select q1_end from quarters)
                    and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date::date > (select q1_end from quarters)))
                    and (pd.company_project_status_type_id is null or pd.company_project_status_type_id != 3)
                    and pd.closer_user_id = :currentUserId
                    and pd.company_id = 3
                 ) as "q1",
                 (select qualification_met from q2_self_gen) q2_qualification_met,
                 (select count(1)
                  from brs.project_details pd
                  where pd.final_design_complete_date is not null
                    and pd.final_design_complete_date::date between (select q2_start from quarters) and (select q2_end from quarters)
                    and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date::date > (select q2_end from quarters)))
                    and (pd.company_project_status_type_id is null or pd.company_project_status_type_id != 3)
                    and pd.closer_user_id = :currentUserId
                    and pd.company_id = 3
                 ) as "q2",
                 (select qualification_met from q3_self_gen) q3_qualification_met,
                 (select count(1)
                  from brs.project_details pd
                  where pd.final_design_complete_date is not null
                    and pd.final_design_complete_date::date between (select q3_start from quarters) and (select q3_end from quarters)
                    and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date::date > (select q3_end from quarters)))
                    and (pd.company_project_status_type_id is null or pd.company_project_status_type_id != 3)
                    and pd.closer_user_id = :currentUserId
                    and pd.company_id = 3
                 ) as "q3",
                 (select qualification_met from q4_self_gen) q4_qualification_met,
                 (select count(1)
                  from brs.project_details pd
                  where pd.final_design_complete_date is not null
                    and pd.final_design_complete_date::date between (select q4_start from quarters) and (select q4_end from quarters)
                    and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date::date > (select q4_end from quarters)))
                    and (pd.company_project_status_type_id is null or pd.company_project_status_type_id != 3)
                    and pd.closer_user_id = :currentUserId
                    and pd.company_id = 3
                 ) as "q4"
    """;

  //language=PostgreSQL
  public final static String getAllRoundRobins = """
    SELECT pcz.id,
       pcz.company_id,
       pcz.round_robin_name,
       pcz.archived
      from flow.round_robin pcz
      WHERE pcz.archived IS FALSE
      and pcz.company_id = :companyId
      ORDER BY pcz.round_robin_name
    """;

  //language=PostgreSQL
  public final static String getRoundRobins = """
    SELECT pcz.id,
       pcz.company_id,
       pcz.round_robin_name,
       pczu.archived
      FROM flow.round_robin_user pczu
           INNER JOIN flow.round_robin pcz ON pcz.id = pczu.round_robin_id
      WHERE pczu.user_id = :userId
        AND pczu.archived IS FALSE
        AND pcz.archived IS FALSE
        and pcz.company_id = 3
        -- round_robin_user_type_id = 1 means schedule to (2 = schedule by)
        AND pczu.round_robin_user_type_id = 1
    """;

  //language=PostgreSQL
  public final static String getClosers = """
      select u.id,
             concat(u.first_name, ' ', u.last_name) as "fullName"
      from flow."user" u
      inner join flow.user_position up on u.id = up.user_id
      inner join flow.company_user_status cus on cus.user_id = u.id
      inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.has_access is true and ust.company_id = 3
      where up.position_id IN (select unnest(string_to_array(value, ',')::bigint[])
                               from flow.company_configuration_value
                               where code = 'CLOSER_POSITION_IDS')
      and up.archived is false
      and ((up.end_date is null and up.start_date <= now())
          OR now() between up.start_date and up.end_date)
      order by u.first_name, u.last_name
    """;

  //language=PostgreSQL
  public final static String getCloserResiduals = """
      select row_to_json(rows)
      from (
             select * from brs.get_closer_residual_details(:userId::bigint, :residualDate::date)
             ) as rows
    """;

  //language=PostgreSQL
  public final static String getRoundRobinLeadAllocationRank = """
    SELECT * FROM brs.get_round_robin_lead_allocation_rank(:roundRobinId::bigint, :timeInterval::bigint, :currentUserId::bigint)
    """;

  //language=PostgreSQL
  public final static String getAllCloserOffices = """
    SELECT o.id,
             o.company_id,
             o.org_name,
             o.active_flag
      FROM flow.org o
        INNER JOIN flow.org_type ot ON ot.id = o.org_type_id
      WHERE o.active_flag IS TRUE
        AND o.company_id = :companyId
        AND ot.org_type = 'Closer Sales Office'
      ORDER BY o.org_name
    """;

  //language=PostgreSQL
  public final static String getCloserDownline = """
    SELECT o.id,
             o.company_id,
             o.org_name,
             o.active_flag
      FROM flow.org o
        INNER JOIN flow.org_type ot ON ot.id = o.org_type_id
      WHERE (o.id = :userOrgId or o.parent_org_id = :userOrgId)
        AND o.active_flag IS TRUE
        AND o.company_id = :companyId
        AND ot.org_type = 'Closer Sales Office'
      ORDER BY o.org_name
    """;

  //language=PostgreSQL
  public final static String getCloserOffice = """
    SELECT o.id,
             o.company_id,
             o.org_name,
             o.active_flag
      FROM flow.org o
        INNER JOIN flow.org_type ot ON ot.id = o.org_type_id
      WHERE o.id = :userOrgId
        AND o.active_flag IS TRUE
        AND o.company_id = :companyId
        AND ot.org_type = 'Closer Sales Office'
      ORDER BY o.org_name
    """;

  //language=PostgreSQL
  public final static String getCloserTableScoresOffice = """
    select * from brs.get_office_fdc_rank(:selectedOrgId, :timeInterval)
    """;

  //language=PostgreSQL
  public final static String getCloserTableScoresRep = """
    select * from brs.get_office_rep_rankings(:timeInterval)
    """;

  //language=PostgreSQL
  public final static String getBrsProvidedSources = """
    SELECT DISTINCT pd.source source_id,
             lov.name source_name
      FROM brs.project_details pd
        INNER JOIN flow.list_of_value lov ON lov.id = pd.source
      WHERE pd.source NOT IN (523, 524, 530) --(Closer Gen, Referral, Events - Closer Gen)
        AND lov.parent_id = 520
        AND pd.company_id = 3
      ORDER BY source_name
    """;

  //language=PostgreSQL
  public final static String getSelfGenSources = """
    SELECT DISTINCT pd.source source_id,
             lov.name source_name
      FROM brs.project_details pd
        INNER JOIN flow.list_of_value lov ON lov.id = pd.source
      WHERE pd.source IN (523, 524, 530) --(Closer Gen, Referral, Events - Closer Gen)
        AND lov.parent_id = 520
        AND pd.company_id = 3
      ORDER BY source_name
    """;

  //language=PostgreSQL
  public final static String getLeaderboardBookings = """
    select pd.closer_user_id,
          pd.closer_name,
          o.org_name as office_name,
          coalesce(lov.name, '--') as metro_area,
          count(1) as booking_count
   from brs.project_details pd
       inner join flow.user_position up on up.id = pd.closer_user_position_id
       INNER JOIN flow.org o ON o.id = up.org_id
       INNER JOIN flow.company_user_status cus on cus.user_id = up.user_id
       INNER JOIN flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
       LEFT JOIN flow.organization_custom_field_value ocfv ON ocfv.org_id = o.id and ocfv.custom_field_group_assignment_id = 19097
       LEFT JOIN flow.list_of_value lov ON ocfv.int_value = lov.id
   where pd.installation_agreement_signed_date = :bookingDate::date
         and up.position_id in (select unnest(string_to_array(value, ',')::bigint[])
                                 from flow.company_configuration_value
                                 where code = 'CLOSER_POSITION_IDS')
         AND up.archived IS FALSE
         AND up.primary_flag IS true
         AND (up.end_date is null or up.end_date >= now())
         AND ust.has_access is true
   group by pd.closer_user_id, pd.closer_name, o.org_name, lov.name
   having count(1) > 1
   order by booking_count desc, closer_name;
    """;
}
