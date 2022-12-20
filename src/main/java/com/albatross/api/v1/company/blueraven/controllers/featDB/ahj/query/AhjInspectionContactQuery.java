package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query;

public class AhjInspectionContactQuery {

  //language=PostgreSQL
  public final static String create = """
    INSERT INTO brs.feat_db_ahj_inspection_contact (ahj_inspection_id, ahj_contact_id)
    VALUES (:ahjInspectionId, :ahjContactId)
    """;


}
