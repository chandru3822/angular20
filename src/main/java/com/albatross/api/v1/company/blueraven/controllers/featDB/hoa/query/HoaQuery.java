package com.albatross.api.v1.company.blueraven.controllers.featDB.hoa.query;

public class HoaQuery {


  //language=PostgreSQL
  public final static String list = """
    SELECT h.id,
                 h.name,
                 cs.id as company_state_id,
                 cs.state_id,
                 s.state,
                 s.abbreviation as state_abbreviation,
                 lov.id as management_company_id,
                 lov.name as management_company,
                 h.archived
          FROM brs.feat_db_hoa h
                   left join brs.list_of_value lov on lov.id = h.management_company_id and lov.parent_id = 759
                   left join flow.company_state cs on cs.id = h.company_state_id
                   left join flow.state s on s.id = cs.state_id
          ORDER BY s.state, h.name
    """;

  //language=PostgreSQL
  public final static String simpleUpdate = """
          UPDATE brs.feat_db_hoa
          SET name = :hoaName,
            archived = :archived,
            company_state_id = :companyStateId,
            management_company_id = :managementCompanyId,
            date_modified = now(),
            modified_by_id = :currentUser
          WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String update = """
          UPDATE brs.feat_db_hoa
          SET
            name = :hoaName,
            archived = :archived,
            company_state_id = :companyStateId,
            management_company_id = :managementCompanyId,
            date_modified = now(),
            modified_by_id = :currentUser
          WHERE id = :id
    """;

  //language=PostgreSQL
    public final static String delete = """
        UPDATE brs.feat_db_hoa
            SET archived = TRUE,
                date_modified = now(),
                modified_by_id = :currentUser
            WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String insert = """
          INSERT INTO brs.feat_db_hoa(name, archived, company_state_id, management_company_id, date_created, created_by_id,date_modified, modified_by_id)
          VALUES (:hoaName, false, :companyStateId, :managementCompanyId, now(), :currentUser, now(), :currentUser)
    """;

  //language=PostgreSQL
  public final static String detailById = """
    SELECT
              h.*,
              mc.name as management_company,
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
                                             INNER JOIN brs.feat_db_hoa_contact auc ON c.id = auc.feat_db_contact_id
                                    WHERE auc.hoa_id = h.id AND c.archived IS FALSE AND c.contact_type_id = 10
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
                                    FROM brs.feat_db_hoa_link aul
                                    WHERE aul.archived IS FALSE
                                      AND aul.link_type_id = 11
                                      AND aul.hoa_id = h.id) links
                       ), '[]') AS links
          FROM brs.feat_db_hoa h
                   left join brs.list_of_value mc on mc.id = h.management_company_id
                   left join flow.company_state cs on cs.id = h.company_state_id
                   left join flow.state s on s.id = cs.state_id
          WHERE h.id = :id
    """;

  //language=PostgreSQL
  public final static String getActiveManagementCompanies = """
    SELECT
             lov.id,
             lov.name as "managementCompany",
             lov.archived
           FROM brs.list_of_value lov
           WHERE lov.parent_id = 759
             AND lov.archived IS FALSE
           ORDER BY lov.name
    """;

}
