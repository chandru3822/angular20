package com.albatross.api.v1.company.blueraven.services.queries;

public class CustomActionQuery {

  //language=PostgreSQL
  public final static String rescheduleCloserAppt = """
    select * from brs.reschedule_closer_appointment(:ppsEventId::bigint, :userId::bigint)
    """;
}
