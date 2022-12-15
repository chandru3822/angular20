package com.albatross.api.v1.flow.queries;

public class SmartlistQueryv2 {

  //language=PostgreSQL
  public final static String getMine = """
    select
      s.*,
      ot.object_type,
      cot.object_type_id,
      concat(u.first_name, ' ', u.last_name) "owner"
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    left join flow.object_type ot1 on ot1.id = s.view_object_type_id
    inner join flow.user u on u.id = s.owner_id
    where
      cot.company_id = :companyId and
      s.owner_id = :userId and
      s.archived is not true and
      s.work_queue_type_id is null
    """;

  //language=PostgreSQL
  public final static String getPublic = """
    select
      s.*,
      ot.object_type,
      cot.object_type_id,
      concat(u.first_name, ' ', u.last_name) "owner"
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    left join flow.object_type ot1 on ot1.id = s.view_object_type_id
    inner join flow.user u on u.id = s.owner_id
    where
      cot.company_id = :companyId and
      s.public and
      s.archived is not true and
      s.work_queue_type_id is null
    """;
}
