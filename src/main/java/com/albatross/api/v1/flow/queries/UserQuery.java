package com.albatross.api.v1.flow.queries;

public class UserQuery {

  //language=PostgreSQL
  public final static String searchUsers = """
    with beat_off as (
             SELECT (value->'orgId')::bigint as org_id,vw.position_id,user_id, hierarchy, user_position_id
             FROM flow.user_position_hierarchy_vw vw
                      left join lateral jsonb_array_elements(vw.hierarchy) dr1
                                on true
         )
         select distinct upv.user_id as id,
                   upv.first_name,
                   upv.last_name,
                   upv.company_id,
                   concat(upv.first_name, ' ', upv.last_name) AS full_name,
                   upv.email,
                   upv.primary_flag,
                   upv.start_date,
                   upv.end_date,
                   upv.position,
                   upv.position_id,
                   upv.user_position_id,
                   upv.phone_number,
                   upv.phone_extension,
                   upv.user_status_type_id,
                   ust.user_status_type,
                   upv.has_access,
                   uphv.hierarchy
         from flow.user_positions_vw upv
               inner join beat_off uphv on uphv.user_id = upv.user_id and uphv.position_id = upv.position_id and uphv.org_id = upv.org_id and uphv.user_position_id = upv.user_position_id
               inner join flow.user_status_type ust on ust.id = upv.user_status_type_id
         where upv.company_id = :companyId
           and upv.archived is false
           and concat(upv.first_name, ' ', upv.last_name) ILIKE '%' || :query || '%'
           and upv.first_name ILIKE '%' || :firstName || '%'
           and upv.last_name ILIKE '%' || :lastName || '%'
           and coalesce(upv.email, '') ILIKE '%' || :email || '%'
           and coalesce(upv.phone_number, '') ILIKE '%' || :phone || '%'
           and case when :primaryFlag is true then upv.primary_flag = true else 1=1 end
           and case when array_length(ARRAY[ :statuses ]::bigint[], 1) > 0 then upv.user_status_type_id = any ( array[ :statuses ]::bigint[]) else 1 = 1 end
           and case when array_length(ARRAY[ :positions ]::bigint[], 1) > 0 then upv.position_id  = any( array[ :positions ]::bigint[] ) else 1=1 end
           and case when array_length(ARRAY[ :orgs ]::bigint[], 1) > 0 then upv.org_id = any( array [ :orgs ]::bigint[] ) else 1=1 end
         union
         select u.id,u.first_name,u.last_name,uc.company_id,
               concat(u.first_name, ' ', u.last_name) AS full_name,
                u.email,
                null,null,
                null,null,null, null,
                null,null,ust.id as user_status_type_id,
                ust.user_status_type, ust.has_access,null
         from flow."user" u
                  inner join flow.user_company uc on u.id = uc.user_id
                  inner join flow.user_status_type ust on ust.company_id = uc.company_id
                  inner join flow.company_user_status cus on cus.user_id = u.id and cus.user_status_type_id = ust.id
         where uc.company_id = :companyId
             and not exists (select up2.id from flow.user_position up2
                       inner join flow.position p on p.id = up2.position_id
                     where up2.user_id = u.id
                       and p.company_id = uc.company_id
                       and up2.archived is false)
           and concat(u.first_name, ' ', u.last_name) ILIKE '%' || :query || '%'
           and u.first_name ILIKE '%' || :firstName || '%'
           and u.last_name ILIKE '%' || :lastName || '%'
           and coalesce(u.email, '') ILIKE '%' || :email || '%'
           and case when array_length(ARRAY[ :positions ]::bigint[], 1) > 0 then false else 1=1 end
           and case when array_length(ARRAY[ :orgs ]::bigint[], 1) > 0 then false else 1=1 end
           and case when array_length(ARRAY[ :statuses ]::bigint[], 1) > 0 then cus.user_status_type_id = any ( array[ :statuses ]::bigint[]) else 1 = 1 end
           and coalesce(u.phone_number, '') ILIKE '%' || :phone || '%'
         order by last_name, first_name, start_date desc
         limit :limit
         offset :offset
       """;

