package com.albatross.api.v1.company.blueraven.controllers.featDB.utility.query;

public class UtilityQuery {

  //language=PostgreSQL
  public final static String list = """
          SELECT u.id,
                 u.name,
                 u.metro_area_id,
                 lov.name as metro_area,
                 cs.id as company_state_id,
                 cs.state_id,
                 s.state,
                 s.abbreviation as state_abbreviation,
                 u.archived
          FROM brs.feat_db_utility u
                   LEFT JOIN flow.list_of_value lov ON lov.id = u.metro_area_id
                   left join flow.company_state cs on cs.id = u.company_state_id
                   left join flow.state s on s.id = cs.state_id
          ORDER BY u.name
    """;

  //language=PostgreSQL
  public final static String simpleUpdate = """
     UPDATE brs.feat_db_utility
           SET name = :utilityName,
             archived = :archived,
             metro_area_id = :metroAreaId,
             company_state_id = :companyStateId,
             date_modified = now(),
             modified_by_id = :currentUser
           WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String update = """
    UPDATE brs.feat_db_utility
          SET
            name = :utilityName,
            archived = :archived,
            metro_area_id = :metroAreaId,
            company_state_id = :companyStateId,
            date_modified = now(),
            modified_by_id = :currentUser
          WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String insert = """
           INSERT INTO brs.feat_db_utility(name, archived,  metro_area_id, company_state_id, date_created, created_by_id,date_modified, modified_by_id)
           VALUES (:utilityName, false, :metroAreaId, :companyStateId,now(), :currentUser, now(), :currentUser)
    """;

  //language=PostgreSQL
  public final static String detailById = """
    SELECT
              u.*,
              lov.name as metro_area,
              cs.state_id,
              s.state,
              s.abbreviation,
              coalesce((
                           SELECT array_to_json(array_agg(row_to_json(contacts)))
                           FROM (
                                    SELECT
                                        c.id,
                                        c.name,
                                        c.title,
                                        c.email,
                                        c.phone_number AS "phoneNumber",
                                        c.address,
                                        c.notes,
                                        c.hours
                                    FROM brs.feat_db_contact c
                                             INNER JOIN brs.feat_db_utility_contact auc ON c.id = auc.feat_db_contact_id
                                    WHERE auc.utility_id = u.id AND c.archived IS FALSE AND c.contact_type_id = 8
                                ) contacts), '[]') AS contacts,
              coalesce((
                           SELECT array_to_json(array_agg(row_to_json(links)))
                           FROM (
                                    SELECT
                                        aul.id,
                                        aul.name,
                                        aul.link,
                                        aul.username,
                                        aul.link_type_id AS "linkTypeId",
                                        aul.password,
                                        aul.notes
                                    FROM brs.feat_db_utility_link aul
                                    WHERE aul.archived IS FALSE
                                      AND aul.link_type_id = 10
                                      AND aul.utility_id = u.id) links
                       ), '[]') AS links
          FROM brs.feat_db_utility u
                   LEFT JOIN flow.list_of_value lov ON lov.id = u.metro_area_id
                   left join flow.company_state cs on cs.id = u.company_state_id
                   left join flow.state s on s.id = cs.state_id
          WHERE u.id = :id
    """;


}
