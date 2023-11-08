package com.albatross.api.v1.company.blueraven.controllers.featDB.suppliers.query;

public class SupplierQuery {


  //language=PostgreSQL
  public final static String list = """
    SELECT h.id,
                 h.name,
                 cs.id as company_state_id,
                 cs.state_id,
                 s.state,
                 s.abbreviation as state_abbreviation,
                 h.date_created as "dateCreated",
                 h.archived
          FROM brs.feat_db_supplier h
                   left join flow.company_state cs on cs.id = h.company_state_id
                   left join flow.state s on s.id = cs.state_id
          ORDER BY s.state, h.name
    """;

  //language=PostgreSQL
  public final static String simpleUpdate = """
          UPDATE brs.feat_db_supplier
          SET name = :supplierName,
            archived = :archived,
            company_state_id = :companyStateId,
            date_modified = now(),
            modified_by_id = :currentUser
          WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String update = """
          UPDATE brs.feat_db_supplier
          SET
            name = :supplierName,
            archived = :archived,
            company_state_id = :companyStateId,
            date_modified = now(),
            modified_by_id = :currentUser
          WHERE id = :id
    """;

  //language=PostgreSQL
    public final static String delete = """
        UPDATE brs.feat_db_supplier
            SET archived = TRUE,
                date_modified = now(),
                modified_by_id = :currentUser
            WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String insert = """
          INSERT INTO brs.feat_db_supplier(name, archived, company_state_id, date_created, created_by_id,date_modified, modified_by_id)
          VALUES (:supplierName, false, :companyStateId, now(), :currentUser, now(), :currentUser)
    """;

  //language=PostgreSQL
  public final static String detailById = """
    SELECT
              h.*,
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
                                             INNER JOIN brs.feat_db_supplier_contact auc ON c.id = auc.feat_db_contact_id
                                    WHERE auc.feat_db_supplier_id = h.id AND c.archived IS FALSE AND c.contact_type_id = 11
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
                                    FROM brs.feat_db_supplier_link aul
                                    WHERE aul.archived IS FALSE
                                      AND aul.link_type_id = 13
                                      AND aul.feat_db_supplier_id = h.id) links
                       ), '[]') AS links
          FROM brs.feat_db_supplier h
                   left join flow.company_state cs on cs.id = h.company_state_id
                   left join flow.state s on s.id = cs.state_id
          WHERE h.id = :id
    """;


}
