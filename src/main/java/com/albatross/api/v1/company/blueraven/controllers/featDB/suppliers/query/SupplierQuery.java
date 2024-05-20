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

    //language=PostgreSQL
    public final static String getSupplierHistory = """
      select
          cf.id,
          cf.field_name,
          case
              when dt.id = 1 then scfva.old_value::text
              when dt.id = 2 then scfva.old_value
              when dt.id = 6 and cdt.has_list_values = true then
                case
                    when scfva.new_value ~ '^[0-9]+$' then (select lov.name from brs.list_of_value lov where lov.id = scfva.old_value::bigint)::text
                    else scfva.new_value
                end
              when dt.id = 6 then scfva.old_value
              when dt.id = 5 then scfva.old_value
              when dt.id = 4 then scfva.old_value::text
              when dt.id = 7 then (
              with ids as (select unnest(string_to_array(substring(scfva.old_value from '[0-9, ]+'), ','))::int AS int_id)
              select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
            when dt.id = 13 then scfva.old_value::text
              end as previous_value,
          case
              when dt.id = 1 then scfva.new_value::text
              when dt.id = 2 then scfva.new_value
              when dt.id = 6 and cdt.has_list_values = true then
                case
                    when scfva.new_value ~ '^[0-9]+$' then (select lov.name from brs.list_of_value lov where lov.id = scfva.new_value::bigint)::text
                    else scfva.new_value
                end
              when dt.id = 6 then scfva.new_value
              when dt.id = 5 then scfva.new_value
              when dt.id = 4 then scfva.new_value::text
              when dt.id = 7 then (
                with ids as (select unnest(string_to_array(substring(scfva.new_value from '[0-9, ]+'), ','))::int AS int_id)
                select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
              when dt.id = 13 then scfva.new_value::text
              end as updated_value,
          scfva.date_modified,
          concat(u.first_name, ' ', u.last_name) as modified_by,
          dt.id as dataType
      from brs.feat_db_supplier_custom_field_value_audit scfva
               join brs.feat_db_supplier_custom_field_value scfv on scfv.id = scfva.feat_db_supplier_custom_field_value_id
               join brs.feat_db_supplier supplier on scfv.feat_db_supplier_id = supplier.id
               join brs.custom_field_group_assignment cfga on scfv.custom_field_group_assignment_id = cfga.id
               join brs.custom_field cf on cfga.custom_field_id = cf.id
               join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
               join flow.data_type dt on cdt.data_type_id = dt.id
               join flow."user" u on scfva.modified_by_id= u.id
      where feat_db_supplier_id = :supplierId
      order by scfva.date_modified desc
      """;


}
