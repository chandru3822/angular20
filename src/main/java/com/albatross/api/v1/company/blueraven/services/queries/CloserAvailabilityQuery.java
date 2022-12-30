package com.albatross.api.v1.company.blueraven.services.queries;

public class CloserAvailabilityQuery {

  //language=PostgreSQL
  public final static String get = """
    select *
    from brs.get_closer_availability(:startTime::timestamp, :endTime::timestamp, array[ :postalCodeZoneUserIds ]::bigint[], :currentUserId);
    """;
}
