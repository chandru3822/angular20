package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query;

public class AhjNewHomeContactQuery {

  //language=PostgreSQL
  public final static String create = """
    INSERT INTO brs.feat_db_ahj_new_home_contact (ahj_new_home_id, ahj_contact_id)
    VALUES (:ahjNewHomeId, :ahjContactId)
    """;


}
