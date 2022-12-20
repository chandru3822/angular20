package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query;

public class AhjPermitLinkQuery {

  //language=PostgreSQL
  public final static String findById = """
    SELECT * FROM brs.feat_db_ahj_permit_link WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String create = """
     INSERT INTO brs.feat_db_ahj_permit_link(ahj_permit_id, name, link, username, password, notes, link_type_id,date_created, created_by_id,date_modified, modified_by_id)
         VALUES (:ahjPermitId, :name, :link, :username, :password, :notes, :linkTypeId,  now(), :currentUser, now(), :currentUser)
    """;

  //language=PostgreSQL
  public final static String update = """
         UPDATE brs.feat_db_ahj_permit_link
               SET
                 ahj_permit_id = :ahjPermitId,
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
      UPDATE brs.feat_db_ahj_permit_link
            SET
              archived = TRUE,
              date_modified = now(),
              modified_by_id = :currentUser
            WHERE id = :id
    """;


}
