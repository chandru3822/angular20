package com.albatross.api.v1.company.blueraven.services.queries;

public class SetterDashboardQuery {

  //language=PostgreSQL
  public final static String getIncentivePitchCounts = """
    WITH "quarters" AS (
                          select (extract('year' from now()) || '-01-01')::date as "q1_start",
                                 (extract('year' from now()) || '-03-31')::date as "q1_end",
                                 (extract('year' from now()) || '-04-01')::date as "q2_start",
                                 (extract('year' from now()) || '-06-30')::date as "q2_end",
                                 (extract('year' from now()) || '-07-01')::date as "q3_start",
                                 (extract('year' from now()) || '-09-30')::date as "q3_end",
                                 (extract('year' from now()) || '-10-01')::date as "q4_start",
                                 (extract('year' from now()) || '-12-31')::date as "q4_end"
                      )
                      SELECT (select count(1)
                              from brs.project_details pd
                                       inner join flow.user_position up on up.id = pd.setter_user_position_id
                              where (((case when pd.first_appointment_pitched is not null
                                                then pd.first_appointment_pitched
                                            when pd.first_appointment_pitched is null
                                                and pd.first_appointment_missed is not null
                                                then pd.first_appointment_missed
                                            else pd.closer_appointment_start
                                  end) at time zone 'UTC') at time zone 'US/Mountain') :: date between (select q1_start from quarters) and (select q1_end from quarters)
                                and pd.source in (525, 526) --(Setter Gen, Retargeted)
                                and (case when pd.first_appointment_pitched is not null
                                              then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                          when pd.first_appointment_pitched is null
                                              and pd.first_appointment_missed is not null
                                              then pd.first_appointment_missed_id in (2,3,1139,1140)
                                          else pd.closer_appointment_outcome in (2,3,1139,1140)
                                  end)
                                and case when :isSetterMgr is true then up.org_id = :setterMgrOfficeId
                                         else pd.setter_user_id = :currentUserId
                                  end
                             ) as "q1",
                             (select count(1)
                              from brs.project_details pd
                                       inner join flow.user_position up on up.id = pd.setter_user_position_id
                              where (((case when pd.first_appointment_pitched is not null
                                                then pd.first_appointment_pitched
                                            when pd.first_appointment_pitched is null
                                                and pd.first_appointment_missed is not null
                                                then pd.first_appointment_missed
                                            else pd.closer_appointment_start
                                  end) at time zone 'UTC') at time zone 'US/Mountain') :: date between (select q2_start from quarters) and (select q2_end from quarters)
                                and pd.source in (525, 526) --(Setter Gen, Retargeted)
                                and (case when pd.first_appointment_pitched is not null
                                              then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                          when pd.first_appointment_pitched is null
                                              and pd.first_appointment_missed is not null
                                              then pd.first_appointment_missed_id in (2,3,1139,1140)
                                          else pd.closer_appointment_outcome in (2,3,1139,1140)
                                  end)
                                and case when :isSetterMgr is true then up.org_id = :setterMgrOfficeId
                                         else pd.setter_user_id = :currentUserId
                                  end
                             ) as "q2",
                             (select count(1)
                              from brs.project_details pd
                                       inner join flow.user_position up on up.id = pd.setter_user_position_id
                              where (((case when pd.first_appointment_pitched is not null
                                                then pd.first_appointment_pitched
                                            when pd.first_appointment_pitched is null
                                                and pd.first_appointment_missed is not null
                                                then pd.first_appointment_missed
                                            else pd.closer_appointment_start
                                  end) at time zone 'UTC') at time zone 'US/Mountain') :: date between (select q3_start from quarters) and (select q3_end from quarters)
                                and pd.source in (525, 526) --(Setter Gen, Retargeted)
                                and (case when pd.first_appointment_pitched is not null
                                              then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                          when pd.first_appointment_pitched is null
                                              and pd.first_appointment_missed is not null
                                              then pd.first_appointment_missed_id in (2,3,1139,1140)
                                          else pd.closer_appointment_outcome in (2,3,1139,1140)
                                  end)
                                and case when :isSetterMgr is true then up.org_id = :setterMgrOfficeId
                                         else pd.setter_user_id = :currentUserId
                                  end
                             ) as "q3",
                             (select count(1)
                              from brs.project_details pd
                                       inner join flow.user_position up on up.id = pd.setter_user_position_id
                              where (((case when pd.first_appointment_pitched is not null
                                                then pd.first_appointment_pitched
                                            when pd.first_appointment_pitched is null
                                                and pd.first_appointment_missed is not null
                                                then pd.first_appointment_missed
                                            else pd.closer_appointment_start
                                  end) at time zone 'UTC') at time zone 'US/Mountain') :: date between (select q4_start from quarters) and (select q4_end from quarters)
                                and pd.source in (525, 526) --(Setter Gen, Retargeted)
                                and (case when pd.first_appointment_pitched is not null
                                              then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                          when pd.first_appointment_pitched is null
                                              and pd.first_appointment_missed is not null
                                              then pd.first_appointment_missed_id in (2,3,1139,1140)
                                          else pd.closer_appointment_outcome in (2,3,1139,1140)
                                  end)
                                and case when :isSetterMgr is true then up.org_id = :setterMgrOfficeId
                                         else pd.setter_user_id = :currentUserId
                                  end
                             ) as "q4"
    """;

