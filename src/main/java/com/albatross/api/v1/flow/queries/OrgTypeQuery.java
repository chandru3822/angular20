package com.albatross.api.v1.flow.queries;

public class OrgTypeQuery {

  //language=PostgreSQL
  public final static String getAllForCompany = """
    select ot.*,
           parent.org_type as org_parent_type,
           ol.level
    from flow.org_type ot
             left join flow.org_type parent on parent.id = ot.org_parent_type_id
             inner join flow.org_level ol on ol.id = ot.org_level_id
    where ot.company_id = :companyId
    and ot.archived is false
    order by ol.level, ot.org_type
    """;

  //language=PostgreSQL
  public final static String getSchedulableForCompany = """
    select distinct ot.*,
       parent.org_type as org_parent_type,
       ol.level
    from flow.org_type ot
         left join flow.org_type parent on parent.id = ot.org_parent_type_id
         inner join flow.org_level ol on ol.id = ot.org_level_id
         inner join flow.org o on o.org_type_id = ot.id and o.schedulable is true and o.archived is not true
    where case when :isParent
            then ot.company_id = any (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
            else ot.company_id = :companyId end
      and  ot.archived is false
    order by ot.org_type
    """;

  //language=PostgreSQL
  public final static String getOne = """
    select ot.*,
           parent.org_type as org_parent_type,
           ol.level
    from flow.org_type ot
        left join flow.org_type parent on parent.id = ot.org_parent_type_id
        inner join flow.org_level ol on ol.id = ot.org_level_id
    where ot.id = :id
    """;

  //language=PostgreSQL
  public final static String updateOrgType = """
    update flow.org_type set
        org_type = :orgType,
        org_parent_type_id = :orgParentTypeId,
        org_level_id = :orgLevelId,
        archived = :archived,
        available_to_children = :availableToChildren,
        modified_by_id = :modifiedById,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertOrgType = """
insert into flow.org_type
  (org_type, org_parent_type_id, org_level_id, company_id, available_to_children, created_by_id, date_created, modified_by_id, date_modified)
  values (:orgType, :orgParentTypeId, :orgLevelId, :companyId, :availableToChildren, :createdById, now(), :createdById, now())
    """;

  //language=PostgreSQL
  public final static String getLevels = """
    select *
    from flow.org_level
    where company_id = :companyId
    order by level
    """;

  //language=PostgreSQL
  public final static String getOrgLevel = """
    select *
    from flow.org_level
    where id = :id
    """;

  //language=PostgreSQL
  public final static String deleteOrgLevel = """
    delete from flow.org_level
        where id = :id
    """;

  //language=PostgreSQL
  public final static String updateOrgLevel = """
    update flow.org_level
    set level_name = :levelName,
        level = :level
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertOrgLevel = """
    insert into flow.org_level(company_id, level, level_name)
    values (:companyId, :level, :levelName)
    """;

}
