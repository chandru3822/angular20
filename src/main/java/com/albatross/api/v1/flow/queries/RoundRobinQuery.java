package com.albatross.api.v1.flow.queries;

public class RoundRobinQuery {

  //language=PostgreSQL
  public final static String getRoundRobins = """
    select pcz.id,
            pcz.company_id,
            pcz.round_robin_name,
            pcz.remote,
            pcz.company_timezone_id,
            pcz.distribution_time_frame_days,
            pcz.schedulable_future_days,
            pcz.archived
        from flow.round_robin pcz
        where pcz.company_id = :companyId
        and pcz.archived is not true
        and case when :searchQuery::text is not null then
                     lower(translate(pcz.round_robin_name, '*,.&', '')) like '%' || lower(trim(translate(:searchQuery::text, '*,.&', ''))) || '%'
                OR pcz.id in (select pc.round_robin_id
                    from flow.postal_code pc
                    where pc.archived is not true
                    and pc.postal_code like '%' || :searchQuery::text || '%')
                OR pcz.id in (select distinct pczu.round_robin_id
                              from flow.round_robin_user pczu
                                       inner join flow."user" u on u.id = pczu.user_id
                                       inner join flow.company_user_status cus on cus.user_id = pczu.user_id
                                        inner join flow.user_status_type ust
                                                   on cus.user_status_type_id = ust.id and ust.has_access is true and ust.company_id = 3 and ust.archived is false
                              where pczu.archived is not true
                                AND lower(translate(coalesce(u.first_name, ''), '*,.& ', '')) || ' ' ||
                                    lower(translate(coalesce(u.last_name, ''), '*,.& ', '')) like
                                    '%' || lower(trim(translate(:searchQuery::text, '*,.&', ''))) || '%')
            else 1=1 end
        order by round_robin_name
        """;

  //language=PostgreSQL
  public final static String getRoundRobinsForUser = """
    with positions as (
           select up.org_id as parent_org_id,up.user_id as user_id
           from flow.user_position up
           where (up.end_date is null or up.end_date > now())
             -- judson had me change this: up.primary_flag is true
             and up.archived is not true
             and user_id = :userId
         )
         select pcz.id,
                pcz.company_id,
                pcz.round_robin_name,
                pcz.remote,
                pcz.company_timezone_id,
                pcz.distribution_time_frame_days,
                pcz.schedulable_future_days,
                pcz.archived
         from flow.round_robin pcz
         where pcz.company_id = :companyId
           and pcz.archived is not true
           and case when :viewAll::boolean is true
           then true
             when :viewCustom::boolean is true
             then
             exists (
                 with positions as (
                   select up.org_id as parent_org_id,up.user_id as user_id
                   from flow.user_position up
                   where (up.end_date is null or up.end_date > now())
                     -- judson had me change this: up.primary_flag is true
                     and up.archived is not true
                     and user_id = :userId
                 ), org_ids as (
                   select t.id
                   from positions p
                          join lateral flow.org_hierarchy_filter_down_search(array [p.parent_org_id]) as t
                               on true)
                 select distinct pczu.round_robin_id
                 from org_ids o
                        inner join flow.user_position up on up.org_id = o.id and (up.end_date is null or up.end_date > now()) and up.archived is false
                        inner join flow.round_robin_user pczu on pczu.user_id = up.user_id
                                                                        and pczu.round_robin_user_type_id = 1
                                                                        and pczu.archived is false
                                                                        and pczu.round_robin_id = pcz.id
               )
           else
             -- check that the user is in the zone as a schedule to
             exists (
               select pczu.round_robin_id
               from flow.round_robin_user pczu
               where pczu.round_robin_user_type_id = 1
               and pczu.archived is false
               and pczu.round_robin_id = pcz.id
               and pczu.user_id = :userId
               )
           end
         order by round_robin_name
       """;

  //language=PostgreSQL
  public final static String getRoundRobinByPostalCode = """
    select pcz.id,
          company_id,
          round_robin_name,
          pcz.remote,
          pcz.company_timezone_id,
          distribution_time_frame_days,
          schedulable_future_days
       from flow.round_robin pcz
           inner join flow.postal_code pc on pcz.id = pc.round_robin_id
       where company_id = :companyId
         and pcz.archived is not true
         and pc.archived is not true
         and pc.postal_code = :postalCode
       limit 1
       """;

  //language=PostgreSQL
  public final static String getScheduleToUsers = """
    select * from brs.get_allocation_by_round_robin(:roundRobinId::bigint, :currentUserId::bigint)
        """;

