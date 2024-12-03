package com.albatross.api.v1.flow.queries;

public class UserPositionQuery {

  //language=PostgreSQL
  public final static String getAll = """
    select distinct upv.user_position_id as id,
                    upv.user_id,
                    upv.archived,
                    upv.primary_flag,
                    upv.start_date,
                    upv.end_date,
                    upv.position,
                    upv.position_id,
                    upv.company_id,
                    upv.sales_org_id,
                    upv.sales_org_name,
                    uphv.hierarchy,
                    p.use_slot_schedule
          from flow.user_positions_vw upv
            inner join flow.user_position_hierarchy_vw uphv on uphv.user_id = upv.user_id and uphv.org_id = upv.org_id and uphv.position_id = upv.position_id
            inner join flow.position p on p.id = upv.position_id
          where upv.company_id = :companyId
            and upv.user_id = :userId
            and upv.archived is not true
          order by upv.start_date desc
    """;

  //language=PostgreSQL
  public final static String getAvailableSalesOrgs = """
    select *
      from brs.get_available_sales_orgs(:orgId::bigint,:positionId::bigint);
    """;

    //language=PostgreSQL
    public final static String getUserPositionIdsForOrgPosition = """
        select upv.user_position_id 
            from flow.user_positions_vw upv 
            where position_id = :positionId and org_id=:orgId
    """;


  //language=PostgreSQL
  public final static String getAllActive = """
    select distinct upv.user_position_id as id,
                    upv.user_id,
                    upv.archived,
                    upv.primary_flag,
                    upv.start_date,
                    upv.end_date,
                    upv.sales_org_id,
                    upv.sales_org_name,
                    upv.position,
                    upv.position_id,
                    upv.company_id
            from flow.user_positions_vw upv
            where upv.user_id = :userId
              and ((upv.end_date is null and upv.start_date <= now())
                     OR now() between upv.start_date and upv.end_date)
              and upv.archived is not true
            order by upv.start_date desc
    """;

  //language=PostgreSQL
  public final static String getOne = """
    select distinct upv.user_position_id as id,
                    upv.user_id,
                    upv.archived,
                    upv.primary_flag,
                    upv.start_date,
                    upv.end_date,
                    upv.sales_org_id,
                    upv.sales_org_name,
                    upv.position,
                    upv.position_id,
                    upv.company_id,
                    uphv.hierarchy
          from flow.user_positions_vw upv
            inner join flow.user_position_hierarchy_vw uphv on uphv.user_id = upv.user_id and uphv.org_id = upv.org_id and uphv.position_id = upv.position_id
          where upv.user_position_id = :id
    """;

  //language=PostgreSQL
  public final static String getUserPrimaryPosition = """
    select up.id,
    	up.user_id,
    	up.archived,
    	up.primary_flag,
    	up.sales_org_id,
    	up.org_id,
    	(select org_name
    	 from flow.org o
    	 where o.id = up.sales_org_id) as sales_org_name,
    	up.start_date,
    	up.end_date,
    	p.position,
    	up.position_id,
    	p.company_id
    from flow.user_position up
    inner join flow.position p on up.position_id = p.id
    where up.user_id = :userId
    	and p.company_id = :companyId
    	and up.archived is not true
    	and up.primary_flag is true
    	and up.archived is false
    """;

  //language=PostgreSQL
  public final static String delete = """
    update flow.user_position
        set archived = true,
            date_modified = now(),
            modified_by_id = :userId
    where id = :userPositionId
    """;

  //language=PostgreSQL
  public final static String updateUserPosition = """
    update flow.user_position
            set position_id = :positionId,
                start_date = :startDate::date,
                end_date = :endDate::date,
                org_id = :orgId,
                sales_org_id = :salesOrgId,
                date_modified = now(),
                modified_by_id = :modifiedById,
                primary_flag = :primaryFlag
        where id = :id
    """;

  //language=PostgreSQL
  public final static String insertUserPosition = """
    insert into flow.user_position(user_id, position_id, start_date, end_date, org_id, primary_flag, created_by_id, date_created, modified_by_id, date_modified, sales_org_id)
      values (:userId, :positionId, :startDate::date, :endDate::date, :orgId, :primaryFlag, :createdById, now(), :createdById, now(), :salesOrgId)
    """;

  //language=PostgreSQL
  public final static String resetPrimaryFlags = """
    update flow.user_position
        set primary_flag = false,
        date_modified = now()
    where id in (select up.id
                 from flow.user_position up
                          inner join flow.position p on p.id = up.position_id
                 where up.user_id = :userId
                   and p.company_id = :companyId
                   and up.id != :id
    )
    """;

  //language=PostgreSQL
  public final static String getPrimaryPosition = """
    select id, user_id, position_id, org_id, primary_flag
        from flow.user_position
    where primary_flag = true and user_id = :userId and archived = false
    """;

  public final static String getSmartlistUsers= """
           select distinct upv.user_id::bigint as user_id,
                           upv.user_position_id as id,
                           concat(upv.first_name,' ',upv.last_name::text) as full_name,
                           upv.position,
                           upv.position_id,
                           upv.primary_flag
           from flow.user_positions_vw upv
           	     inner join flow.position_feature_access_control pac on upv.position_id = pac.position_id and upv.company_id = :companyId
           	     inner join flow.company_feature cf on cf.id = pac.company_feature_id and cf.feature_id = 19
           where
           		pac.enabled = true and
           		upv.company_id = :companyId and
           	    upv.has_access is true and
           	    (upv.start_date <= now() and (upv.end_date IS NULL OR upv.end_date > now())) and
           	    upv.primary_flag is true
          union
           select distinct u.id::bigint as user_id,
                           upv.user_position_id as id,
                           concat(u.first_name,' ',u.last_name::text) as full_name,
                           upv.position,
                           upv.position_id,
                           upv.primary_flag
           from flow.access_control ac
           	     inner join flow.user_feature_access_control ufac on ac.id = ufac.access_control_id
           	     inner join flow.company_feature cf on cf.id = ufac.company_feature_id
           	     inner join flow."user" u on u.id = ufac.user_id
                  inner join flow.user_positions_vw upv on u.id = upv.user_id and upv.primary_flag = true
           where
           	cf.has_permissions is true and
           	ufac.enabled = true and
           	(upv.start_date <= now() and (upv.end_date IS NULL OR upv.end_date > now())) and
           	cf.feature_id = 19
           """;


  //language=PostgreSQL
  public final static String getPrimaryUserPositions = """
    select
      distinct upv.user_id::bigint as user_id,
      upv.user_position_id as id,
      concat(upv.first_name,' ',upv.last_name::text) as full_name,
      upv.position,
      upv.primary_flag
    from flow.user_positions_vw upv
    where
      upv.company_id = :companyId and
      upv.has_access is true and
      (upv.start_date <= now() and (upv.end_date IS NULL OR upv.end_date > now())) and
      upv.primary_flag is true
    order by full_name
  """;
}
