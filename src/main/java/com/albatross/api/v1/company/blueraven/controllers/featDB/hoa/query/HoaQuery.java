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
                 h.date_created as "dateCreated",
                 h.archived,
                 h.active
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
            modified_by_id = :currentUser,
            active = :active
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
            modified_by_id = :currentUser,
            active = :active
          WHERE id = :id
    """;

  //language=PostgreSQL
    public final static String delete = """
        UPDATE brs.feat_db_hoa
            SET archived = TRUE,
                date_modified = now(),
                modified_by_id = :currentUser,
                active = FALSE
            WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String restore = """
    UPDATE brs.feat_db_hoa
          SET archived = false,
              active = true,
              date_modified = now(),
              modified_by_id = :userId
          WHERE id = :id and archived = true
    """;

  //language=PostgreSQL
  public final static String insert = """
          INSERT INTO brs.feat_db_hoa(name, archived, company_state_id, management_company_id, date_created, created_by_id,date_modified, modified_by_id, active)
          VALUES (:hoaName, false, :companyStateId, :managementCompanyId, now(), :currentUser, now(), :currentUser, true)
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

  //language=PostgreSQL
  public final static String getHoaHistory = """
    select
        cf.id,
        cf.field_name as "fieldName",
        case
            when dt.id = 1 then hcfva.old_value::text
            when dt.id = 2 then hcfva.old_value
            when dt.id = 6 and cdt.has_list_values = true then
              case
                  when hcfva.new_value ~ '^[0-9]+$' then (select lov.name from brs.list_of_value lov where lov.id = hcfva.old_value::bigint)::text
                  else hcfva.new_value
              end
            when dt.id = 6 then hcfva.old_value
            when dt.id = 5 then hcfva.old_value
            when dt.id = 4 then hcfva.old_value::text
            when dt.id = 7 then (
              with ids as (select unnest(string_to_array(substring(hcfva.old_value from '[0-9, ]+'), ','))::int AS int_id)
              select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
            when dt.id = 13 then hcfva.old_value::text
            end as previousValue,
        case
            when dt.id = 1 then hcfva.new_value::text
            when dt.id = 2 then hcfva.new_value
            when dt.id = 6 and cdt.has_list_values = true then
              case
                  when hcfva.new_value ~ '^[0-9]+$' then (select lov.name from brs.list_of_value lov where lov.id = hcfva.new_value::bigint)::text
                  else hcfva.new_value
              end
            when dt.id = 6 then hcfva.new_value
            when dt.id = 5 then hcfva.new_value
            when dt.id = 4 then hcfva.new_value::text
            when dt.id = 7 then (
              with ids as (select unnest(string_to_array(substring(hcfva.new_value from '[0-9, ]+'), ','))::int AS int_id)
              select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
            when dt.id = 13 then hcfva.new_value::text
            end as updatedValue,
        hcfva.date_modified as dateModified,
        concat(u.first_name, ' ', u.last_name) as modifiedBy,
        dt.id as "dataType"
    from brs.feat_db_hoa_custom_field_value_audit hcfva
             join brs.feat_db_hoa_custom_field_value adcfv on adcfv.id = hcfva.hoa_custom_field_value_id
             join brs.feat_db_hoa hoa on adcfv.hoa_id = hoa.id
             join brs.custom_field_group_assignment cfga on adcfv.custom_field_group_assignment_id = cfga.id
             join brs.custom_field cf on cfga.custom_field_id = cf.id
             join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
             join flow.data_type dt on cdt.data_type_id = dt.id
             join flow."user" u on hcfva.modified_by_id= u.id
    where hoa_id = :hoaId
    order by hcfva.date_modified desc
    """;
}
