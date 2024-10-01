package com.albatross.api.v1.company.blueraven.services.queries;

public class KlaviyoQuery {
  //language=PostgreSQL
  public final static String getLeadSource = """
    select lov.name
    from flow.contact_custom_field_value ccfv
             inner join flow.list_of_value lov on lov.id = ccfv.int_value
    where ccfv.contact_id = :contactId and
        ccfv.custom_field_group_assignment_id = 395
    """;

}
