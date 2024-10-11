package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query;

public class AhjNewHomeQuery {

  //language=PostgreSQL
  public final static String detailByAhj = """
    SELECT
              i.*,
              ahj.metro_area_id,
              ahj.name as ahj_name,
              cs.id as company_state_id,
              cs.state_id,
              s.state AS "stateName",
              lov.name as metro_area,
              s.abbreviation AS "stateAbbreviation",
              ahj.archived,
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
                  INNER JOIN brs.feat_db_ahj_new_home_contact apc ON c.id = apc.ahj_contact_id
                WHERE apc.ahj_new_home_id = i.id AND c.archived IS FALSE AND c.contact_type_id = 14
                order by c.name
              ) contacts), '[]'
            ) AS contacts,
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
                FROM brs.feat_db_ahj_new_home_link apl
                WHERE apl.archived IS FALSE
                  AND apl.link_type_id = 15
                  AND apl.ahj_new_home_id = i.id
                order by apl.date_created
                  ) links
                ), '[]'
              ) AS links
          FROM brs.feat_db_ahj_new_home i
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
           FROM brs.feat_db_ahj_new_home i
                    INNER JOIN brs.feat_db_ahj ahj ON ahj.id = i.ahj_id
                    LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
                    left join flow.company_state cs on cs.id = ahj.company_state_id
                    left join flow.state s on s.id = cs.state_id
           WHERE i.id = :id
    """;

  //language=PostgreSQL
  public final static String create = """
    INSERT INTO brs.feat_db_ahj_new_home (ahj_id, date_created, created_by_id, date_modified, modified_by_id)
        VALUES (:ahjId, now(), :currentUser, now(), :currentUser)
    """;

  //language=PostgreSQL
  public final static String searchAhjsByState = """
           SELECT i.id, i.ahj_id
           FROM brs.feat_db_ahj_new_home i
                    INNER JOIN brs.feat_db_ahj ahj ON ahj.id = i.ahj_id
                    INNER JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
                    LEFT JOIN flow.company_state cs on cs.id = ahj.company_state_id
           WHERE cs.state_id = :stateId
             AND ahj.active IS TRUE
    """;

  //language=postgresql
  public final static String searchAhjsByMetro = """
         SELECT i.id, i.ahj_id
         FROM brs.feat_db_ahj_new_home i
           INNER JOIN brs.feat_db_ahj ahj ON ahj.id = i.ahj_id
           LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
         WHERE lov.id = :metroId
           AND ahj.active IS TRUE
    """;

  //language=PostgreSQL
  public final static String getAhjHistory = """
        select
          cf.id,
          cf.field_name,
          case
              when dt.id = 1 then aicfva.old_value::text
              when dt.id = 2 then aicfva.old_value
              when dt.id = 6 and cdt.has_list_values = true then
                  case
                      when aicfva.old_value ~ '^[0-9]+$' then (select lov.name from brs.list_of_value lov where lov.id = aicfva.old_value::bigint)::text
                      else aicfva.old_value
                  end
              when dt.id = 6 then aicfva.old_value
              when dt.id = 5 then aicfva.old_value
              when dt.id = 4 then aicfva.old_value::text
              when dt.id = 7 then (
              with ids as (select unnest(string_to_array(substring(aicfva.old_value from '[0-9, ]+'), ','))::int AS int_id)
                select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
                when dt.id = 13 then aicfva.old_value::text
              end as previous_value,
          case
              when dt.id = 1 then aicfva.new_value::text
              when dt.id = 2 then aicfva.new_value
              when dt.id = 6 and cdt.has_list_values = true then
                  case
                      when aicfva.new_value ~ '^[0-9]+$' then (select lov.name from brs.list_of_value lov where lov.id = aicfva.new_value::bigint)::text
                      else aicfva.new_value
                  end
              when dt.id = 6 then aicfva.new_value
              when dt.id = 5 then aicfva.new_value
              when dt.id = 4 then aicfva.new_value::text
              when dt.id = 7 then (
              with ids as (select unnest(string_to_array(substring(aicfva.new_value from '[0-9, ]+'), ','))::int AS int_id)
                select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
                when dt.id = 13 then aicfva.new_value::text
              end as updated_value,
          aicfva.date_modified,
          concat(u.first_name, ' ', u.last_name) as modified_by
        from brs.feat_db_ahj_new_home_custom_field_value_audit aicfva
                 join brs.feat_db_ahj_new_home_custom_field_value adcfv on adcfv.id = aicfva.ahj_new_home_custom_field_value_id
                 join brs.feat_db_ahj_new_home ahjd on adcfv.ahj_new_home_id = ahjd.id
                 join brs.feat_db_ahj ahj on ahjd.ahj_id = ahj.id
                 join brs.custom_field_group_assignment cfga on adcfv.custom_field_group_assignment_id = cfga.id
                 join brs.custom_field cf on cfga.custom_field_id = cf.id
                 join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                 join flow.data_type dt on cdt.data_type_id = dt.id
                 join flow."user" u on aicfva.modified_by_id= u.id
        where ahj_id = :ahjId
        order by aicfva.date_modified desc
""";

}
