package com.albatross.api.v1.company.blueraven.controllers.featDB;

public class FeatDbContactQuery {


  //language=PostgreSQL
  public final static String findById = """
    SELECT * FROM brs.feat_db_contact WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String create = """
      INSERT INTO brs.feat_db_contact
        (name, title, email, phone_number, address, notes, hours, date_created, created_by_id, date_modified, modified_by_id,
         contact_type_id)
      VALUES
        (:name, :title, :email, :phoneNumber, :address, :notes, :hours, now(), :currentUser, now(), :currentUser,
         :contactTypeId)
    """;

  //language=PostgreSQL
  public final static String update = """
      UPDATE brs.feat_db_contact
      SET
        name = :name,
        title = :title,
        email = :email,
        phone_number = :phoneNumber,
        address = :address,
        notes = :notes,
        hours = :hours,
        date_modified = now(),
        modified_by_id = :currentUser
      WHERE id = :contactId
    """;

  //language=PostgreSQL
  public final static String delete = """
      UPDATE brs.feat_db_contact
      SET
        archived = TRUE,
        date_modified = now(),
        modified_by_id = :currentUser
      WHERE id = :contactId
    """;

}
