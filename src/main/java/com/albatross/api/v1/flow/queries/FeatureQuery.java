package com.albatross.api.v1.flow.queries;

public class FeatureQuery {

  //language=PostgreSQL
  public final static String getAll = """
    select f.id,
              f.feature_name,
              f.feature_code,
              f.archived,
              f.is_system
       from flow.feature f
       where f.archived is not true
       order by f.feature_name
       """;

  //language=PostgreSQL
  public final static String getCompanyTools = """
    select cf.id,
              cf.feature_name,
              f.feature_code,
              f.feature_path,
              f.is_system,
              cf.archived
       from flow.company_feature cf
           inner join flow.feature f on f.id = cf.feature_id
       where company_id = :companyId
       and cf.archived is not true
       and f.archived is not true
       and f.is_system is not true
       order by cf.feature_name
       """;

  //language=PostgreSQL
  public final static String getHomePagesForCompany = """
    select cf.id,
               cf.feature_name,
               f.feature_code,
               f.feature_path,
               f.is_system,
               cf.archived
        from flow.company_feature cf
                 inner join flow.feature f on f.id = cf.feature_id
        where company_id = :companyId
          and cf.archived is not true
          and f.archived is not true
          and cf.home_page is true
        order by cf.feature_name
        """;

  //language=PostgreSQL
  public final static String getAllForCompany = """
    select cf.id,
              cf.feature_name,
              cf.company_id,
              cf.feature_id,
              cf.archived,
              f.feature_code,
              f.is_system
       from flow.company_feature cf
           inner join flow.feature f on f.id = cf.feature_id
       where cf.company_id = :companyId
       and cf.archived is not true
       and cf.hidden is not true
       order by cf.feature_name
       """;

  //language=PostgreSQL
  public final static String getAllForCompanyWithAccess = """
    select cf.id,
           cf.feature_name,
           cf.company_id,
           cf.feature_id,
           cf.archived,
           coalesce((
                        SELECT array_to_json(array_agg(row_to_json(accessControl)))
                        FROM (
                                 select ac.id,
                                        ac.access_level as "accessLevel",
                                        ac.access_code as "accessCode",
                                        false as enabled
                                 from flow.access_control ac
                                 where ac.archived is not true
                                 order by ac.display_order
                             ) accessControl), '[]') AS "accessControl"
    from flow.company_feature cf
    where cf.company_id = :companyId
      and cf.archived is not true
      and cf.hidden is not true
    order by cf.feature_name
    """;

  //language=PostgreSQL
  public final static String getForUser = """
    select cf.id,
           cf.feature_name as "featureName",
           cf.company_id as "companyId",
           cf.feature_id as "featureId",
           cf.archived,
           cf.hidden,
           coalesce((
                        SELECT array_to_json(array_agg(row_to_json(accessControl)))
                        FROM (
                                 select ufac.id,
                                        ufac.user_id as "userId",
                                        ufac.company_feature_id as "companyFeatureId",
                                        ac.id as "accessControlId",
                                        ac.access_level as "accessLevel",
                                        ac.access_code as "accessCode",
                                        ufac.enabled,
                                        coalesce(( select true from flow.feature_access_control fac where fac.access_control_id = ac.id and fac.feature_id = cf.feature_id), false) as "usedByFeature"
                                 from flow.access_control ac
                                          left join flow.user_feature_access_control ufac on ac.id = ufac.access_control_id
                                   and ufac.company_feature_id = cf.id
                                    and ufac.user_id = :userId
                                 order by ac.display_order
                             ) accessControl), '[]') AS "accessControl"
          from flow.company_feature cf
          where cf.company_id = :companyId
            and cf.archived is not true
          order by cf.feature_name
        """;

