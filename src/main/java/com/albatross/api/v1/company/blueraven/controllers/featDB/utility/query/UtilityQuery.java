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
                 u.archived,
                 u.active
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
             modified_by_id = :currentUser,
             active = :active
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
            modified_by_id = :currentUser,
            active = :active
          WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String insert = """
           INSERT INTO brs.feat_db_utility(name, archived,  metro_area_id, company_state_id, date_created, created_by_id,date_modified, modified_by_id, active)
           VALUES (:utilityName, false, :metroAreaId, :companyStateId,now(), :currentUser, now(), :currentUser, true)
    """;

  //language=PostgreSQL
  public final static String delete = """
    UPDATE brs.feat_db_utility
          SET
            archived = true,
            active = false,
            date_modified = now(),
            modified_by_id = :userId
          WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String restore = """
    UPDATE brs.feat_db_utility
          SET archived = false,
              active = true,
              date_modified = now(),
              modified_by_id = :userId
          WHERE id = :id and archived = true
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

  //language=PostgreSQL
  public final static String getUtilityHistory = """
        select
          cf.id,
          cf.field_name,
          case
              when dt.id = 1 then ucfva.old_value::text
              when dt.id = 2 then ucfva.old_value
              when dt.id = 6 and cdt.has_list_values = true then
                case
                    when ucfva.old_value ~ '^[0-9]+$' then (select lov.name from brs.list_of_value lov where lov.id = ucfva.old_value::bigint)::text
                    else ucfva.old_value
                end
              when dt.id = 6 then ucfva.old_value
              when dt.id = 5 then ucfva.old_value
              when dt.id = 4 then ucfva.old_value::text
              when dt.id = 7 then (
                with ids as (select unnest(string_to_array(substring(ucfva.old_value from '[0-9, ]+'), ','))::int AS int_id)
                select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
              when dt.id = 13 then ucfva.old_value::text
              end as previous_value,
          case
              when dt.id = 1 then ucfva.new_value::text
              when dt.id = 2 then ucfva.new_value
              when dt.id = 6 and cdt.has_list_values = true then
                case
                    when ucfva.new_value ~ '^[0-9]+$' then (select lov.name from brs.list_of_value lov where lov.id = ucfva.new_value::bigint)::text
                    else ucfva.new_value
                end
              when dt.id = 6 then ucfva.new_value
              when dt.id = 5 then ucfva.new_value
              when dt.id = 4 then ucfva.new_value::text
              when dt.id = 7 then (
                with ids as (select unnest(string_to_array(substring(ucfva.new_value from '[0-9, ]+'), ','))::int AS int_id)
                select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
              when dt.id = 13 then ucfva.new_value::text
              end as updated_value,
          ucfva.date_modified,
          concat(u.first_name, ' ', u.last_name) as modified_by,
          dt.id as dataType
        from brs.feat_db_utility_custom_field_value_audit ucfva
                 join brs.feat_db_utility_custom_field_value adcfv on adcfv.id = ucfva.utility_custom_field_value_id
                 join brs.feat_db_utility util on adcfv.utility_id = util.id
                 join brs.custom_field_group_assignment cfga on adcfv.custom_field_group_assignment_id = cfga.id
                 join brs.custom_field cf on cfga.custom_field_id = cf.id
                 join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                 join flow.data_type dt on cdt.data_type_id = dt.id
                 join flow."user" u on ucfva.modified_by_id= u.id
        where utility_id = :utilityId
        order by ucfva.date_modified desc;
    """;

  //language=PostgreSQL
  public final static String utilityArchiveStatus = """
    select archived from brs.feat_db_utility where id = :id;
    """;

}
