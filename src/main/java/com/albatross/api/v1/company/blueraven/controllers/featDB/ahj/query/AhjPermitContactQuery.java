package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query;

public class AhjPermitContactQuery {

  //language=PostgreSQL
  public final static String create = """
    INSERT INTO brs.feat_db_ahj_permit_contact (ahj_permit_id, ahj_contact_id)
          VALUES (:ahjPermitId, :ahjContactId)
    """;


}
