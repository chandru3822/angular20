package com.albatross.api.v1.company.blueraven.controllers.featDB.suppliers.query;

public class SupplierLinkQuery {

  //language=PostgreSQL
  public final static String findById = """
    SELECT * FROM brs.feat_db_supplier_link WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String add = """
     INSERT INTO brs.feat_db_supplier_link (feat_db_supplier_id, name, link, username, password, notes, date_created, created_by_id, date_modified, modified_by_id, link_type_id)
           VALUES (:supplierId, :name, :link, :username, :password, :notes, now(), :currentUser, now(), :currentUser, :linkTypeId)
           RETURNING id
    """;

  //language=PostgreSQL
  public final static String update = """
    UPDATE brs.feat_db_supplier_link
          SET feat_db_supplier_id = :supplierId,
              name = :name,
              link = :link,
              username = :username,
              password = :password,
              notes = :notes,
              date_modified = now(),
              modified_by_id = :currentUser
          WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String delete = """
     UPDATE brs.feat_db_supplier_link
           SET archived = true,
               date_modified = now(),
               modified_by_id = :currentUser
           WHERE id = :id
    """;



}
