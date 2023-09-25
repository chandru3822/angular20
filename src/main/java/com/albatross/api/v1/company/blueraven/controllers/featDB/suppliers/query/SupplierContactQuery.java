package com.albatross.api.v1.company.blueraven.controllers.featDB.suppliers.query;

public class SupplierContactQuery {

  //language=PostgreSQL
  public final static String add = """
      WITH auc AS (
        insert into brs.feat_db_contact (name, title, email, phone_number, address, notes, hours, date_created, created_by_id, date_modified, modified_by_id, contact_type_id)
        values (:name, :title, :email, :phoneNumber, :address, :notes, :hours, now(), :currentUser, now(), :currentUser, :contactTypeId)
        returning id
      )
      INSERT INTO brs.feat_db_supplier_contact (feat_db_supplier_id, feat_db_contact_id)
      SELECT :supplierId, auc.id
      FROM auc
      RETURNING feat_db_contact_id;
    """;

}
