package com.albatross.api.v1.flow.queries;

public class OperatorQuery {

  //language=PostgreSQL
  public final static String getTypesByDataType = """
            select ot.*
            from flow.operator_type ot
                inner join flow.operator_data_type odt on odt.operator_type_id = ot.id
            where ot.archived is not true
                and odt.archived is not true
                and odt.data_type_id = :dataTypeId
    """;



}
