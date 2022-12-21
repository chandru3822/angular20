package com.albatross.api.v1.flow.queries;

public class RoleQuery {

  //language=PostgreSQL
  public final static String getAllForCompany = """
    select r.id,
                 r.role_name,
                 r.archived
          from flow.role r
          where r.archived is not true
          and r.company_id = :companyId
          order by r.role_name
        """;

  //language=PostgreSQL
  public final static String updateRole = """
    update flow.role
          set role_name = :roleName
        where id = :id
        """;

  //language=PostgreSQL
  public final static String archiveRole = """
    update flow.role
      set archived = true
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertRole = """
    insert into flow.role (company_id, role_name)
    values (:companyId, :roleName)
    """;

  //language=PostgreSQL
  public final static String getOne = """
    select r.id,
               r.role_name,
               r.archived,
               coalesce((
                   SELECT array_to_json(array_agg(row_to_json(companyFeatures)))
                   FROM (
                            select cf.id,
                                   cf.feature_name as "featureName",
                                   cf.company_id as "companyId",
                                   cf.feature_id as "featureId",
                                   cf.archived,
                                   coalesce((
                                        SELECT array_to_json(array_agg(row_to_json(accessControl)))
                                        FROM (
                                                 select rfac.id,
                                                        rfac.role_id as "roleId",
                                                        rfac.company_feature_id as "companyFeatureId",
                                                        ac.id as "accessControlId",
                                                        ac.access_level as "accessLevel",
                                                        ac.access_code as "accessCode",
                                                        rfac.enabled
                                                 from flow.access_control ac
                                                          left join flow.role_feature_access_control rfac on ac.id = rfac.access_control_id
                                                                                                                 and rfac.company_feature_id = cf.id
                                                                                                                 and rfac.role_id = r.id
                                                 order by "accessControlId"
                                             ) accessControl), '[]') AS "accessControl"
                            from flow.company_feature cf
                            where cf.company_id = :companyId
                              and cf.archived is not true
                    ) companyFeatures), '[]') AS "companyFeatures"
        from flow.role r
        where r.id = :id
        """;

  //language=PostgreSQL
  public final static String insertRoleFeatureAccessControl = """
    insert into flow.role_feature_access_control(company_feature_id, access_control_id, role_id, enabled)
    values (:companyFeatureId, :accessControlId, :roleId, true)
    """;

  //language=PostgreSQL
  public final static String updateRoleFeatureAccessControl = """
    update flow.role_feature_access_control
    set enabled = :enabled
    where id = :roleFeatureAccessControlId
    """;

}
