package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query;

public class AhjDesignQuery {


  //language=PostgreSQL
  public final static String detailByAhj = """
          SELECT
            d.*,
            ahj.metro_area_id,
            ahj.name as ahj_name,
            cs.state_id,
            s.state AS "stateName",
            lov.name as metro_area
          FROM brs.feat_db_ahj_design d
            INNER JOIN brs.feat_db_ahj ahj ON ahj.id = d.ahj_id
            LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
             left join flow.company_state cs on cs.id = ahj.company_state_id
             left join flow.state s on s.id = cs.state_id
          WHERE d.ahj_id = :ahjId
    """;

  //language=PostgreSQL
  public final static String create = """
        INSERT INTO brs.feat_db_ahj_design(ahj_id, date_created, created_by_id, date_modified, modified_by_id)
        VALUES (:ahjId, now(), :currentUser, now(), :currentUser)
    """;

  //language=PostgreSQL
  public final static String searchAhjsByState = """
          SELECT d.id, d.ahj_id
          FROM brs.feat_db_ahj_design d
            INNER JOIN brs.feat_db_ahj ahj ON ahj.id = d.ahj_id
            LEFT JOIN flow.list_of_value lov ON lov.id = ahj.metro_area_id
             left join flow.company_state cs on cs.id = ahj.company_state_id
          WHERE cs.state_id = :stateId
            AND ahj.archived IS FALSE
    """;

  public final static String searchAhjsByMetro = """
         SELECT d.id, d.ahj_id
         FROM brs.feat_db_ahj_design d
           INNER JOIN brs.feat_db_ahj ahj ON ahj.id = d.ahj_id
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
                 when dt.id = 1 or dt.id = 2 then adcfva.old_value::text
                 when dt.id = 6 and cdt.has_list_values is false then adcfva.old_value
                 when dt.id = 6 and cdt.has_list_values is true then (
                     select lov.name from brs.list_of_value lov where lov.id = adcfva.old_value::bigint
                 )::text
                 when dt.id = 5 then adcfva.old_value
                 when dt.id = 4 then adcfva.old_value::text
                 when dt.id = 7 then (
                  with ids as (select unnest(string_to_array(substring(adcfva.old_value from '[0-9, ]+'), ','))::int AS int_id)
                  select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
                 when dt.id = 13 then adcfva.old_value::text
            end as previous_value,
            case
                when dt.id = 1 or dt.id = 2 then adcfva.new_value::text
                when dt.id = 6 and cdt.has_list_values is false then adcfva.new_value
                when dt.id = 6 and cdt.has_list_values is true then (
                    select lov.name from brs.list_of_value lov where lov.id = adcfva.new_value::bigint
                )::text
                when dt.id = 5 then adcfva.new_value
                when dt.id = 4 then adcfva.new_value::text
                when dt.id = 7 then (
                  with ids as (select unnest(string_to_array(substring(adcfva.new_value from '[0-9, ]+'), ','))::int AS int_id)
                  select array_to_string(array(select lov.name from brs.list_of_value lov where lov.id in (select int_id from ids)), ', '))
                when dt.id = 13 then adcfva.new_value::text
                end as updated_value,
            adcfva.date_modified,
            concat(u.first_name, ' ', u.last_name) as modified_by
        from brs.feat_db_ahj_design_custom_field_value_audit adcfva
                 join brs.feat_db_ahj_design_custom_field_value adcfv on adcfv.id = adcfva.ahj_design_custom_field_value_id
                 join brs.feat_db_ahj_design ahjd on adcfv.ahj_design_id = ahjd.id
                 join brs.feat_db_ahj ahj on ahjd.ahj_id = ahj.id
                 join brs.custom_field_group_assignment cfga on adcfv.custom_field_group_assignment_id = cfga.id
                 join brs.custom_field cf on cfga.custom_field_id = cf.id
                 join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                 join flow.data_type dt on cdt.data_type_id = dt.id
                 join flow."user" u on adcfva.modified_by_id= u.id
        where ahj_id = :ahjId
        order by adcfva.date_modified desc
    """;
}