  //language=PostgreSQL
  public final static String loadFunnel = """
    select brs.rpt_setter_funnel_standard(:startDate::date, :endDate::date, :trendStart::date, :trendEnd::date, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[], :hideInactive::boolean)
  """;

  public final static String loadUpcomingAppointments = """
    select brs.rpt_get_upcoming_appointments(array[ :userIds ]::bigint[],
    array[ :orgIds ]::bigint[])
   """;

  //language=PostgreSQL
  public final static String loadFunnelDrilldown = """
    select brs.rpt_setter_funnel_standard_drilldown(
    :startDate::date,
    :endDate::date,
    :funnelId::bigint,
    array[ :userIds ]::bigint[],
    array[ :orgIds ]::bigint[],
     :hideInactive::boolean)
  """;

  //language=PostgreSQL
  public final static String pitchesDrilldown = """
    SELECT * FROM brs.get_pitches_drilldown(:userId::bigint, :quarter::bigint, :isSetterMgr::BOOLEAN, :setterMgrOfficeId::bigint)
  """;

  //language=PostgreSQL
  public final static String getPerformanceReport = """
    SELECT * FROM brs.get_setter_performance_report(:currentUserId::bigint, :startDate::date, :endDate::date)
  """;

  //language=PostgreSQL
  public final static String getOfficePerformanceReport = """
    SELECT * FROM brs.get_setter_office_performance_report(:userId::bigint, :startDate::date, :endDate::date)
  """;

  //language=PostgreSQL
  public final static String topReps = """
    SELECT * FROM brs.get_top_setter_reps(:startDate::date, :endDate::date, :limit::bigInt)
  """;

  //language=PostgreSQL
  public final static String officeRanking = """
    SELECT * FROM brs.get_setter_office_ranking(:startDate::date, :endDate::date, :limit::bigInt)
  """;

  //language=PostgreSQL
  public final static String getAreas = """
    SELECT * FROM brs.util_setter_area_selection(:userId::bigint)
  """;

  //language=PostgreSQL
  public final static String getRegions = """
    SELECT * FROM brs.util_setter_region_selection(:userId::bigint, :areas::JSON)
  """;

  //language=PostgreSQL
  public final static String getDistricts = """
    SELECT * FROM brs.util_setter_district_selection(:userId::bigint, :areas::JSON, :regions::JSON)
  """;

  //language=PostgreSQL
  public final static String getOffices = """
    SELECT * FROM brs.util_setter_office_selection(:userId::bigint, :areas::JSON, :regions::JSON, :districts::JSON)
  """;

  //language=PostgreSQL
  public final static String getReps = """
    SELECT * FROM brs.util_setter_rep_selection(:userId::bigint, :areas::JSON, :regions::JSON, :districts::JSON, :offices::JSON)
  """;
}
