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
  public final static String getAllActive = """
    select distinct upv.user_position_id as id,
                    upv.user_id,
                    upv.archived,
                    upv.primary_flag,
                    upv.start_date,
                    upv.end_date,
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
    select distinct upv.user_position_id as id,
                       upv.user_id,
                       upv.archived,
                       upv.primary_flag,
                       upv.start_date,
                       upv.end_date,
                       upv.position,
                       upv.position_id,
                       upv.company_id
       from flow.user_positions_vw upv
       where upv.user_id = :userId
       and upv.company_id = :companyId
       and upv.archived is not true
       and upv.primary_flag is true
       and upv.archived is false
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
                date_modified = now(),
                modified_by_id = :modifiedById,
                primary_flag = :primaryFlag
        where id = :id
        """;

  //language=PostgreSQL
  public final static String insertUserPosition = """
    insert into flow.user_position(user_id, position_id, start_date, end_date, org_id, primary_flag, created_by_id, date_created, modified_by_id, date_modified)
      values (:userId, :positionId, :startDate::date, :endDate::date, :orgId, :primaryFlag, :createdById, now(), :createdById, now())
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

}
