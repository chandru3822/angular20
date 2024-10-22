package com.albatross.api.v1.company.blueraven.services.queries;

public class MetroAreaQuery {

  //language=PostgreSQL
  public final static String getAllActive = """
    SELECT
         lov.id,
         lov.name as "metroArea",
         lov.archived
       FROM flow.list_of_value lov
       WHERE lov.parent_id = 172
         AND lov.archived IS FALSE
       ORDER BY lov.name
    """;

  public final static String getAllowedModules = """
          select cf.field_name as "fieldName",
          	     cfv.text_value as "textValue"
          from brs.feat_db_ahj_design_custom_field_value cfv
          	inner join brs.feat_db_ahj_design d on d.id = cfv.ahj_design_id
          	inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
          	inner join brs.custom_field cf on cf.id = cfga.custom_field_id
          where d.ahj_id = (select id FROM brs.feat_db_ahj ahj where metro_area_id = :metroAreaId fetch first 1 rows only)
          	and cfv.custom_field_group_assignment_id in (491,492,493)
          """;
}
