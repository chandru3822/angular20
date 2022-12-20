package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query;

public class AhjPermitQuery {

  //language=PostgreSQL
  public final static String detailByAhj = """
    SELECT
            p.*,
            ahj.metro_area_id,
            ahj.name as ahj_name,
            cs.state_id,
            s.state AS "stateName",
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
                  INNER JOIN brs.feat_db_ahj_permit_contact apc ON c.id = apc.ahj_contact_id
                WHERE apc.ahj_permit_id = p.id AND c.archived IS FALSE AND c.contact_type_id = 1
                order by c.name
              ) contacts), '[]'
            ) AS submissionContacts,
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
                  INNER JOIN brs.feat_db_ahj_permit_contact apc ON c.id = apc.ahj_contact_id
                WHERE apc.ahj_permit_id = p.id AND c.archived IS FALSE AND c.contact_type_id = 6
                order by c.name
              ) contacts), '[]'
            ) AS followUpContacts,
            coalesce((
              SELECT array_to_json(array_agg(row_to_json(links)))
              FROM (
                SELECT
                  apl.id,
                  apl.link_type_id,
                  apl.name,
                  apl.link,
                  apl.username,
                  apl.password,
                  apl.notes
                FROM brs.feat_db_ahj_permit_link apl
                WHERE apl.archived IS FALSE
                  AND apl.link_type_id = 4
                  AND apl.ahj_permit_id = p.id
                order by apl.name
                  ) links
                ), '[]'
              ) AS submissionLinks,
            coalesce((
              SELECT array_to_json(array_agg(row_to_json(links)))
              FROM (
                SELECT
                  apl.id,
                  apl.link_type_id,
                  apl.name,
                  apl.link,
                  apl.username,
                  apl.password,
                  apl.notes
                FROM brs.feat_db_ahj_permit_link apl
                WHERE apl.archived IS FALSE
                  AND apl.link_type_id = 5
                  AND apl.ahj_permit_id = p.id
                order by apl.name
                  ) links
              ), '[]'
            ) AS followUpLinks
          FROM brs.feat_db_ahj_permit p
            INNER JOIN brs.feat_db_ahj ahj ON ahj.id = p.ahj_id
            LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
             left join flow.company_state cs on cs.id = ahj.company_state_id
             left join flow.state s on s.id = cs.state_id
          WHERE p.ahj_id = :ahjId
    """;

  //language=PostgreSQL
  public final static String create = """
        INSERT INTO brs.feat_db_ahj_permit(ahj_id, date_created, created_by_id, date_modified, modified_by_id)
        VALUES(:ahjId, now(), :currentUser, now(), :currentUser)
    """;

  //language=PostgreSQL
  public final static String searchAhjsByState = """
         SELECT p.id, p.ahj_id
         FROM brs.feat_db_ahj_permit p
           INNER JOIN brs.feat_db_ahj ahj ON ahj.id = p.ahj_id
           LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
            left join flow.company_state cs on cs.id = ahj.company_state_id
         WHERE cs.state_id = :stateId
           AND ahj.archived IS FALSE
    """;


}
