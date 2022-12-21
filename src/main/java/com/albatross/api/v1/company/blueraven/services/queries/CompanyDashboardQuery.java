package com.albatross.api.v1.company.blueraven.services.queries;

public class CompanyDashboardQuery {

  //language=PostgreSQL
  public final static String getTargets = """
    select *
    from brs.company_dashboard_targets
    order by target_date desc
    """;

  //language=PostgreSQL
  public final static String insertTargets = """
    insert into brs.company_dashboard_targets (
        target_date, bookings_brs, bookings_partner, final_designs_completed_brs,
        final_designs_completed_partner, substantial_completions_brs, substantial_completions_partner,
        final_completions_brs,  final_completions_partner
    )
    values (
        :targetDate, :bookingsBrs, :bookingsPartner, :finalDesignsCompletedBrs,
        :finalDesignsCompletedPartner, :substantialCompletionsBrs, :substantialCompletionsPartner,
        :finalCompletionsBrs, :finalCompletionsPartner
    )
    on conflict do nothing
    """;

  //language=PostgreSQL
  public final static String updateTargets = """
    update brs.company_dashboard_targets
    set bookings_brs = :bookingsBrs,
        bookings_partner = :bookingsPartner,
        final_designs_completed_brs = :finalDesignsCompletedBrs,
        final_designs_completed_partner = :finalDesignsCompletedPartner,
        substantial_completions_brs = :substantialCompletionsBrs,
        substantial_completions_partner = :substantialCompletionsPartner,
        final_completions_brs = :finalCompletionsBrs,
        final_completions_partner = :finalCompletionsPartner
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getWeekTargets = """
    SELECT array_to_json(array_agg(row_to_json(targets)))
    FROM (
     SELECT * FROM brs.company_dashboard_targets
     where target_date = :targetDate
   ) targets
    """;

  //language=PostgreSQL
  public final static String getDates = """
    SELECT array_to_json(array_agg(row_to_json(dates)))
        FROM (
         SELECT target_date FROM brs.company_dashboard_targets ORDER BY target_date ASC
     ) dates
    """;

  //language=PostgreSQL
  public final static String getCompanyDashboard = """
    select * from brs.rpt_company_dashboard(:startDate::date, :endDate::date, :companyId::bigint, :targetTypeId::bigint, :currentUserId::bigint);
    """;

  //language=PostgreSQL
  public final static String getCompanyDashboardDrilldown = """
    select * from brs.rpt_company_dashboard_drilldown(:startDate::date, :endDate::date, :companyId::bigint, :milestoneTypeId::bigint, :loadPartners::boolean, :currentUserId::bigint);
    """;
}
