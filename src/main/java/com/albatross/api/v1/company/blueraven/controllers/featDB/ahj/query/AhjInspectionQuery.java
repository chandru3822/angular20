package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query;

public class AhjInspectionQuery {

  //language=PostgreSQL
  public final static String detailByAhj = """
    SELECT
              i.*,
              ahj.metro_area_id,
              ahj.name as ahj_name,
              cs.id as company_state_id,
              cs.state_id,
              s.state AS "stateName",
              s.abbreviation AS "stateAbbreviation",
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
                                        c.hours,
                                        c.contact_type_id as "contactTypeId"
                                    FROM brs.feat_db_contact c
                                             INNER JOIN brs.feat_db_ahj_inspection_contact aic ON c.id = aic.ahj_contact_id
                                    WHERE aic.ahj_inspection_id = i.id AND c.archived IS FALSE AND c.contact_type_id = 9) contacts
                       ), '[]'
                  ) AS utility_service_dept_contacts,
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
                                             INNER JOIN brs.feat_db_ahj_inspection_contact aic ON c.id = aic.ahj_contact_id
                                    WHERE aic.ahj_inspection_id = i.id AND c.archived IS FALSE AND c.contact_type_id = 2) contacts
                       ), '[]'
                  ) AS scheduling_contacts,
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
                                             INNER JOIN brs.feat_db_ahj_inspection_contact aic ON c.id = aic.ahj_contact_id
                                    WHERE aic.ahj_inspection_id = i.id AND c.archived IS FALSE AND c.contact_type_id = 3) contacts
                       ), '[]'
                  ) AS obtaining_results_contacts,
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
                                             INNER JOIN brs.feat_db_ahj_inspection_contact aic ON c.id = aic.ahj_contact_id
                                    WHERE aic.ahj_inspection_id = i.id
                                      AND c.archived IS FALSE
                                      AND c.contact_type_id = 4) contacts
                       ), '[]'
                  ) AS fee_contacts,
              coalesce((
                           SELECT array_to_json(array_agg(row_to_json(links)))
                           FROM (
                                    SELECT
                                        apl.id,
                                        apl.name,
                                        apl.link,
                                        apl.username,
                                        apl.link_type_id AS "linkTypeId",
                                        apl.password,
                                        apl.notes
                                    FROM brs.feat_db_ahj_inspection_link apl
                                    WHERE apl.archived IS FALSE
                                      AND apl.link_type_id = 1
                                      AND apl.ahj_inspection_id = i.id) links
                       ), '[]'
                  ) AS schedulingLinks,
              coalesce((
                           SELECT array_to_json(array_agg(row_to_json(links)))
                           FROM (
                                    SELECT
                                        apl.id,
                                        apl.name,
                                        apl.link,
                                        apl.username,
                                        apl.link_type_id AS "linkTypeId",
                                        apl.password,
                                        apl.notes
                                    FROM brs.feat_db_ahj_inspection_link apl
                                    WHERE apl.archived IS FALSE
                                      AND apl.link_type_id = 2
                                      AND apl.ahj_inspection_id = i.id) links
                       ), '[]'
                  ) AS fotLinks,
              coalesce((
                           SELECT array_to_json(array_agg(row_to_json(links)))
                           FROM (
                                    SELECT
                                        apl.id,
                                        apl.name,
                                        apl.link,
                                        apl.username,
                                        apl.link_type_id AS "linkTypeId",
                                        apl.password,
                                        apl.notes
                                    FROM brs.feat_db_ahj_inspection_link apl
                                    WHERE apl.archived IS FALSE
                                      AND apl.link_type_id = 3
                                      AND apl.ahj_inspection_id = i.id) links
                       ), '[]'
                  ) AS resultsLinks,
              coalesce((
                           SELECT array_to_json(array_agg(row_to_json(fots)))
                           FROM (
                                    SELECT
                                        upv.user_id AS "id",
                                        upv.first_name AS "firstName",
                                        upv.last_name AS "lastName",
                                        concat(upv.first_name,' ',upv.last_name) AS "fullName",
                                        (select array_to_json(array_agg(row_to_json(fots)))
                                         from (select o.id AS "orgId",
                                                      upv.org_level_id AS "orgLevelId",
                                                      o.org_name AS "orgName",
                                                      upv.position_level AS "positionLevel"
                                               from flow.org o
                                               where o.id = upv.org_id) fots
                                        ) AS "hierarchy"
                                    FROM flow.user_positions_vw upv
                                             INNER JOIN flow.org o ON o.id = upv.org_id
                                             LEFT JOIN flow.organization_custom_field_value ocfv ON ocfv.org_id = o.id and ocfv.custom_field_group_assignment_id = 19097
                                             LEFT JOIN brs.feat_db_ahj ahj2 ON ahj2.metro_area_id = ocfv.int_value
                                    WHERE upv.end_date IS NULL
                                      AND upv.user_archived IS FALSE
                                      and upv.archived is not true
                                      AND upv.primary_flag IS TRUE
                                      AND o.org_type_id = 8
                                      AND ahj2.id = i.ahj_id) fots
                       ), '[]'
                  ) AS servicingFots
          FROM brs.feat_db_ahj_inspection i
                   INNER JOIN brs.feat_db_ahj ahj ON ahj.id = i.ahj_id
                   LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
                   left join flow.company_state cs on cs.id = ahj.company_state_id
                   left join flow.state s on s.id = cs.state_id
          WHERE i.ahj_id = :ahjId
    """;

  //language=PostgreSQL
  public final static String findById = """
     SELECT i.*,
                  ahj.metro_area_id,
                  cs.state_id,
                  s.state AS "stateName"
           FROM brs.feat_db_ahj_inspection i
                    INNER JOIN brs.feat_db_ahj ahj ON ahj.id = i.ahj_id
                    LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
                    left join flow.company_state cs on cs.id = ahj.company_state_id
                    left join flow.state s on s.id = cs.state_id
           WHERE i.id = :id
    """;

  //language=PostgreSQL
  public final static String create = """
    INSERT INTO brs.feat_db_ahj_inspection (ahj_id, date_created, created_by_id, date_modified, modified_by_id)
        VALUES (:ahjId, now(), :currentUser, now(), :currentUser)
    """;

  //language=PostgreSQL
  public final static String searchAhjsByState = """
           SELECT i.id, i.ahj_id
           FROM brs.feat_db_ahj_inspection i
                    INNER JOIN brs.feat_db_ahj ahj ON ahj.id = i.ahj_id
                    INNER JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
                    LEFT JOIN flow.company_state cs on cs.id = ahj.company_state_id
           WHERE cs.state_id = :stateId
             AND ahj.archived IS FALSE
    """;


}