  //language=PostgreSQL
  public final static String getScheduleByUsers = """
    select pczu.id,
               pczu.user_id as "userId",
               u.first_name as "firstName",
               u.last_name as "lastName",
               concat(u.first_name, ' ', u.last_name) AS "fullName",
               pczu.round_robin_id as "roundRobinId",
               pczu.round_robin_user_type_id as "roundRobinUserTypeId",
               pczu.archived
        from flow.round_robin_user pczu
               inner join flow.user u on u.id = pczu.user_id
               inner join flow.company_user_status cus on cus.user_id = pczu.user_id
               inner join flow.user_status_type ust
                          on cus.user_status_type_id = ust.id and ust.has_access is true and ust.company_id = 3 and ust.archived is false
        where pczu.round_robin_id = :roundRobinId
          and pczu.archived is not true
          and pczu.round_robin_user_type_id = 2
        order by u.first_name, u.last_name
        """;

  //language=PostgreSQL
  public final static String getAssignedCodesForRoundRobin = """
    select pc.id,
              pc.postal_code as "postalCode",
              pc.round_robin_id as "roundRobinId",
              pc.archived
       from flow.postal_code pc
       where pc.round_robin_id = :roundRobinId
         and pc.active is true
         and pc.archived is not true
       order by pc.postal_code
       """;

  //language=PostgreSQL
  public final static String getAvaialbleCodesForRoundRobin = """
      select pc.id,
             pc.postal_code as "postalCode",
             pc.round_robin_id as "roundRobinId",
             pc.active,
             pc.archived
      from flow.postal_code pc
      where pc.archived is false
      and pc.active is true
      and pc.round_robin_id is null
      order by postal_code
       """;

  //language=PostgreSQL
  public final static String saveManualUserAllocation = """
    update flow.round_robin_user
        set manual_allocation = :manualAllocation,
            modified_by_id = :modifiedById,
            date_modified = now()
        where id = :rruId
        """;

  //language=PostgreSQL
  public final static String archiveInactiveUsers = """
    with updates as (
          select pczu.id
          from flow.round_robin_user pczu
                 inner join flow.round_robin pcz on pczu.round_robin_id = pcz.id
                 inner join flow.company_user_status cus on cus.user_id = pczu.user_id
                 inner join flow.user_status_type ust on cus.user_status_type_id = ust.id and ust.company_id = pcz.company_id
          where ust.has_access is false
            and pczu.archived is false
            and pczu.round_robin_user_type_id = 1
            and pcz.id = :roundRobinId
          order by round_robin_id
        )
        update flow.round_robin_user pczu
          set archived = true,
              modified_by_id = :modifiedById,
              date_modified = now()
        from updates u
        where u.id = pczu.id
        """;

  //language=PostgreSQL
  public final static String getRoundRobin = """
    select pcz.id,
               pcz.company_id,
               pcz.distribution_time_frame_days,
               pcz.schedulable_future_days,
               pcz.remote,
               pcz.company_timezone_id,
               t.timezone,
               pcz.round_robin_name,
               pcz.archived
        from flow.round_robin pcz
          left join flow.company_timezone ct on pcz.company_timezone_id = ct.id
          left join flow.timezone t on ct.timezone_id = t.id
        where pcz.id = :id
        """;

  //language=PostgreSQL
  public final static String insertRoundRobin = """
    insert into flow.round_robin(company_id, round_robin_name, distribution_time_frame_days, schedulable_future_days, company_timezone_id, created_by_id, date_created, modified_by_id, date_modified)
        values (:companyId, :roundRobinName, :distributionTimeFrameDays, :schedulableFutureDays, :companyTimezoneId, :createdById, now(), :createdById, now())
        """;

  //language=PostgreSQL
  public final static String updateRoundRobin = """
    update flow.round_robin
        set round_robin_name = :roundRobinName,
            company_timezone_id = :companyTimezoneId,
            distribution_time_frame_days = :distributionTimeFrameDays,
            schedulable_future_days = :schedulableFutureDays,
            modified_by_id = :modifiedById,
            date_modified = now()
        where id = :id
        """;

  //language=PostgreSQL
  public final static String deleteRoundRobin = """
    update flow.round_robin
        set archived = true,
            modified_by_id = :modifiedById,
            date_modified = now()
        where id = :id
        """;

  //language=PostgreSQL
  public final static String insertRoundRobinUser = """
    insert into flow.round_robin_user(round_robin_id, user_id, round_robin_user_type_id, company_timezone_id, created_by_id, date_created, modified_by_id, date_modified)
        values (:roundRobinId, :userId, :roundRobinUserTypeId, :companyTimezoneId, :createdById, now(), :createdById, now())
        """;

  //language=PostgreSQL
  public final static String updateRoundRobinUser = """
    update flow.round_robin_user
       set company_timezone_id = :companyTimezoneId,
           modified_by_id = :modifiedById,
           date_modified = now()
       where id = :rruId
       """;

