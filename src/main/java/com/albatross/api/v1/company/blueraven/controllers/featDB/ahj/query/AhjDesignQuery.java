package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query;

public class AhjDesignQuery {


  //language=PostgreSQL
  public final static String detailByAhj = """
          SELECT
            d.*,
            ahj.metro_area_id,
            ahj.name as ahj_name,
            cs.state_id,
            s.state AS "stateName"
          FROM brs.feat_db_ahj_design d
            INNER JOIN brs.feat_db_ahj ahj ON ahj.id = d.ahj_id
            LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
             left join flow.company_state cs on cs.id = ahj.company_state_id
             left join flow.state s on s.id = cs.state_id
          WHERE d.ahj_id = :ahjId
    """;

  //language=PostgreSQL
  public final static String create = """
        INSERT INTO brs.feat_db_ahj_design(ahj_id, date_created, created_by_id, date_modified, modified_by_id)
        VALUES (:ahjId, now(), :currentUser, now(), :currentUser)
    """;

  //language=PostgreSQL
  public final static String searchAhjsByState = """
          SELECT d.id, d.ahj_id
          FROM brs.feat_db_ahj_design d
            INNER JOIN brs.feat_db_ahj ahj ON ahj.id = d.ahj_id
            LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
             left join flow.company_state cs on cs.id = ahj.company_state_id
          WHERE cs.state_id = :stateId
            AND ahj.archived IS FALSE
    """;

}