  //language=PostgreSQL
  public final static String getPositionAccessForUser = """
    select distinct cf.feature_id,
               cf.feature_name,
               f.feature_code,
               cf.hidden,
               ac.access_code,
               pac.enabled,
               coalesce(( select true from flow.feature_access_control fac where fac.access_control_id = ac.id and fac.feature_id = cf.feature_id), false) as "usedByFeature"
        from flow.position_feature_access_control pac
             inner join flow.position p on p.id = pac.position_id and p.company_id = :companyId
             inner join flow.company_feature cf on cf.id = pac.company_feature_id
             inner join flow.company c on c.id = cf.company_id and c.id = :companyId
             inner join flow.user_position up on up.position_id = pac.position_id and up.user_id = :userId
             inner join flow.feature f on f.id = cf.feature_id
             inner join flow.access_control ac on ac.id = pac.access_control_id
        WHERE pac.enabled is true
        and up.archived is not true
          and up.start_date <= now()
          and (up.end_date is null or up.end_date >= now())
          and cf.company_id = :companyId
        """;

  //language=PostgreSQL
  public final static String getAccessForUser = """
    WITH t as (
        select feature_id, cf.feature_name, f.feature_code, ac.access_code, uac.enabled
            from flow.user_feature_access_control uac
                     inner join flow.company_feature cf on cf.id = uac.company_feature_id
                     inner join flow.company c on c.id = :companyId
                     inner join flow.feature f on f.id = cf.feature_id
                     inner join flow.access_control ac on ac.id = uac.access_control_id
            where user_id = :userId
              and cf.archived is not true
              and enabled is true
              and cf.company_id = :companyId
        )
       SELECT *
       FROM T
       UNION
       select distinct feature_id,
              cf.feature_name,
              f.feature_code,
              ac.access_code,
              pac.enabled
       from flow.position_feature_access_control pac
            inner join flow.position p on p.id = pac.position_id and p.company_id = :companyId
            inner join flow.company_feature cf on cf.id = pac.company_feature_id
            inner join flow.company c on c.id = cf.company_id and c.id = :companyId
            inner join flow.user_position up on up.position_id = pac.position_id and up.user_id = :userId
            inner join flow.feature f on f.id = cf.feature_id
            inner join flow.access_control ac on ac.id = pac.access_control_id
       WHERE pac.enabled is true
       and up.archived is not true
         and up.start_date <= now()
         and cf.archived is not true
         and (up.end_date is null or up.end_date >= now())
         and cf.company_id = :companyId
       """;

