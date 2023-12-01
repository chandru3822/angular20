package com.albatross.api.v1.company.blueraven.services.queries;

public class CustomBehaviorQuery {

  //language=PostgreSQL
  public final static String saveValueFromOrg = """
    select from brs.contact_field_update_from_org(:contactId::bigint, :cfgaId::bigint, :userId::bigint, true);
  """;

}
