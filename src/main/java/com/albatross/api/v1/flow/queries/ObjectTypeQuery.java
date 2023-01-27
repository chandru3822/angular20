package com.albatross.api.v1.flow.queries;

public class ObjectTypeQuery {

  //language=PostgreSQL
  public final static String getCustomFieldGroupsAndValues = """
    select * from flow.get_cfgs_with_values(:objectTypeId::bigint, :sourceId::bigint, :secondaryId::bigint, :companyId::bigint, :systemAdmin::boolean, :userPositions::bigint[], false, false);
  """;

  //language=PostgreSQL
  public final static String getCompanyObjectTypes = """
    select cot.id,
           cot.id company_object_type_id,
           cot.object_type_id,
           ot.object_type,
           ot.flow_type_id,
           cot.company_id
    from flow.company_object_type cot
      inner join flow.object_type ot on ot.id = cot.object_type_id
    where cot.company_id = :companyId
    and cot.archived is not true
    """;

  //language=PostgreSQL
  public final static String getSmartlistCompanyObjectTypes = """
    select cot.id,
           cot.id company_object_type_id,
           cot.object_type_id,
           ot.object_type,
           ot.flow_type_id,
           cot.company_id
    from flow.company_object_type cot
           inner join flow.object_type ot on ot.id = cot.object_type_id
    where cot.company_id = :companyId
      and ot.smartlist is true
      and cot.archived is not true
    order by ot.object_type
    """;

  //language=PostgreSQL
  public final static String getCompanyObjectTypeDetail = """
select cot.id,
           cot.id company_object_type_id,
           cot.object_type_id,
           ot.object_type,
           ot.flow_type_id,
           cot.company_id,
           cot.archived,
           cot.status_read_only,
           cot.owner_read_only,
            coalesce((
              SELECT array_to_json(array_agg(row_to_json(wlp)))
              FROM (
                       SELECT wlp.id,
                              wlp.position_id as "positionId",
                              wlp.custom_field_group_assignment_id as "custom_field_group_assignment_id",
                              wlp.created_by_id as "createdById",
                              wlp.modified_by_id as "modifiedById",
                              wlp.archived
                       FROM flow.white_listed_position wlp
                       WHERE wlp.white_list_type_id = :statusReadOnlyTypeId
                         AND wlp.archived is not true) wlp), '[]') AS "statusReadOnlyWhiteListedPositions",
             coalesce((
                          SELECT array_to_json(array_agg(row_to_json(wlp)))
                          FROM (
                                   SELECT wlp.id,
                                          wlp.position_id as "positionId",
                                          wlp.custom_field_group_assignment_id as "custom_field_group_assignment_id",
                                          wlp.created_by_id as "createdById",
                                          wlp.modified_by_id as "modifiedById",
                                          wlp.archived
                                   FROM flow.white_listed_position wlp
                                   WHERE wlp.white_list_type_id = :ownerReadOnlyTypeId
                                     AND wlp.archived is not true) wlp), '[]') AS "ownerReadOnlyWhiteListedPositions"
    from flow.company_object_type cot
      inner join flow.object_type ot on ot.id = cot.object_type_id
    where cot.company_id = :companyId
    and cot.object_type_id = :objectTypeId
    and cot.archived is not true
    """;

  //language=PostgreSQL
  public final static String saveStatusReadOnly = """
    update flow.company_object_type
      set status_read_only = :statusReadOnly,
          date_modified = now(),
          modified_by_id = :userId
    where id = :companyObjectTypeId
    """;

  //language=PostgreSQL
  public final static String saveOwnerReadOnly = """
    update flow.company_object_type
      set owner_read_only = :ownerReadOnly,
          date_modified = now(),
          modified_by_id = :userId
    where id = :companyObjectTypeId
    """;

}