  //language=PostgreSQL
  public final static String searchUserCount = """
    with t1 as (
            select distinct upv.user_id as id
            from flow.user_positions_vw upv
                inner join flow.user_position_hierarchy_vw uphv on uphv.user_id = upv.user_id
                                                         and uphv.position_id = upv.position_id
                                                         and uphv.org_id = upv.org_id
                inner join flow.user_status_type ust on ust.id = upv.user_status_type_id
            where upv.company_id = :companyId
              and upv.position_level = 0
              and concat(upv.first_name, ' ', upv.last_name) ILIKE '%' || :query || '%'
              and upv.first_name ILIKE '%' || :firstName || '%'
              and upv.last_name ILIKE '%' || :lastName || '%'
              and coalesce(upv.email, '') ILIKE '%' || :email || '%'
              and coalesce(upv.phone_number, '') ILIKE '%' || :phone || '%'
              and case when :primaryFlag::boolean is not null then upv.primary_flag = :primaryFlag else 1=1 end
              and case when array_length(ARRAY[ :statuses ]::bigint[], 1) > 0 then upv.user_status_type_id = any ( array[ :statuses ]::bigint[]) else 1 = 1 end
              and case when array_length(ARRAY[ :positions ]::bigint[], 1) > 0 then upv.position_id = any(array [ :positions ]::bigint[]) else 1=1 end
              and case when array_length(ARRAY[ :orgs ]::bigint[], 1) > 0 then upv.org_id  = any(array [ :orgs ]::bigint[]) else 1=1 end
           union
             select u.id
              from flow."user" u
                       inner join flow.user_company uc on u.id = uc.user_id
                       inner join flow.user_status_type ust on ust.company_id = uc.company_id
                        inner join flow.company_user_status cus on cus.user_id = u.id and cus.user_status_type_id = ust.id
              where uc.company_id = :companyId
                  and not exists (select up2.id from flow.user_position up2
                            inner join flow.position p on p.id = up2.position_id
                          where up2.user_id = u.id
                            and p.company_id = uc.company_id
                            and up2.archived is false)
                and concat(u.first_name, ' ', u.last_name) ILIKE '%' || :query || '%'
                and u.first_name ILIKE '%' || :firstName || '%'
                and u.last_name ILIKE '%' || :lastName || '%'
                and coalesce(u.email, '') ILIKE '%' || :email || '%'
                and case when array_length(ARRAY[ :positions ]::bigint[], 1) > 0 then false else 1=1 end
                and case when array_length(ARRAY[ :orgs ]::bigint[], 1) > 0 then false else 1=1 end
                and coalesce(u.phone_number, '') ILIKE '%' || :phone || '%'
                and case when array_length(ARRAY[ :statuses ]::bigint[], 1) > 0 then ust.id = any ( array[ :statuses ]::bigint[]) else 1 = 1 end
          )
         select count(*)
          from t1
        """;

  //language=PostgreSQL
  public final static String updateUser = """
    update flow."user"
          set first_name = trim(:firstName),
              last_name = trim(:lastName),
              email = trim(:email),
              notification_type_id = :notificationTypeId,
              username = trim(:username),
              phone_number = trim(:phone),
              phone_extension = trim(:phoneExtension),
              modified_by_id = :modifiedById,
              date_modified = now()
          where id = :id;
          update flow.user_company uc
              set home_page_company_feature_id = :homePageCompanyFeatureId,
                  date_modified = now()
          where uc.company_id = :companyId
            and uc.user_id = :id
        """;

  //language=PostgreSQL
  public final static String saveUserHomePage = """
      update flow.user_company uc
          set home_page_company_feature_id = :homePageCompanyFeatureId,
              date_modified = now()
      where uc.company_id = :companyId
        and uc.user_id = :userId
    """;

  //language=PostgreSQL
  public final static String insertUser = """
    insert into flow.user(first_name, last_name, phone_number, email, username, password, created_by_id, date_created, modified_by_id, date_modified)
      values(trim(:firstName), trim(:lastName), trim(:phone), trim(:email), trim(:email), :defaultPassword, :createdById, now(), :createdById, now())
        """;

