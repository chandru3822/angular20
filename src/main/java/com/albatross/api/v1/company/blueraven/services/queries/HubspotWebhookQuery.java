package com.albatross.api.v1.company.blueraven.services.queries;

public class HubspotWebhookQuery {

  //language=PostgreSQL
  public final static String saveLead = """
    insert into flow.contact (contact_type_id, first_name, last_name, phone, postal_code, email, created_by_id, owner_user_position_id, company_id, company_country_id, latitude, longitude, street1, city)
    values (2, :firstName, :lastName, :phoneNumber, :postalCode, :email, 2371412, 9016, 3, 1, :latitude, :longitude, :street1, :city)
    returning id
    """;
}
