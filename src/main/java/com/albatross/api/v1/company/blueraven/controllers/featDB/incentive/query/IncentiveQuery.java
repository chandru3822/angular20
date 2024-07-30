package com.albatross.api.v1.company.blueraven.controllers.featDB.incentive.query;

public class IncentiveQuery {


  //language=PostgreSQL
  public final static String list = """
    SELECT h.id,
                 h.name,
                 cs.id as company_state_id,
                 cs.state_id,
                 s.state,
                 lovit.id as type_id,
                 lovit.name as type,
                 lovis.id as status_id,
                 lovis.name as status,
                 s.abbreviation as state_abbreviation,
                 h.date_created as "dateCreated",
                 h.archived,
                 h.active
          FROM brs.feat_db_incentive h
                   left join brs.list_of_value lovit on lovit.id = h.type_id and lovit.parent_id = 452
                   left join brs.list_of_value lovis on lovis.id = h.status_id and lovis.parent_id = 2066
                   left join flow.company_state cs on cs.id = h.company_state_id
                   left join flow.state s on s.id = cs.state_id
          ORDER BY s.state, h.name
    """;

  //language=PostgreSQL
  public final static String simpleUpdate = """
          UPDATE brs.feat_db_incentive
          SET name = :incentiveName,
            archived = :archived,
            company_state_id = :companyStateId,
            type_id = :typeId,
            status_id = :statusId,
            date_modified = now(),
            modified_by_id = :currentUser,
            active = :active
          WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String update = """
          UPDATE brs.feat_db_incentive
          SET
            name = :incentiveName,
            archived = :archived,
            company_state_id = :companyStateId,
            type_id = :typeId,
            status_id = :statusId,
            date_modified = now(),
            modified_by_id = :currentUser,
            active = :active
          WHERE id = :id
    """;

  //language=PostgreSQL
    public final static String delete = """
        UPDATE brs.feat_db_incentive
            SET archived = TRUE,
                date_modified = now(),
                modified_by_id = :currentUser,
                active = FALSE
            WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String restore = """
    UPDATE brs.feat_db_incentive
          SET archived = false,
              active = true,
              date_modified = now(),
              modified_by_id = :userId
          WHERE id = :id and archived = true
    """;

  //language=PostgreSQL
  public final static String insert = """
          INSERT INTO brs.feat_db_incentive(name, archived, company_state_id, type_id, status_id, date_created, created_by_id,date_modified, modified_by_id, active)
          VALUES (:incentiveName, false, :companyStateId, :typeId, :statusId, now(), :currentUser, now(), :currentUser, true)
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
                                             INNER JOIN brs.feat_db_incentive_contact auc ON c.id = auc.feat_db_contact_id
                                    WHERE auc.feat_db_incentive_id = h.id AND c.archived IS FALSE AND c.contact_type_id = 13
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
                                    FROM brs.feat_db_incentive_link aul
                                    WHERE aul.archived IS FALSE
                                      AND aul.link_type_id = 14
                                      AND aul.feat_db_incentive_id = h.id) links
                       ), '[]') AS links
          FROM brs.feat_db_incentive h
                   left join brs.feat_db_incentive_custom_field_value fdicfvt on fdicfvt.int_value = h.type_id
                   left join brs.feat_db_incentive_custom_field_value fdicfvs on fdicfvs.int_value = h.status_id
                   left join flow.company_state cs on cs.id = h.company_state_id
                   left join flow.state s on s.id = cs.state_id
          WHERE h.id = :id
    """;

  //language=PostgreSQL
  public final static String listAllType = """
    SELECT
            lov.id,
            lov.name as "type",
            lov.archived
          FROM brs.list_of_value lov
          WHERE lov.parent_id = 452
            AND lov.archived IS FALSE
          ORDER BY lov.name
    """;

  //language=PostgreSQL
  public final static String getAllStatus= """
    SELECT
            lov.id,
            lov.name as "status",
            lov.archived
          FROM brs.list_of_value lov
          WHERE lov.parent_id = 2066
            AND lov.archived IS FALSE
          ORDER BY lov.name
    """;

  //language=PostgreSQL
  public final static String getIncentiveHistory = """
        select
          cf.id,
          cf.field_name,
          case
              when dt.id = 1 then icfva.old_value::text
              when dt.id = 2 then icfva.old_value
              when dt.id = 6 and cdt.has_list_values = true then
                case
                    when icfva.new_value ~ '^[0-9]+$' then (select lov.name from brs.list_of_value lov where lov.id = icfva.old_value::bigint)::text
                    else icfva.new_value
                end
              when dt.id = 6 then icfva.old_value
              when dt.id = 5 then icfva.old_value
              when dt.id = 4 then icfva.old_value::text
              when dt.id = 7 then (
                with ids as (select unnest(string_to_array(substring(icfva.old_value from '[0-9, ]+'), ','))::int AS int_id)
                select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
              when dt.id = 13 then icfva.old_value::text
              end as previous_value,
          case
              when dt.id = 1 then icfva.new_value::text
              when dt.id = 2 then icfva.new_value
              when dt.id = 6 and cdt.has_list_values = true then
                case
                    when icfva.new_value ~ '^[0-9]+$' then (select lov.name from brs.list_of_value lov where lov.id = icfva.new_value::bigint)::text
                    else icfva.new_value
                end
              when dt.id = 6 then icfva.new_value
              when dt.id = 5 then icfva.new_value
              when dt.id = 4 then icfva.new_value::text
              when dt.id = 7 then (
                with ids as (select unnest(string_to_array(substring(icfva.new_value from '[0-9, ]+'), ','))::int AS int_id)
                select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
              when dt.id = 13 then icfva.new_value::text
              end as updated_value,
          icfva.date_modified,
          concat(u.first_name, ' ', u.last_name) as modified_by,
          dt.id as dataType
      from brs.feat_db_incentive_custom_field_value_audit icfva
               join brs.feat_db_incentive_custom_field_value icfv on icfv.id = icfva.feat_db_incentive_custom_field_value_id
               join brs.feat_db_incentive incentive on icfv.feat_db_incentive_id = incentive.id
               join brs.custom_field_group_assignment cfga on icfv.custom_field_group_assignment_id = cfga.id
               join brs.custom_field cf on cfga.custom_field_id = cf.id
               join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
               join flow.data_type dt on cdt.data_type_id = dt.id
               join flow."user" u on icfva.modified_by_id= u.id
      where feat_db_incentive_id = :incentiveId
      order by icfva.date_modified desc
    """;
}