  //language=PostgreSQL
  public final static String getOne = """
    select u.id,
          u.phone_number,
          u.phone_extension,
          u.email,
          u.notification_type_id,
          u.username,
          u.created_by_id,
          u.first_name,
          u.last_name,
          u.login_attempts,
          ( select p.position
           from flow.user_position up
           inner join flow.position p on p.id = up.position_id and p.company_id = uc.company_id
            where up.user_id = u.id
              and up.primary_flag is true
              and up.archived is not true
              limit 1
            ) as primary_position,
          concat(u.first_name, ' ', u.last_name) AS full_name,
          uc.company_id,
          u.modified_by_id,
          u.date_modified,
          u.default_company_id,
          ust.user_status_type,
          uc.home_page_company_feature_id,
          f.feature_path as home_page_path,
          ust.id as user_status_type_id,
          ust.has_access,
          coalesce((
                       SELECT array_to_json(array_agg(row_to_json(companies)))
                       FROM (
                                select c.id,
                                       c.company_name as "companyName",
                                       c.parent_company_id as "parentCompanyId",
                                       c.aws_bucket as "awsBucket",
                                       c.abbreviation
                                from flow.user_company uc
                                         inner join flow.company c on c.id = uc.company_id
                                where uc.user_id = u.id
                                  and uc.archived is not true
                                  and c.archived is not true
                                order by c.company_name
                            ) companies), '[]') as companies
         from flow."user" u
                  inner join flow.user_company uc on uc.user_id = u.id
                  inner join flow.company_user_status cus on cus.user_id = u.id
                  inner join flow.user_status_type ust on ust.company_id = uc.company_id and ust.id = cus.user_status_type_id
                  left join flow.company_feature cf on cf.company_id = uc.company_id and cf.id = uc.home_page_company_feature_id
                  left join flow.feature f on f.id = cf.feature_id
         where u.id = :id
           and uc.company_id = :companyId
           and uc.archived is not true
       """;

  //language=PostgreSQL
  public final static String getByIds = """
    select u.id,
           u.phone_number,
           u.phone_extension,
           u.email,
           u.notification_type_id,
           u.username,
           u.created_by_id,
           u.first_name,
           u.last_name,
           u.login_attempts,
           ( select p.position
            from flow.user_position up
            inner join flow.position p on p.id = up.position_id and p.company_id = uc.company_id
             where up.user_id = u.id
               and up.primary_flag is true
               and up.archived is not true
               limit 1
             ) as primary_position,
           concat(u.first_name, ' ', u.last_name) AS full_name,
           uc.company_id,
           u.modified_by_id,
           u.date_modified,
           u.default_company_id,
           ust.user_status_type,
           uc.home_page_company_feature_id,
           f.feature_path as home_page_path,
           ust.id as user_status_type_id,
           ust.has_access,
           coalesce((
                        SELECT array_to_json(array_agg(row_to_json(companies)))
                        FROM (
                                 select c.id,
                                        c.company_name as "companyName",
                                        c.parent_company_id as "parentCompanyId",
                                        c.aws_bucket as "awsBucket",
                                        c.abbreviation
                                 from flow.user_company uc
                                          inner join flow.company c on c.id = uc.company_id
                                 where uc.user_id = u.id
                                   and uc.archived is not true
                                   and c.archived is not true
                                 order by c.company_name
                             ) companies), '[]') as companies
          from flow."user" u
                   inner join flow.user_company uc on uc.user_id = u.id
                   inner join flow.company_user_status cus on cus.user_id = u.id
                   inner join flow.user_status_type ust on ust.company_id = uc.company_id and ust.id = cus.user_status_type_id
                   left join flow.company_feature cf on cf.company_id = uc.company_id and cf.id = uc.home_page_company_feature_id
                   left join flow.feature f on f.id = cf.feature_id
          where u.id in (:ids)
            and uc.company_id = :companyId
            and uc.archived is not true
        """;

  //language=PostgreSQL
  public final static String getAllActiveUsers = """
    select
      distinct upv.user_id::bigint as id,
      concat(upv.first_name,' ',upv.last_name::text) as full_name,
      upv.position
    from flow.user_positions_vw upv
    where
      upv.company_id = :companyId and
      upv.has_access is true and
      (upv.start_date <= now() and (upv.end_date IS NULL OR upv.end_date > now()))
    order by full_name
  """;

  //language=PostgreSQL
  public final static String getOneAlbatross = """
    select u.id,
                u.phone_number,
                u.phone_extension,
                u.email,
                u.notification_type_id,
                u.username,
                u.created_by_id,
                u.login_attempts,
                u.first_name,
                u.last_name,
                concat(u.first_name, ' ', u.last_name) AS full_name,
                u.modified_by_id,
                u.date_modified,
                u.default_company_id
         from flow."user" u
                  inner join flow.user_company uc on uc.user_id = u.id
         where u.id = :id
           and uc.company_id = 1
           and u.archived is not true
       """;

