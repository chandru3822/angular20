package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query;

public class AhjQuery {

  //language=PostgreSQL
  public final static String list = """
    SELECT
              ahj.id,
              ahj.name,
              ahj.metro_area_id,
              lov.name as metro_area,
              cs.id as company_state_id,
              cs.state_id,
              s.state,
              s.abbreviation as state_abbreviation,
              ahj.archived,
              ahj.active
          FROM brs.feat_db_ahj ahj
                   LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
                   left join flow.company_state cs on cs.id = ahj.company_state_id
                   left join flow.state s on s.id = cs.state_id
          ORDER BY s.state, lov.name, ahj.name
    """;

  //language=PostgreSQL
  public final static String findById = """
    SELECT
              ahj.id,
              ahj.name,
              ahj.metro_area_id,
              lov.name as metro_area,
              cs.id as company_state_id,
              cs.state_id,
              s.state,
              s.abbreviation as state_abbreviation,
              ahj.archived,
              ahj.active
          FROM brs.feat_db_ahj ahj
                   LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
                   left join flow.company_state cs on cs.id = ahj.company_state_id
                   left join flow.state s on s.id = cs.state_id
          WHERE ahj.id = :id
    """;

  //language=PostgreSQL
  public final static String checkForDuplicate = """
    SELECT
              ahj.id,
              ahj.name,
              ahj.metro_area_id,
              lov.name as metro_area,
              cs.id as company_state_id,
              cs.state_id,
              s.state,
              s.abbreviation as state_abbreviation,
              ahj.archived
          FROM brs.feat_db_ahj ahj
                   LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
                   left join flow.company_state cs on cs.id = ahj.company_state_id
                   left join flow.state s on s.id = cs.state_id
          WHERE ahj.name = :name
            AND ahj.metro_area_id = :metroAreaId
            AND ahj.active IS FALSE
    """;

  //language=PostgreSQL
  public final static String create = """
    INSERT INTO brs.feat_db_ahj (name, metro_area_id, date_created, created_by_id, date_modified, modified_by_id, company_state_id, active)
          VALUES (:name, :metroAreaId, now(), :currentUser, now(), :currentUser, :companyStateId, true)
    """;

  //language=PostgreSQL
  public final static String update = """
    UPDATE brs.feat_db_ahj
          SET
            name = :name,
            metro_area_id = :metroAreaId,
            company_state_id = :companyStateId,
            date_modified = now(),
            modified_by_id = :currentUser,
            active = :active
          WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String simpleUpdate = """
     UPDATE brs.feat_db_ahj
           SET name = :name,
             archived = :archived,
             metro_area_id = :metroAreaId,
             company_state_id = :companyStateId,
             date_modified = now(),
             modified_by_id = :currentUser,
             active = :active
           WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String delete = """
    UPDATE brs.feat_db_ahj
          SET archived = TRUE,
            active = FALSE,
            date_modified = now(),
            modified_by_id = :userId
          WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String restore = """
    UPDATE brs.feat_db_ahj
          SET archived = false,
              active = true,
              date_modified = now(),
              modified_by_id = :userId
          WHERE id = :id and archived = true
    """;

}