  //language=PostgreSQL
  public final static String deleteRoundRobinUser = """
    update flow.round_robin_user
        set archived = true,
            modified_by_id = :modifiedById,
            date_modified = now()
        where id = :id
        """;

  //language=PostgreSQL
  public final static String getRoundRobinUser = """
    select pczu.id,
               pczu.round_robin_id,
               u.first_name,
               u.last_name,
               concat(u.first_name, ' ', u.last_name) AS full_name,
               pczu.user_id,
               pczu.company_timezone_id,
               t.timezone,
               pczu.round_robin_user_type_id,
               pczu.archived
        from flow.round_robin_user pczu
          inner join flow.user u on u.id = pczu.user_id
          left join flow.company_timezone ct on pczu.company_timezone_id = ct.id
          left join flow.timezone t on ct.timezone_id = t.id
        where pczu.id = :id
        """;

  //language=PostgreSQL
  public final static String updatePostalCode = """
    update flow.postal_code
         set archived = false,
             date_modified = now(),
             modified_by_id = :createdById,
             round_robin_id = :roundRobinId
         where id = :id
       """;


  //language=PostgreSQL
  public final static String deleteRoundRobinFromPostalCode = """
    update flow.postal_code
       set modified_by_id = :modifiedById,
           date_modified = now(),
           round_robin_id = null
     where id = :id
       """;

  //language=PostgreSQL
  public final static String getPostalCode = """
    select pc.id,
          pc.round_robin_id,
          pc.postal_code,
          pc.archived
       from flow.postal_code pc
       where pc.id = :id
       """;

  //language=PostgreSQL
  public final static String userCanSchedule = """
    select pczu.*
        from flow.round_robin_user pczu
                 inner join flow.round_robin pcz on pczu.round_robin_id = pcz.id
                 inner join flow.postal_code pc on pcz.id = pc.round_robin_id
        where pczu.user_id = :userId
          and pczu.archived is not true
          and pcz.company_id = :companyId
          and pc.postal_code = left(:postalCode, 5)
        """;

  //language=PostgreSQL
  public final static String userCanScheduleRemote = """
    select pczu.*
        from flow.round_robin_user pczu
               inner join flow.round_robin pcz on pczu.round_robin_id = pcz.id
        where pczu.user_id = :userId
          and pczu.archived is not true
          and pcz.company_id = :companyId
          and round_robin_user_type_id = 2
          and pcz.remote is true
        """;

  //language=PostgreSQL
  public final static String getAvailableRoundRobinUsers = """
    select distinct upv.user_id as id,
                    upv.first_name,
                    upv.position_id,
                    upv.last_name,
                    concat(upv.first_name, ' ', upv.last_name) AS full_name,
                    concat(upv.first_name, ' ', upv.last_name) AS title
          from flow.user_positions_vw upv
            inner join flow.org o on upv.org_id = o.id
          where case when :isParent and :isSchedulingTool
                         then upv.company_id = any (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
                     else (upv.company_id = :companyId OR (:isSchedulingTool AND upv.company_id = :parentCompanyId AND upv.available_to_children is true )) end
            and case when :loadSchedulers is true
                         then upv.position_scheduler is true
                     else upv.position_schedulable is true end
            and upv.user_archived is not true
            and upv.archived is not true
            and upv.has_access = true
            and upv.company_id = :companyId
            and upv.start_date <= now()
            and upv.primary_flag is true
            and (upv.end_date is null or upv.end_date >= now())
            and not exists (select pczu.user_id
                            from flow.round_robin_user pczu
                            where round_robin_id = :roundRobinId
                              and pczu.user_id = upv.user_id
                              and case when :loadSchedulers is true then pczu.round_robin_user_type_id = 2 else pczu.round_robin_user_type_id = 1 end
                              and archived is not true)
          order by full_name
        """;