  //language=PostgreSQL
  public final static String getSchedulingUsers = """
    with t1 as (
              select distinct upv.user_id                            as id,
                              upv.first_name,
                              upv.last_name,
                              concat(upv.first_name, ' ', upv.last_name) AS full_name,
                              concat(upv.first_name, ' ', upv.last_name) AS title

              from flow.user_positions_vw upv
              where upv.position_schedulable is true
                and case
                        when :isParent and :isSchedulingTool
                            then upv.company_id = any (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
                        else (upv.company_id = :companyId OR
                              (:isSchedulingTool AND upv.company_id = :parentCompanyId AND upv.available_to_children is true)) end
                and case
                        when :companyStateId::bigint is not null
                            then upv.company_state_id = :companyStateId::bigint and upv.position_schedulable is true
                        else upv.position_schedulable is true end
                and upv.user_archived is not true
                and upv.start_date <= now()
                and upv.has_access is true
                and (upv.end_date is null or upv.end_date >= now())
          )
          select id,
                 first_name,
                 last_name,
                 full_name,
                 title,
                 coalesce((
                              SELECT array_to_json(array_agg(row_to_json(positions)))
                              FROM (
                                       SELECT up.id,
                                              up.user_id as "userId",
                                              p.position,
                                              p.schedulable,
                                              p.scheduler,
                                              up.position_id as "positionId",
                                              up.org_id as "orgId",
                                              p.use_slot_schedule as "useSlotSchedule",
                                              o.company_state_id as "companyStateId",
                                              cs.state_id as "stateId",
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
                                                left join flow.company_state cs on cs.id = o.company_state_id
                                       WHERE up.user_id = t1.id
                                         and up.archived is not true) positions), '[]') AS "userPositions"
          from t1
            order by full_name
        """;

  //language=PostgreSQL
  public final static String findByUsernameIgnoreCase = """
    with t1 as (
            select u.id,
                   u.first_name,
                   u.last_name,
                   u.password,
                   u.username,
                   u.email,
                   c.aws_bucket,
                   c.minute_increment,
                   c.api_path,
                   u.phone_number,
                   u.phone_extension,
                   u.login_attempts,
                   (select has_access
                    from flow.company_user_status cus
                           inner join flow.user_status_type ust on ust.id = cus.user_status_type_id
                    where user_id = u.id
                      and ust.company_id = uc.company_id
                   )                                                                                        as has_access,
                   coalesce(u.default_company_id, uc.company_id)                                            as company_id,
                   uc.home_page_company_feature_id,
                   f.feature_path                                                                           as home_page_path,
                   (select parent_company_id
                    from flow.company c
                    where c.id = coalesce(u.default_company_id, uc.company_id))                             as parent_company_id,
                   (select case
                             when parent_company_id is null or parent_company_id = 1
                               then coalesce(u.default_company_id, uc.company_id)
                             else parent_company_id end
                    from flow.company c
                    where c.id = coalesce(u.default_company_id, uc.company_id))                             as highest_parent_company_id,
                   null                                                                                     as "timezone",
                   concat(u.first_name, ' ', u.last_name)                                                   AS full_name,
                   (
                     select c.id
                     from flow.company c
                            inner join flow.user_company uc on uc.company_id = c.id
                     where uc.user_id = u.id
                       and uc.archived is not true
                     order by level
                     limit 1
                   )                                                                                        as highest_company_id,
                   coalesce((
                              SELECT array_to_json(array_agg(row_to_json(positions)))
                              FROM (
                                     SELECT up.id,
                                            up.user_id                                     as "userId",
                                            p.position,
                                            p.schedulable,
                                            p.scheduler,
                                            up.position_id                                 as "positionId",
                                            up.org_id                                      as "orgId",
                                            o.org_name                                     as "orgName",
                                            up.start_date                                  as "startDate",
                                            up.end_date                                    as "endDate",
                                            up.primary_flag                                as "primaryFlag",
                                            p.use_slot_schedule                            as "useSlotSchedule",
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
                                     WHERE up.user_id = u.id
                                       and up.archived is not true
                                       and (up.end_date is null or up.end_date >= now())) positions), '[]') AS "userPositions"
            from flow.user u
                   inner join flow.user_company uc on uc.user_id = u.id
                   inner join flow.company c on c.id = uc.company_id
                   left join flow.company_feature cf on cf.company_id = uc.company_id and cf.id = uc.home_page_company_feature_id
                   left join flow.feature f on f.id = cf.feature_id
            where case
                    when :username::text is not null then lower(username) = lower(:username::text)
                    else u.id = :userId::bigint end
              and uc.is_default = true
            limit 1
          )
          select id,
                 first_name,
                 last_name,
                 password,
                 t1.username,
                 email,
                 case when highest_company_id = 1 and company_id != highest_company_id then
                        (select minute_increment from flow.company where id = company_id )
                      else minute_increment end,
                 case when highest_company_id = 1 and company_id != highest_company_id then
                        (select aws_bucket from flow.company where id = company_id )
                      else aws_bucket end,
                 case when highest_company_id = 1 and company_id != highest_company_id then
                        (select api_path from flow.company where id = company_id )
                      else api_path end,
                 phone_number,
                 phone_extension,
                 login_attempts,
                 has_access,
                 company_id,
                 home_page_company_feature_id,
                 home_page_path,
                 parent_company_id,
                 highest_parent_company_id,
                 timezone,
                 full_name,
                 highest_company_id,
                 "userPositions"
          from t1
        """;