  //language=PostgreSQL
  public final static String getMasqueradedUserFeatureAccess = """
    with masq_user_access as (
            WITH t as (
            select feature_id, cf.feature_name, f.feature_code, ac.access_code, uac.enabled
            from flow.user_feature_access_control uac
                   inner join flow.company_feature cf on cf.id = uac.company_feature_id
                   inner join flow.company c on c.id = :companyId
                   inner join flow.feature f on f.id = cf.feature_id
                   inner join flow.access_control ac on ac.id = uac.access_control_id
            where user_id = :userId
              and cf.archived is not true
              and enabled is true
              and cf.company_id = :companyId
          )
                                    SELECT *
                                    FROM t
                                    UNION
                                    select distinct feature_id,
                                                    cf.feature_name,
                                                    f.feature_code,
                                                    ac.access_code,
                                                    pac.enabled
                                    from flow.position_feature_access_control pac
                                           inner join flow.position p on p.id = pac.position_id and p.company_id = :companyId
                                           inner join flow.company_feature cf on cf.id = pac.company_feature_id
                                           inner join flow.company c on c.id = cf.company_id and c.id = :companyId
                                           inner join flow.user_position up
                                                      on up.position_id = pac.position_id and up.user_id = :userId
                                           inner join flow.feature f on f.id = cf.feature_id
                                           inner join flow.access_control ac on ac.id = pac.access_control_id
                                    WHERE pac.enabled is true
                                      and up.archived is not true
                                      and up.start_date <= now()
                                      and cf.archived is not true
                                      and (up.end_date is null or up.end_date >= now())
                                      and cf.company_id = :companyId
          )
          select *
          from masq_user_access mua
          where exists(
                    WITH t1 as (
                      select feature_id, cf2.feature_name, f2.feature_code, ac2.access_code, uac2.enabled
                      from flow.user_feature_access_control uac2
                             inner join flow.company_feature cf2 on cf2.id = uac2.company_feature_id
                             inner join flow.company c2 on c2.id = :companyId
                             inner join flow.feature f2 on f2.id = cf2.feature_id
                             inner join flow.access_control ac2 on ac2.id = uac2.access_control_id
                      where user_id = :trueUserId
                        and mua.feature_id = cf2.feature_id
                        and mua.feature_code = f2.feature_code
                        and mua.feature_name = cf2.feature_name
                        and mua.access_code = ac2.access_code
                        and mua.enabled = uac2.enabled
                        and cf2.archived is not true
                        and enabled is true
                        and cf2.company_id = :companyId
                    )
                    SELECT *
                    FROM t1
                    UNION
                    select distinct feature_id,
                                    cf3.feature_name,
                                    f3.feature_code,
                                    ac3.access_code,
                                    pac3.enabled
                    from flow.position_feature_access_control pac3
                           inner join flow.position p3 on p3.id = pac3.position_id and p3.company_id = :companyId
                           inner join flow.company_feature cf3 on cf3.id = pac3.company_feature_id
                           inner join flow.company c3 on c3.id = cf3.company_id and c3.id = :companyId
                           inner join flow.user_position up3
                                      on up3.position_id = pac3.position_id and up3.user_id = :trueUserId
                           inner join flow.feature f3 on f3.id = cf3.feature_id
                           inner join flow.access_control ac3 on ac3.id = pac3.access_control_id
                    WHERE pac3.enabled is true
                      and up3.archived is not true
                      and mua.feature_id = cf3.feature_id
                      and mua.feature_code = f3.feature_code
                      and mua.feature_name = cf3.feature_name
                      and mua.access_code = ac3.access_code
                      and mua.enabled = pac3.enabled
                      and up3.start_date <= now()
                      and cf3.archived is not true
                      and (up3.end_date is null or up3.end_date >= now())
                      and cf3.company_id = :companyId
                  )
        """;

  //language=PostgreSQL
  public final static String upsertUserFeatureAccessControl = """
    insert into flow.user_feature_access_control(company_feature_id, access_control_id, user_id, enabled)
    values (:companyFeatureId, :accessControlId, :userId, true)
    ON CONFLICT (user_id, company_feature_id, access_control_id)
      DO UPDATE SET enabled = :enabled, date_modified = now()
    """;

  //language=PostgreSQL
  public final static String getOneCompanyFeature = """
    select cf.id,
           cf.feature_name,
           cf.company_id,
           cf.feature_id,
           cf.archived,
           f.is_system,
           f.feature_code
    from flow.company_feature cf
        inner join flow.feature f on f.id = cf.feature_id
    where cf.id = :id
    """;

  //language=PostgreSQL
  public final static String insertCompanyFeature = """
    insert into flow.company_feature(feature_name, company_id, feature_id)
    values (:featureName, :companyId, :featureId)
    """;

  //language=PostgreSQL
  public final static String updateCompanyFeature = """
    update flow.company_feature
        set feature_name = :featureName
    where id = :id
    """;

  //language=PostgreSQL
  public final static String deleteCompanyFeature = """
    update flow.company_feature
        set archived = true
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getOneFeature = """
    select f.id,
           f.feature_name,
           f.feature_code,
           f.archived,
           f.is_system
    from flow.feature f
    where f.id = :id
    """;

  //language=PostgreSQL
  public final static String insertFeature = """
    insert into flow.feature(feature_name, feature_code, is_system)
     values (:featureName, :featureCode, :isSystem)
     """;

  //language=PostgreSQL
  public final static String updateFeature = """
    update flow.feature
        set feature_name = :featureName,
            feature_code = :featureCode,
            is_system = :isSystem
    where id = :id
    """;

  //language=PostgreSQL
  public final static String deleteFeature = """
    update flow.feature
        set archived = true
    where id = :id
    """;

}