  //language=PostgreSQL
  public final static String getAllRoundRobinUsers = """
    select pczu.id,
               pczu.user_id,
               u.first_name,
               u.last_name,
               pcz.round_robin_name,
               pczu.archived,
               pcz.id as round_robin_id,
               pczu.round_robin_user_type_id,
               concat(u.first_name, ' ', u.last_name) AS full_name,
               concat(u.first_name, ' ', u.last_name, ' - ', pcz.round_robin_name) AS title,
               coalesce((
                            SELECT array_to_json(array_agg(row_to_json(positions)))
                            FROM (
                                     SELECT up.id,
                                            up.user_id as "userId",
                                            up.id as "userPositionId",
                                            p.position,
                                            p.schedulable,
                                            p.scheduler,
                                            up.position_id as "positionId",
                                            up.org_id as "orgId",
                                            o.company_state_id as "companyStateId",
                                            up.start_date as "startDate",
                                            up.end_date as "endDate",
                                            up.primary_flag as "primaryFlag",
                                            up.archived,
                                            (select json_agg(json_build_object(
                                                                     'orgId', h.org_id,
                                                                     'orgName', h.org_name,
                                                                     'positionLevel', h.position_level,
                                                                     'orgLevelId', h.org_level_id
                                                                 ) order by h.org_level_id)::jsonb
                                             from flow.user_org_hierarchy(up.org_id) as h) as "hierarchy"
                                     FROM flow.user_position up
                                              inner join flow.position p on p.id = up.position_id
                                              inner join flow.org o on o.id = up.org_id
                                     WHERE up.user_id = pczu.user_id
                                       and up.archived is not true) positions), '[]') AS "userPositions"
        from flow.round_robin_user pczu
                 inner join flow.round_robin pcz on pcz.id = pczu.round_robin_id
            inner join flow."user" u on u.id = pczu.user_id
        where pczu.archived is not true
          and pcz.archived is not true
          and pcz.company_id = :companyId
          and pczu.round_robin_user_type_id = 1
          and ((cast(:roundRobinIds as int[]) is null) OR pczu.round_robin_id = any (:roundRobinIds))
        order by full_name
        """;

  //language=PostgreSQL
  public final static String getRoundRobinUsersByDownline = """
    select pczu.id,
               pczu.user_id,
               u.first_name,
               u.last_name,
               pcz.round_robin_name,
               pczu.archived,
               pcz.id as round_robin_id,
               pczu.round_robin_user_type_id,
               concat(u.first_name, ' ', u.last_name) AS full_name,
               concat(u.first_name, ' ', u.last_name, ' - ', pcz.round_robin_name) AS title,
               coalesce((
                          SELECT array_to_json(array_agg(row_to_json(positions)))
                          FROM (
                                 SELECT up.id,
                                        up.user_id as "userId",
                                        up.id as "userPositionId",
                                        p.position,
                                        p.schedulable,
                                        p.scheduler,
                                        up.position_id as "positionId",
                                        up.org_id as "orgId",
                                        o.company_state_id as "companyStateId",
                                        up.start_date as "startDate",
                                        up.end_date as "endDate",
                                        up.primary_flag as "primaryFlag",
                                        up.archived,
                                        (select json_agg(json_build_object(
                                                             'orgId', h.org_id,
                                                             'orgName', h.org_name,
                                                             'positionLevel', h.position_level,
                                                             'orgLevelId', h.org_level_id
                                                           ) order by h.org_level_id)::jsonb
                                         from flow.user_org_hierarchy(up.org_id) as h) as "hierarchy"
                                 FROM flow.user_position up
                                        inner join flow.position p on p.id = up.position_id
                                        inner join flow.org o on o.id = up.org_id
                                 WHERE up.user_id = pczu.user_id
                                   and up.archived is not true) positions), '[]') AS "userPositions"
        from flow.round_robin_user pczu
               inner join flow.round_robin pcz on pcz.id = pczu.round_robin_id
               inner join flow."user" u on u.id = pczu.user_id
               INNER JOIN flow.company_user_status cus on cus.user_id = pczu.user_id
                        INNER JOIN flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = pcz.company_id
        where pczu.archived is not true
          and pcz.archived is not true
          and ust.has_access is true
          and pcz.company_id = :companyId
          and pczu.round_robin_user_type_id = 1
          and ((cast(:roundRobinIds as int[]) is null) OR pczu.round_robin_id = any (:roundRobinIds))
          and case when :viewAll::boolean is true then true
          when :viewCustom::boolean is true
          then
            exists (
                with positions as (
                  select up.org_id as parent_org_id,up.user_id as user_id
                  from flow.user_position up
                  where (up.end_date is null or up.end_date > now())
                    -- judson had me change this: up.primary_flag is true
                    and up.archived is not true
                    and user_id = :userId
                ), org_ids as (
                  select t.id
                  from positions p
                         join lateral flow.org_hierarchy_filter_down_search(array [p.parent_org_id]) as t
                              on true)
                select distinct pczu2.round_robin_id
                from org_ids o
                       inner join flow.user_position up on up.org_id = o.id and (up.end_date is null or up.end_date > now()) and up.archived is false
                       inner join flow.round_robin_user pczu2 on pczu2.user_id = up.user_id
                  and pczu2.round_robin_user_type_id = 1
                  and pczu2.archived is false
                  and pczu2.id = pczu.id
              )
          else pczu.user_id = :userId end
        order by full_name
        """;

}