  //language=PostgreSQL
  public final static String updateLoginAttempts = """
    update flow."user"
           set login_attempts = :loginAttempts,
               date_modified = now()
       where id = :userId
       """;

  //language=PostgreSQL
  public final static String findByUsernameOrEmailIgnoreCase = """
    select u.id,
           u.first_name,
           u.last_name,
           u.password,
           u.email,
           ust.has_access,
           ust.user_status_type,
           u.notification_type_id,
           u.username,
           u.phone_number,
           u.phone_extension,
           concat(u.first_name, ' ', u.last_name) AS full_name
        from flow.user u
          left join flow.user_company uc on uc.user_id = u.id
          left join flow.company_user_status cus on cus.user_id = u.id
          left join flow.user_status_type ust on ust.company_id = uc.company_id and ust.id = cus.user_status_type_id
        where lower(:usernameOrEmail::text) = lower(username)
              OR lower(:usernameOrEmail::text) = lower(email)
        limit 1
        """;

  //language=PostgreSQL
  public final static String findUserById = """
    with t1 as (
          select u.id,
                 u.first_name,
                 u.last_name,
                 u.username,
                 u.email,
                 u.phone_number,
                 u.phone_extension,
                 concat(u.first_name, ' ', u.last_name)                       AS full_name,
                 u.password,
                 coalesce(u.default_company_id, uc.company_id)                as company_id,
                 c.aws_bucket,
                 c.minute_increment,
                 c.api_path,
                 (select has_access
                  from flow.company_user_status cus
                         inner join flow.user_status_type ust on ust.id = cus.user_status_type_id
                  where user_id = u.id
                    and ust.company_id = uc.company_id
                 )                                                            as has_access,
                 (select parent_company_id
                  from flow.company c
                  where c.id = coalesce(u.default_company_id, uc.company_id)) as parent_company_id,
                 (select case
                           when parent_company_id is null or parent_company_id = 1
                             then coalesce(u.default_company_id, uc.company_id)
                           else parent_company_id end
                  from flow.company c
                  where c.id = coalesce(u.default_company_id, uc.company_id)) as highest_parent_company_id,
                 (
                   select c.id
                   from flow.company c
                          inner join flow.user_company uc on uc.company_id = c.id
                   where uc.user_id = u.id
                     and uc.archived is not true
                     and c.archived is not true
                   order by level
                   limit 1
                 )                                                            as highest_company_id,
                 coalesce((
                              SELECT array_to_json(array_agg(row_to_json(positions)))
                              FROM (
                                     SELECT up.id,
                                            up.user_id                                     as "userId",
                                            p.position,
                                            p.schedulable,
                                            p.scheduler,
                                            up.position_id                                 as "positionId",
                                            up.org_id                                      as "orgId",
                                            o.org_name                                     as "orgName",
                                            up.start_date                                  as "startDate",
                                            up.end_date                                    as "endDate",
                                            up.primary_flag                                as "primaryFlag",
                                            p.use_slot_schedule                            as "useSlotSchedule",
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
                                     WHERE up.user_id = u.id
                                       and up.archived is not true
                                       and p.company_id = coalesce(u.default_company_id, uc.company_id)
                                       and (up.end_date is null or up.end_date >= now())) positions), '[]') AS "userPositions"
          from flow.user u
                 inner join flow.user_company uc on uc.user_id = u.id
                 inner join flow.company c on c.id = uc.company_id
          where u.id = :id
            and uc.is_default is true
            and uc.archived is not true
            and c.archived is not true
        )
        select id,
               first_name,
               last_name,
               email,
               username,
               phone_number,
               phone_extension,
               full_name,
               password,
               "userPositions",
               company_id,
               case when highest_company_id = 1 and company_id != highest_company_id then
                  (select minute_increment from flow.company where id = company_id )
                else minute_increment end,
               case when highest_company_id = 1 and company_id != highest_company_id then
                  (select aws_bucket from flow.company where id = company_id )
                 else aws_bucket end,
               case when highest_company_id = 1 and company_id != highest_company_id then
                      (select api_path from flow.company where id = company_id )
                    else api_path end,
               has_access,
               parent_company_id,
               highest_parent_company_id,
               highest_company_id
        from t1
        """;

