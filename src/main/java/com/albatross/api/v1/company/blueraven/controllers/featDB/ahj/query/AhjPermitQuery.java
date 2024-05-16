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
            lov.name as metro_area,
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
                FROM brs.feat_db_ahj_permit_link apl
                WHERE apl.archived IS FALSE
                  AND apl.link_type_id = 12
                  AND apl.ahj_permit_id = p.id
                order by apl.date_created
                  ) links
                ), '[]'
              ) AS links
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

  public final static String searchAhjsByMetro = """
         SELECT p.id, p.ahj_id
         FROM brs.feat_db_ahj_permit p
           INNER JOIN brs.feat_db_ahj ahj ON ahj.id = p.ahj_id
           LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
         WHERE lov.id = :metroId
           AND ahj.archived IS FALSE
    """;

  //language=PostgreSQL
  public final static String getAhjHistory = """
        select
            cf.id,
            cf.field_name,
            case
                when dt.id = 1 then apcfva.old_value::text
                when dt.id = 2 then
                  case
                      when EXTRACT(HOUR FROM TO_TIMESTAMP(apcfva.old_value, 'YYYY-MM-DD HH24:MI:SS')) < 12 THEN to_char(TO_TIMESTAMP(apcfva.old_value, 'YYYY-MM-DD HH24:MI:SS'), 'MM/DD/YYYY HH12:MI:SS AM')
                      when EXTRACT(HOUR FROM TO_TIMESTAMP(apcfva.old_value, 'YYYY-MM-DD HH24:MI:SS')) > 12 THEN to_char(TO_TIMESTAMP(apcfva.old_value, 'YYYY-MM-DD HH24:MI:SS'), 'MM/DD/YYYY HH12:MI:SS PM')
                  end
                when dt.id = 6 and cdt.has_list_values is false then apcfva.old_value
                when dt.id = 6 and cdt.has_list_values is true then (
                    select lov.name from brs.list_of_value lov where lov.id = apcfva.old_value::bigint
                )::text
                when dt.id = 5 then apcfva.old_value
                when dt.id = 4 then apcfva.old_value::text
                when dt.id = 7 then (
                  with ids as (select unnest(string_to_array(substring(apcfva.old_value from '[0-9, ]+'), ','))::int AS int_id)
                  select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
                when dt.id = 13 then apcfva.old_value::text
                end as previous_value,
            case
                when dt.id = 1 then apcfva.new_value::text
                when dt.id = 2 then
                  case
                      when EXTRACT(HOUR FROM TO_TIMESTAMP(apcfva.new_value, 'YYYY-MM-DD HH24:MI:SS')) < 12 THEN to_char(TO_TIMESTAMP(apcfva.new_value, 'YYYY-MM-DD HH24:MI:SS'), 'MM/DD/YYYY HH12:MI:SS AM')
                      when EXTRACT(HOUR FROM TO_TIMESTAMP(apcfva.new_value, 'YYYY-MM-DD HH24:MI:SS')) > 12 THEN to_char(TO_TIMESTAMP(apcfva.new_value, 'YYYY-MM-DD HH24:MI:SS'), 'MM/DD/YYYY HH12:MI:SS PM')
                  end
                when dt.id = 6 and cdt.has_list_values is false then apcfva.new_value
                when dt.id = 6 and cdt.has_list_values is true then (
                    select lov.name from brs.list_of_value lov where lov.id = apcfva.new_value::bigint
                )::text
                when dt.id = 5 then apcfva.new_value
                when dt.id = 4 then apcfva.new_value::text
                when dt.id = 7 then (
                  with ids as (select unnest(string_to_array(substring(apcfva.new_value from '[0-9, ]+'), ','))::int AS int_id)
                  select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
              when dt.id = 13 then apcfva.new_value::text
                end as updated_value,
            apcfva.date_modified,
            concat(u.first_name, ' ', u.last_name) as modified_by
        from brs.feat_db_ahj_permit_custom_field_value_audit apcfva
                 join brs.feat_db_ahj_permit_custom_field_value adcfv on adcfv.id = apcfva.ahj_permit_custom_field_value_id
                 join brs.feat_db_ahj_permit ahjd on adcfv.ahj_permit_id = ahjd.id
                 join brs.feat_db_ahj ahj on ahjd.ahj_id = ahj.id
                 join brs.custom_field_group_assignment cfga on adcfv.custom_field_group_assignment_id = cfga.id
                 join brs.custom_field cf on cfga.custom_field_id = cf.id
                 join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                 join flow.data_type dt on cdt.data_type_id = dt.id
                 join flow."user" u on apcfva.modified_by_id= u.id
        where ahj_id = :ahjId
        order by apcfva.date_modified desc;
    """;



}
