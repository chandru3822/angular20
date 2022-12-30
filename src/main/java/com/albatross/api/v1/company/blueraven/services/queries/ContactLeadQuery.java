package com.albatross.api.v1.company.blueraven.services.queries;

public class ContactLeadQuery {

  //language=PostgreSQL
  public final static String insertContact = """
    insert into flow.contact(contact_type_id, first_name, last_name, street1, city, postal_code, phone, email, company_id, owner_user_position_id, company_state_id, company_country_id, latitude, longitude, created_by_id,date_created, modified_by_id, date_modified)
    values (:contactTypeId, trim(:firstName), trim(:lastName), :street1, :city, trim(:postalCode), :phone, :email, :companyId, :ownerUserPositionId,
            (select cs.id from flow.state s inner join flow.company_state cs on s.id = cs.state_id
             where s.state = :state and cs.company_id = :companyId),
            (select s.country_id from flow.state s inner join flow.company_state cs on s.id = cs.state_id
             where s.state = :state and cs.company_id = :companyId),  :latitude, :longitude, :createdById, now(), :createdById, now())
    """;

  //language=PostgreSQL
  public final static String insertContactNoState = """
    insert into flow.contact(contact_type_id, first_name, last_name, street1, city, postal_code, phone, email, company_id, owner_user_position_id, latitude, longitude, created_by_id, date_created, modified_by_id, date_modified)
    values (:contactTypeId, trim(:firstName), trim(:lastName), :street1, :city, trim(:postalCode), :phone, :email, :companyId, :ownerUserPositionId, :latitude, :longitude, :createdById, now(), :createdById, now())
    """;

  //language=PostgreSQL
  public final static String checkIfCustomFieldDropdownValueExists = """
    select id
    from flow.list_of_value lov
    where lov.parent_id = :listOfValueId
      and lov.name = :customFieldDropdownValue
    """;

  //language=PostgreSQL
  public final static String upsertCustomFieldValue = """
    insert into flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id, text_value, int_value, numeric_value, created_by_id, date_created, modified_by_id, date_modified)
    values (:contactId, :customFieldGroupAssignmentId, :textValue, :intValue, :numericValue, :leadOwnerUserId, now(), :leadOwnerUserId, now())
    on conflict (contact_id, custom_field_group_assignment_id)
    do update
        set text_value = :textValue,
            int_value = :intValue,
            numeric_value = :numericValue,
            modified_by_id = :leadOwnerUserId,
            date_modified = now()
    """;

  //language=PostgreSQL
  public final static String insertCustomFieldDropdownValue = """
    with display_order as (
      select max(display_order) as value
      from flow.list_of_value
      where parent_id = :listOfValueId
    )
    insert into flow.list_of_value (name, parent_id, display_order, created_by_id, date_created, modified_by_id, date_modified)
    (select :customFieldDropdownValue, :listOfValueId, ((select value from display_order) + 1), :leadOwnerUserId, now(), :leadOwnerUserId, now())
    returning id
    """;
}