  //language=PostgreSQL
  public final static String getCompanyUserStatuses = """
    select id,
                 user_status_type,
                 company_id,
                 has_access,
                 new_user_default,
                 archived
          from flow.user_status_type
            where company_id = :companyId
             and archived is not true
          order by user_status_type
        """;

  //language=PostgreSQL
  public final static String saveUserStatusType = """
     update flow.user_status_type
          set has_access = :hasAccess,
              modified_by_id = :modifiedById,
              date_modified = now()
      where id = :id
    """;

  //language=PostgreSQL
  public final static String archiveUserStatus = """
    update flow.company_user_status cus
         set archived = true,
             date_modified = now(),
             modified_by_id = :modifiedById
             from flow.user_status_type ust
         where ust.id = cus.user_status_type_id
             and cus.user_id = :userId
             and ust.company_id = :companyId
       """;

  //language=PostgreSQL
  public final static String upsertUserStatus = """
    WITH do_upsert AS (
          update flow.company_user_status cus
          set user_status_type_id = :userStatusTypeId,
              date_modified = now(),
              modified_by_id = :currentUserId
              from flow.user_status_type ust
          where ust.id = cus.user_status_type_id
              and cus.user_id = :userId
              and ust.company_id = :companyId
          returning *
        )
        INSERT INTO flow.company_user_status (user_status_type_id, user_id)
        SELECT :userStatusTypeId, :userId
        WHERE NOT EXISTS (SELECT * FROM do_upsert)
        """;

  //language=PostgreSQL
  public final static String updateUserStatus = """
    update flow.company_user_status cus
         set user_status_type_id = :userStatusTypeId,
             date_modified = now(),
             modified_by_id = :currentUserId
       from flow.user_status_type ust
       where ust.id = cus.user_status_type_id
         and cus.user_id = :userId
         and ust.company_id = :companyId
       """;

  //language=PostgreSQL
  public final static String insertUserStatus = """
    insert into flow.company_user_status(user_id, user_status_type_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:userId, :userStatusTypeId, :currentUserId, now(), :currentUserId, now())
      """;

  //language=PostgreSQL
  public final static String updateDefault = """
    update flow.user_company
            set is_default = false,
                date_modified = now()
          where user_id = :userId;
          update flow.user_company
          set is_default = true,
              date_modified = now()
          where company_id = :companyId
            and user_id = :userId
        """;

  //language=PostgreSQL
  public final static String updateAdminDefault = """
    update flow.user
         set default_company_id = :companyId
         where id = :userId
      """;

  //language=PostgreSQL
  public final static String insertUserCompany = """
    insert into flow.user_company(company_id, user_id, is_default, home_page_company_feature_id)
       values (:companyId, :id, :isDefault, :homePageCompanyFeatureId)
     """;

  //language=PostgreSQL
  public final static String deleteUserCompany = """
    update flow.user_company
        set archived = true,
            date_modified = now()
      where user_id = :userId
        and company_id = :companyId
    """;

  //language=PostgreSQL
  public final static String upsertUserCompany = """
    insert into flow.user_company(company_id, user_id)
    values (:companyId, :userId)
    ON CONFLICT (company_id, user_id)
        DO UPDATE SET archived = false
    """;

  //language=PostgreSQL
  public final static String getUserCompanies = """
    select c.id,
              c.company_name as "companyName",
              c.parent_company_id as "parentCompanyId",
              c.aws_bucket as "awsBucket",
              c.abbreviation
        from flow.user_company uc
                inner join flow.company c on c.id = uc.company_id
        where uc.user_id = :userId
         and uc.archived is not true
         and c.archived is not true
         order by c.company_name
        """;

  //language=PostgreSQL
  public final static String checkEmailExists = """
      select id,
         email
      from flow."user"
      where lower(trim(email)) = lower(trim(:email))
      and case when :userId::bigint is not null then :userId::bigint != id else 1=1 end
    """;

  //language=PostgreSQL
  public final static String checkUsernameExists = """
      select id,
         username
      from flow."user"
      where lower(trim(username)) = lower(trim(:username))
      and case when :userId::bigint is not null then :userId::bigint != id else 1=1 end
    """;

  //language=PostgreSQL
  public final static String saveForgotPasswordFields = """
      update flow."user"
      set uuid = :uuid,
          expiry_date = :expiryDate
      where id = :id
    """;

  //language=PostgreSQL
  public final static String saveUserPassword = """
      update flow."user"
      set password = :password,
          date_modified = now()
      where id = :id
    """;

  //language=PostgreSQL
  public final static String findByUserUuid = """
    select u.id,
          u.first_name,
          u.last_name,
          u.password,
          u.email,
          u.username,
          concat(u.first_name, ' ', u.last_name) AS full_name,
          u.uuid,
          u.expiry_date
       from flow.user u
       where u.uuid = :uuid
       limit 1
       """;

  //language=PostgreSQL
  public final static String mentionableUsers = """
      select u.id, u.first_name, u.last_name,
             concat(u.first_name, ' ', u.last_name, ' (', u.email, ')') AS full_name,
             u.email
      from flow."user" u
               inner join flow.user_company uc on u.id = uc.user_id
               inner join flow.company c on c.id = uc.company_id
               inner join flow.user_status_type ust on ust.company_id = uc.company_id
               inner join flow.company_user_status cus on cus.user_id = u.id and cus.user_status_type_id = ust.id
      where (uc.company_id = :companyId or (c.parent_company_id = :parentCompanyId and :parentCompanyId != 1))
        and u.archived = false
        and ust.has_access is true
      group by u.id, last_name, first_name
      order by last_name, first_name desc
    """;

  //language=PostgreSQL
  public final static String addNotificationToken = """
    insert into flow.user_notification_token (user_id, token, created_by_id, date_created, modified_by_id, date_modified)
    values (:userId, :token, :createdById, now(), :createdById, now())
      """;

  //language=PostgreSQL
  public final static String getUserAttachments = """
    select
          a.id,
          a.size,
          a.uuid,
          a.date_created,
          a.date_modified,
          a.filename,
          a.attachment_type_id,
          a.content_type,
          a.s3_key,
          a.display_name,
          a.archived,
          substring(filename, '\\.([^\\.]+)$') as file_extension,
          ua.user_id,
          ua.linked,
          concat(u.first_name, ' ', u.last_name) AS uploaded_by,
          att.attachment_type,
          orgn.*
        from flow.user_attachment ua
               inner join flow.attachment a on a.id = ua.attachment_id
               inner join flow."user" u ON a.created_by_id = u.id
               inner join flow.attachment_type att on a.attachment_type_id = att.id
               inner join flow.user_attachment_type uat on uat.attachment_type_id = att.id and uat.archived is false
               left join lateral ( select * from flow.get_attachment_origin(a.id)) orgn on true
        where ua.user_id = :userId
          and a.company_id = :companyId
          and uat.archived is false
          and case when :linked is true then ua.linked is true and uat.linkable is true else ua.linked is false end
          and ua.archived is not true
          and a.archived is not true
        order by ua.date_created desc
        """;

  //language=PostgreSQL
  public final static String linkAttachment = """
    insert into flow.user_attachment(attachment_id, user_id, created_by_id, linked)
    values(:attachmentId, :userId, :currentUserId, true)
    """;

  //language=PostgreSQL
  public final static String unlinkAttachment = """
    update flow.user_attachment
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
    where attachment_id = :attachmentId
    and user_id = :userId
    and linked is true
    """;

  //language=PostgreSQL
  public final static String addAttachment = """
    insert into flow.user_attachment(attachment_id, user_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:attachmentId, :userId, :createdById, now(), :createdById, now())
      """;

  //language=PostgreSQL
  public final static String isSuperAdmin = """
    select case when uc.id is not null then true else false end
    from flow.user_company uc
      inner join flow."user" u on uc.user_id = u.id
    where uc.user_id = :userId
      and uc.company_id = 1
      and uc.archived is false
      and u.archived is false
    """;

  //language=PostgreSQL
  public final static String hasAccessInCompany = """
    select case when uc.id is not null then true else false end
    from flow.user_company uc
       inner join flow."user" u on uc.user_id = u.id
       inner join flow.company_user_status cus on cus.user_id = u.id
       inner join flow.user_status_type ust on cus.user_status_type_id = ust.id and ust.company_id = :companyId
    where uc.user_id = :userId
      and uc.company_id = :companyId
      and ust.has_access is true
      and uc.archived is false
      and u.archived is false
    """;

  //language=PostgreSQL
  public final static String getAttachmentType = """
    select oat.id,
               oat.company_id,
               oat.attachment_type_id,
               at.attachment_type,
               oat.focused,
               oat.linkable,
               oat.allow_upload,
               oat.archived,
               coalesce((
                          SELECT array_to_json(array_agg(row_to_json(cfGroups)))
                          FROM (
                                 SELECT cfg.id,
                                        cfg.group_name as "groupName",
                                        cot.object_type_id as "objectTypeId",
                                        cot.id as "companyObjectTypeId",
                                        cfg.archived,
                                        cfg.group_order as "groupOrder",
                                        cfg.process_step_id as "processStepId",
                                        coalesce((
                                                   SELECT array_to_json(array_agg(row_to_json(customFields)))
                                                   FROM (
                                                          SELECT cfga.id,
                                                                 cfga.custom_field_group_id as "customFieldGroupId",
                                                                 cfga.custom_field_id as "customFieldId",
                                                                 cfga.use_parent_data as "useParentData",
                                                                 cfga.id as "customFieldGroupAssignmentId",
                                                                 cfga.ancillary_custom_field_group_assignment_id as "ancillaryCustomFieldGroupAssignmentId",
                                                                 cfga.field_order as "fieldOrder",
                                                                 cfga.archived,
                                                                 cfga.read_only as "customFieldGroupAssignmentReadOnly",
                                                                 cfga.hidden as "customFieldGroupAssignmentHidden",
                                                                 cfga.detail_view as "detailView",
                                                                 cf.field_name as "fieldName",
                                                                 cf.system_readonly as "systemReadonly",
                                                                 cfg1.group_name as "groupName",
                                                                 null as "eventName",
                                                                 ps.process_step_name as "processStepName",
                                                                 ot.object_type as "objectType",
                                                                 '[]' as whiteListedPositions,
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
                                                                                   WHERE wlp.custom_field_group_assignment_id = cfga.id
                                                                                     AND wlp.white_list_type_id = 2
                                                                                     AND wlp.archived is not true) wlp), '[]') AS "hiddenWhiteListedPositions"
                                                          FROM flow.custom_field_group_assignment cfga
                                                                 inner join flow.custom_field_group_assignment cfga2 on cfga2.id = cfga.ancillary_custom_field_group_assignment_id
                                                                 inner join flow.custom_field cf on cf.id = cfga2.custom_field_id
                                                                 inner join flow.custom_field_group cfg1 on cfg1.id = cfga2.custom_field_group_id
                                                                 left join flow.process_step ps on ps.id = cfg1.process_step_id
                                                                 inner join flow.company_object_type cot on cot.id = cfg1.company_object_type_id
                                                                 inner join flow.object_type ot on ot.id = cot.object_type_id
                                                          WHERE cfga.custom_field_group_id = cfg.id
                                                            AND cfga.archived is not true
                                                            and cf.archived is not true
                                                          ORDER by "fieldOrder", "fieldName") customFields), '[]') AS "customFields"
                                 FROM flow.custom_field_group cfg
                                        inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
                                 WHERE cfg.user_attachment_type_id = oat.id AND cfg.archived is not true
                                 order by cfg.group_order) cfGroups), '[]') AS custom_field_groups
        from flow.user_attachment_type oat
               inner join flow.attachment_type at on oat.attachment_type_id = at.id
        where oat.id = :id
        and oat.company_id = :companyId
    """;
}
