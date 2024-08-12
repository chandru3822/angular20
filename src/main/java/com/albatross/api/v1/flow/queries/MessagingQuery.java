package com.albatross.api.v1.flow.queries;

public class MessagingQuery {

  //language=PostgreSQL
  public final static String getConversations = """
       select pc.id,
              pc.date_created,
              pc.closed,
              pc.to_phone,
              pc.from_phone,
              pc.inbound,
              pc.recipient_type_id,
              pc.parent_id,
              pc.message,
              case when pc.recipient_type_id = 1 then
                  (select concat(u.first_name, ' ', u.last_name)
                   from flow.user u
                   where u.archived is false
                   and (u.search_phone = pc.search_to_phone or u.search_phone = pc.search_from_phone)
                   limit 1)
                  else
                      (select concat(c.first_name, ' ', c.last_name)
                       from flow.contact c
                       where c.archived is false
                         and (c.search_phones = pc.search_to_phone or c.search_phones = pc.search_from_phone)
                       order by c.date_created desc
                       limit 1) end as full_name,
               case when pc.recipient_type_id = 2 then
                        (select s.abbreviation
                         from flow.contact c
                             inner join flow.company_state cs on c.company_state_id = cs.id
                             inner join flow.state s on cs.state_id = s.id
                         where c.archived is false
                           and (c.search_phones = pc.search_to_phone or c.search_phones = pc.search_from_phone)
                         order by c.date_created desc
                         limit 1
                         )
                   end as state_abbreviation,
                  (coalesce((SELECT array_to_json(array_agg(row_to_json(st)))
                         FROM (select st.id,
                                      st.team_name                                                        as "teamName",
                                      coalesce((SELECT array_to_json(array_agg(row_to_json(tb)))
                                                FROM (SELECT pmo.id,
                                                             pmo.user_id                            as "userId",
                                                             concat(u.first_name, ' ', u.last_name) as "name",
                                                             pmo.sms_team_id                        as "smsTeamId",
                                                             pmo.archived
                                                      FROM flow.sms_thread_owner pmo
                                                               inner join flow.user u on pmo.user_id = u.id
                                                      WHERE pmo.archived = false
                                                        and pmo.sms_thread_id = sto.sms_thread_id
                                                        and pmo.sms_team_id = sto.sms_team_id
                                                        and pmo.user_id is not null
                                                        ) tb), '[]') AS "users"
                               from flow.sms_thread_owner sto
                                        inner join flow.sms_team st on sto.sms_team_id = st.id and st.archived is false
                               where sto.sms_thread_id = pc.parent_id
                                  and sto.user_id is null
                                 and sto.archived = false) st), '[]')) as "smsTeamOwners"
       from flow.sms_thread pc
                inner join flow.sms_thread_owner pco on pc.parent_id = pco.sms_thread_id and pco.archived is false
       where pc.inbound = :showInbox
         and pc.is_last_inserted is true
         and pc.archived is false
         and (pco.sms_team_id = any (array [ :smsTeamIds ]::bigint[]) and
              (case when :unassigned is true then pco.user_id is null
                    else pco.user_id = any (array [ :ownerIds ]::bigint[]) end))
         and case
                 when array_length(array [ :notifConversationIds ]::bigint[], 1) > 0 then
                     (pc.id = any (array [ :notifConversationIds ]::bigint[]))
                 else true end
       order by pc.date_created desc
       limit :limit
           offset :offset
    """;

  //language=PostgreSQL
  public final static String getProjectsCount = """
    with owner_filter AS (SELECT project_id, id
                          FROM flow.project_message_owner pmo
                          where case
                                    when array_length(array [ :ownerIds ]::bigint[], 1) > 0 then
                                        pmo.user_id = any (array [ :ownerIds ]::bigint[])
                                            and pmo.sms_team_id = any (array [ :smsTeamIds ]::bigint[])
                                            and pmo.archived is false
                                    end),
         projects as (select distinct on (p.id) p.id as project_id
                      from flow.project p
                               inner join flow.project_message_properties pmp on pmp.project_id = p.id
                               left join flow.project_message_team pmt on pmt.project_id = p.id
                          and pmt.archived is false
                               left join flow.project_message_owner pmo2
                                         on pmo2.sms_team_id = pmt.sms_team_id
                                             and pmo2.project_id = p.id
                                             and pmo2.archived is false
                               left join flow.user u on pmo2.user_id = u.id
                               left join flow.sms_cache sc on p.id = sc.project_id
                               left join owner_filter of on of.project_id = p.id
                      where case
                                when :query::varchar is not null then
                                    (p.project_name_search like '%' || :query || '%') or
                                    (p.id::varchar like '%' || :query || '%') or
                                    (u.user_full_name_search like '%' || :query || '%')
                                else 1 = 1 end
                        and (pmt.sms_team_id = any (array [ :smsTeamIds ]::bigint[]) and
                             (of.id is not null or case when :unassigned is true then pmo2.id is null end))
                        and case
                                when :showInbox
                                    then sc.outbound_message is false
                                else sc.outbound_message is null or sc.outbound_message is true
                          end)
    select p.project_id from projects p
    """;

  //language=PostgreSQL
  public final static String getProjectCountCombined = """
    with owner_filter AS (SELECT project_id, id
                          FROM flow.project_message_owner pmo
                          where case
                                    when array_length(array [ :ownerIds ]::bigint[], 1) > 0 then
                                        (pmo.user_id = any (array [ :ownerIds ]::bigint[])) and
                                        pmo.sms_team_id = any (array [ :smsTeamIds ]::bigint[])
                                            and pmo.archived is false
                                    end)
    select distinct on (p.id) p.id                                as project_id,
                              coalesce(sc.outbound_message, true) as outbound_message
    from flow.project p
             inner join flow.project_message_properties pmp on pmp.project_id = p.id
             left join flow.project_message_team pmt on pmt.project_id = p.id and pmt.archived is false
             left join flow.project_message_owner pmo2
                       on pmo2.sms_team_id = pmt.sms_team_id
                           and pmo2.project_id = p.id
                           and pmo2.archived is false
             left join flow.sms_cache sc on p.id = sc.project_id
             left join owner_filter of on of.project_id = p.id
    where case
              when array_length(array [ :notifProjectIds ]::bigint[], 1) > 0 then
                  (p.id = any (array [ :notifProjectIds ]::bigint[]))
              else 1 = 1 end
      and (pmt.sms_team_id = any (array [ :smsTeamIds ]::bigint[]) and
           (of.id is not null or pmo2.id is null))
    """;

  //language=PostgreSQL
  public final static String getThread = """
    select
                                  st.closed,
                                  case when st.recipient_type_id = 1 then
                                           (select concat(u.first_name, ' ', u.last_name)
                                            from flow.user u
                                            where u.archived is false
                                              and (u.search_phone = st.search_to_phone or u.search_phone = st.search_from_phone)
                                            limit 1)
                                       else
                                           (select concat(c.first_name, ' ', c.last_name)
                                            from flow.contact c
                                            where c.archived is false
                                              and (c.search_phones = st.search_to_phone or c.search_phones = st.search_from_phone)
                                            order by c.date_created desc
                                            limit 1) end as full_name,
                                  case when st.recipient_type_id = 2 then
                                           (select s.abbreviation
                                            from flow.contact c
                                                     inner join flow.company_state cs on c.company_state_id = cs.id
                                                     inner join flow.state s on cs.state_id = s.id
                                            where c.archived is false
                                              and (c.search_phones = st.search_to_phone or c.search_phones = st.search_from_phone)
                                            order by c.date_created desc
                                            limit 1
                                           )
                                      end as state_abbreviation,
                                  (coalesce((SELECT array_to_json(array_agg(row_to_json(st)))
                                             FROM (select st.id,
                                                          st2.team_name                                                        as "teamName",
                                                          coalesce((SELECT array_to_json(array_agg(row_to_json(tb)))
                                                                    FROM (SELECT pmo.id,
                                                                                 pmo.user_id                            as "userId",
                                                                                 concat(u.first_name, ' ', u.last_name) as "name",
                                                                                 pmo.sms_team_id                        as "smsTeamId",
                                                                                 pmo.archived
                                                                          FROM flow.sms_thread_owner pmo
                                                                                   inner join flow.user u on pmo.user_id = u.id
                                                                          WHERE pmo.archived = false
                                                                            and pmo.sms_thread_id = sto.sms_thread_id
                                                                            and pmo.sms_team_id = sto.sms_team_id
                                                                            and pmo.user_id is not null
                                                                         ) tb), '[]') AS "users"
                                                   from flow.sms_thread_owner sto
                                                            inner join flow.sms_team st2 on sto.sms_team_id = st2.id and st2.archived is false
                                                   where sto.sms_thread_id = st.parent_id
                                                     and sto.user_id is null
                                                     and sto.archived = false) st), '[]')) as "smsTeamOwners"
                              from flow.sms_thread st
                              where st.id = :smsThreadId
    """;

  //language=PostgreSQL
  public final static String getUsers = """
    with owner_filter AS (SELECT owner_user_id, id
                          FROM flow.user_message_owner umo
                          where case
                                    when array_length(array [ :ownerIds ]::bigint[], 1) > 0 then
                                        (umo.user_id = any (array [ :ownerIds ]::bigint[])) and
                                        umo.sms_team_id = any (array [ :smsTeamIds ]::bigint[])
                                            and umo.archived is false
                                    end),
         users as (select distinct on (u.id) u.id                                   as user_id,
                                             concat(u.first_name, ' ', u.last_name) as name,
                                             u.search_phone                         as mobile,
                                             case
                                                 when sc.id is null then '[]'
                                                 else
                                                     json_build_array(
                                                             json_build_object(
                                                                     'message', sc.message_text,
                                                                     'lastMessageSent', sc.message_date,
                                                                     'outboundMessage', sc.outbound_message,
                                                                     'recipientTypeId', 1))
                                                 end                                as message_history
                   from flow.user u
                            inner join flow.user_message_properties ump on ump.user_id = u.id
                            left join flow.user_message_team umt on umt.user_id = u.id and umt.archived is false
                            left join flow.user_message_owner umo2
                                      on umo2.sms_team_id = umt.sms_team_id and umo2.user_id = u.id and
                                         umo2.archived is false
                            left join owner_filter of on of.owner_user_id = u.id
                            left join flow.sms_cache sc on u.id = sc.user_id
                   where case
                             when array_length(array [ :notifUserIds ]::bigint[], 1) > 0 then
                                 (u.id = any (array [ :notifUserIds ]::bigint[]))
                             else 1 = 1 end
                     and case
                             when :query::varchar is not null then
                                 (u.id::varchar like '%' || :query || '%') or
                                 (u.user_full_name_search like '%' || :query || '%')
                             else 1 = 1 end
                     and (umt.sms_team_id = any (array [ :smsTeamIds ]::bigint[]) and
                          (of.id is not null or case when :unassigned is true then umo2.id is null end))
                     and (case
                              when :showInbox then
                                  sc.outbound_message is false
                              else sc.outbound_message is null or sc.outbound_message is true
                       end)
                   limit :limit offset :offset)
    select u.user_id,
           u.name                                                    as "fullName",
           u.message_history,
           (coalesce((SELECT array_to_json(array_agg(row_to_json(st)))
                      FROM (select st.id,
                                   st.team_name                                              as "teamName",
                                   coalesce((SELECT array_to_json(array_agg(row_to_json(tb)))
                                             FROM (SELECT umo.id,
                                                          umo.user_id                            as "userId",
                                                          concat(u.first_name, ' ', u.last_name) as "name",
                                                          umo.sms_team_id                        as "smsTeamId",
                                                          umo.archived
                                                   FROM flow.user_message_owner umo
                                                            inner join flow.user u on umo.user_id = u.id
                                                       and umo.owner_user_id = umt.user_id
                                                       and umo.sms_team_id = umt.sms_team_id
                                                       and umo.archived is false) tb), '[]') AS "users"
                            from flow.user_message_team umt
                                     inner join flow.sms_team st on umt.sms_team_id = st.id
                            where umt.user_id = u.user_id
                              and umt.archived is false) st), '[]')) as "smsTeamOwners"
    from users u
    """;

  //language=PostgreSQL
  public final static String getUsersCount = """
    with owner_filter AS (SELECT owner_user_id, id
                          FROM flow.user_message_owner umo
                          where case
                                    when array_length(array [ :ownerIds ]::bigint[], 1) > 0 then
                                        (umo.user_id = any (array [ :ownerIds ]::bigint[])) and
                                        umo.sms_team_id = any (array [ :smsTeamIds ]::bigint[])
                                            and umo.archived is false
                                    end),
         users as (select distinct on (u.id) u.id                                   as user_id,
                                             concat(u.first_name, ' ', u.last_name) as name
                   from flow.user u
                            inner join flow.user_message_properties ump on ump.user_id = u.id
                            left join flow.user_message_team umt on umt.user_id = u.id and umt.archived is false
                            left join flow.user_message_owner umo2
                                      on umo2.sms_team_id = umt.sms_team_id and umo2.user_id = u.id and
                                         umo2.archived is false
                            left join owner_filter of on of.owner_user_id = u.id
                            left join flow.sms_cache sc on u.id = sc.user_id
                   where case
                             when :query::varchar is not null then
                                 (u.id::varchar like '%' || lower(:query) || '%') or
                                 (u.user_full_name_search like '%' || lower(:query) || '%')
                             else 1 = 1 end
                     and (umt.sms_team_id = any (array [ :smsTeamIds ]::bigint[]) and
                          (of.id is not null or case when :unassigned is true then umo2.id is null end))
                     and (case
                              when :showInbox then
                                  sc.outbound_message is false
                              else sc.outbound_message is null or sc.outbound_message is true
                       end))
    select u.user_id
    from users u
    """;

  public final static String getUsersCountCombined = """
with owner_filter AS (SELECT owner_user_id, id
                      FROM flow.user_message_owner umo
                      where case
                                when array_length(array [ :ownerIds ]::bigint[], 1) > 0 then
                                    (umo.user_id = any (array [ :ownerIds ]::bigint[])) and
                                    umo.sms_team_id = any (array [ :smsTeamIds ]::bigint[])
                                        and umo.archived is false
                                end),
     users as (select distinct on (u.id) u.id                                   as user_id,
                                         coalesce(outbound_message, true)       as outbound_message
               from flow.user u
                        inner join flow.user_message_properties ump on ump.user_id = u.id
                        left join flow.user_message_team umt on umt.user_id = u.id and umt.archived is false
                        left join flow.user_message_owner umo2
                                  on umo2.sms_team_id = umt.sms_team_id and umo2.user_id = u.id and
                                     umo2.archived is false
                        left join flow.sms_cache sc on u.id = sc.user_id
                        left join owner_filter of on of.owner_user_id = u.id
               where (umt.sms_team_id = any (array [ :smsTeamIds ]::bigint[]) and
                      (of.id is not null or umo2.id is null)))
select u.user_id, outbound_message from users u
    """;

  public final static String getUser = """
    select    u.id                                                     as userId,
              u.first_name || ' ' || u.last_name                       as fullName,
              coalesce(u.default_company_id, uc.company_id)                as company_id,
              (coalesce((SELECT array_to_json(array_agg(row_to_json(st)))
                         FROM (select st.id,
                                      st.team_name                                                        as "teamName",
                                      coalesce((SELECT array_to_json(array_agg(row_to_json(tb)))
                                                FROM (SELECT umo.id,
                                                             umo.user_id                            as "userId",
                                                             concat(u2.first_name, ' ', u2.last_name) as "name",
                                                             umo.sms_team_id                        as "smsTeamId",
                                                             umo.archived
                                                      FROM flow.user_message_owner umo
                                                               inner join flow.user u2 on umo.user_id = u2.id
                                                      WHERE umo.archived = false
                                                        and umo.owner_user_id = u.id
                                                        and umo.sms_team_id = umt.sms_team_id) tb), '[]') AS "users"
                               from flow.user_message_team umt
                                        inner join flow.sms_team st on umt.sms_team_id = st.id
                               where umt.user_id = u.id
                                 and umt.archived = false) st), '[]')) as "smsTeamOwners"
       from flow.user u
                inner join flow.user_message_properties ump on u.id = ump.user_id
                inner join flow.user_company uc on uc.user_id = u.id
       where u.id = :userId
       and uc.is_default is true
            and uc.archived is not true
    """;

  //language=PostgreSQL
  public final static String getProjectsBySmsTeam = """
    select pmt.project_id
      from flow.project_message_team pmt
        where pmt.sms_team_id = :smsTeamId and archived = false
    group by project_id
    """;

  //language=PostgreSQL
  public final static String getUsersBySmsTeam = """
    select umt.user_id
      from flow.user_message_team umt
        where umt.sms_team_id = :smsTeamId and archived = false
    group by user_id
    """;

  //language=PostgreSQL
  public final static String getActiveProjectId = """
    select pmp.id from flow.project_message_properties pmp where pmp.project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String insertProject = """
    insert into flow.project_message_properties
    (project_id, closed, created_by_id, date_created, modified_by_id, date_modified)
    values (:projectId, false, :createdById, now(), :createdById, now())
    on conflict (project_id)
        do update set modified_by_id = excluded.modified_by_id,
                      date_modified  = excluded.date_modified
    """;

  //language=PostgreSQL
  public final static String insertUser = """
    insert into flow.user_message_properties
    (user_id, closed, created_by_id, date_created, modified_by_id, date_modified)
    values (:userId, false, :createdById, now(), :createdById, now())
    on conflict (user_id)
        do update set modified_by_id = excluded.modified_by_id,
                      date_modified  = excluded.date_modified
    """;

  //language=PostgreSQL
  public final static String saveProjectStatusOpen = """
    update flow.project_message_properties
    set closed = false,
        date_modified = now(),
        modified_by_id = :modifiedById
      where project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String saveUserStatusOpen = """
    update flow.user_message_properties
    set closed = false,
        date_modified = now(),
        modified_by_id = :modifiedById
      where user_id = :userId
    """;

  //language=PostgreSQL
  public final static String saveProjectStatusClosed = """
    update flow.project_message_properties
    set closed = true,
        last_sent = null,
        date_modified = now(),
        modified_by_id = :modifiedById
      where project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String saveUserStatusClosed = """
    update flow.user_message_properties
    set closed = true,
        last_sent = null,
        date_modified = now(),
        modified_by_id = :modifiedById
      where user_id = :userId
    """;

  //language=PostgreSQL
  public final static String getOwnersForProject = """
    select distinct user_id, sms_team_id from flow.project_message_owner where project_id = :projectId and archived is false
    """;

  //language=PostgreSQL
  public final static String getOwnersForUser = """
    select distinct user_id, sms_team_id from flow.user_message_owner where owner_user_id = :userId and archived is false
    """;

  //language=PostgreSQL
  public final static String getProjectHistory = """
    select * from coalesce((
       SELECT array_to_json(array_agg(row_to_json(history)))
       FROM (
                 select st.team_name, u.first_name || ' ' || u.last_name as "userName", pmoh.date_created, date_removed,
                        (select u1.first_name || ' ' || u1.last_name from flow.user u1 where u1.id = pmoh.created_by_id) as "addedBy",
                        (select u2.first_name || ' ' || u2.last_name from flow.user u2 where u2.id = pmoh.modified_by_id) as "removedBy"
                    from flow.project_message_owner_history pmoh
                 inner join flow.project p on pmoh.project_id = p.id
                 inner join flow.sms_team st on pmoh.sms_team_id = st.id
                 left join flow.user u on pmoh.user_id = u.id
                 where project_id = :projectId
                  order by pmoh.date_modified desc
            ) history), '[]') AS "conversationHistory"
    """;

  //language=PostgreSQL
  public final static String getUserHistory = """
    select * from coalesce((
       SELECT array_to_json(array_agg(row_to_json(history)))
       FROM (
                 select st.team_name, u.first_name || ' ' || u.last_name as "userName", umoh.date_created, date_removed,
                        (select u1.first_name || ' ' || u1.last_name from flow.user u1 where u1.id = umoh.created_by_id) as "addedBy",
                        (select u2.first_name || ' ' || u2.last_name from flow.user u2 where u2.id = umoh.modified_by_id) as "removedBy"
                    from flow.user_message_owner_history umoh
                 inner join flow.sms_team st on umoh.sms_team_id = st.id
                 left join flow.user u on umoh.user_id = u.id
                 where umoh.owner_user_id = :userId
                  order by umoh.date_modified desc
            ) history), '[]') AS "conversationHistory"
    """;

  //language=PostgreSQL
  public final static String setLastSentForProject = """
    update flow.project_message_properties set last_sent = now(), date_modified = now(), modified_by_id = :modifiedById where project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String setLastSentForUser = """
    update flow.user_message_properties set last_sent = now(), date_modified = now(), modified_by_id = :modifiedById where user_id = :userId
    """;

  //language=PostgreSQL
  public final static String clearProjectLastSent = """
    update flow.project_message_properties set last_sent = null, date_modified = now(), modified_by_id = :modifiedById where project_id in (:projectIds)
    """;

  //language=PostgreSQL
  public final static String clearUserLastSent = """
    update flow.user_message_properties set last_sent = null, date_modified = now(), modified_by_id = :modifiedById where user_id in (:userIds)
    """;

  //language=PostgreSQL
  public final static String getStaleProjects = """
    select project_id from flow.project_message_properties pmp where pmp.last_sent < ((now() AT TIME ZONE 'US/Mountain') :: DATE) - 3
    """;

  //language=PostgreSQL
  public final static String getStaleUsers = """
    select user_id from flow.user_message_properties ump where ump.last_sent < ((now() AT TIME ZONE 'US/Mountain') :: DATE) - 3
    """;

  //language=PostgreSQL
  public final static String insertProjectTeam = """
    insert into flow.project_message_team
    (project_id, sms_team_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:projectId, :teamId, :createdById, now(), :createdById, now())
    on conflict (project_id, sms_team_id) WHERE archived is false
        do nothing
    """;

  //language=PostgreSQL
  public final static String insertUserTeam = """
    insert into flow.user_message_team
    (user_id, sms_team_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:userId, :teamId, :createdById, now(), :createdById, now())
    """;

  //language=PostgreSQL
  public final static String removeProjectOwner = """
    update flow.project_message_owner
      set archived = true,
          modified_by_id = :modifiedById,
          date_modified = now()
      where project_id = :projectId and user_id = :userId and sms_team_id = :smsTeamId
    """;

  //language=PostgreSQL
  public final static String removeUserOwner = """
    update flow.user_message_owner
      set archived = true,
          modified_by_id = :modifiedById,
          date_modified = now()
      where user_id = :userId and owner_user_id = :ownerUserId and sms_team_id = :smsTeamId
    """;

  //language=PostgreSQL
  public final static String getProjectTeamId = """
    select id from flow.project_message_team where project_id = :projectId and sms_team_id = :teamId and archived = false
    """;

  //language=PostgreSQL
  public final static String getUserTeamId = """
    select id from flow.user_message_team where user_id = :userId and sms_team_id = :teamId and archived = false
    """;

  //language=PostgreSQL
  public final static String getSmsTeamsForProject = """
    select st.id,
           st.team_name,
           coalesce((SELECT array_to_json(array_agg(row_to_json(tb)))
                     FROM (SELECT pmo.id,
                                  pmo.user_id                            as "userId",
                                  concat(u.first_name, ' ', u.last_name) as "name",
                                  pmo.sms_team_id                        as "smsTeamId",
                                  pmo.archived
                           FROM flow.project_message_owner pmo
                                    --inner join flow.sms_team_user stu on stu.id = pmu.sms_team_user_id
                                    inner join flow.user u on pmo.user_id = u.id
                           WHERE pmo.archived = false
                             and pmo.project_id = :projectId
                             and pmo.sms_team_id = pmt.sms_team_id) tb), '[]') AS "users"
    from flow.project_message_team pmt
             inner join flow.sms_team st on pmt.sms_team_id = st.id
    where pmt.project_id = :projectId
      and pmt.archived = false
    """;

  //language=PostgreSQL
  public final static String getSmsTeamsForUserConversation = """
    select st.id,
           st.team_name,
           coalesce((SELECT array_to_json(array_agg(row_to_json(tb)))
                     FROM (SELECT umo.id,
                                  umo.user_id                            as "userId",
                                  concat(u2.first_name, ' ', u2.last_name) as "name",
                                  umo.sms_team_id                        as "smsTeamId",
                                  umo.archived
                           FROM flow.user_message_owner umo
                                    --inner join flow.sms_team_user stu on stu.id = pmu.sms_team_user_id
                                    inner join flow.user u2 on umo.user_id = u2.id
                           WHERE umo.archived = false
                             and umo.owner_user_id = :userId
                             and umo.sms_team_id = umt.sms_team_id) tb), '[]') AS "users"
    from flow.user_message_team umt
             inner join flow.sms_team st on umt.sms_team_id = st.id
    where umt.user_id = :userId
      and umt.archived = false
    """;

  //language=PostgreSQL
  public final static String getSmsTeamsForProjectByUser = """
    select st.id, st.team_name,
              coalesce((
                           SELECT array_to_json(array_agg(row_to_json(tb)))
                           FROM (
                                    SELECT pmo.id,
                                           pmo.user_id as "userId",
                                           concat(u.first_name, ' ', u.last_name) as "name",
                                           pmo.sms_team_id as "smsTeamId",
                                           pmo.archived
                                    FROM flow.project_message_owner pmo
                                        --inner join flow.sms_team_user stu on stu.id = pmu.sms_team_user_id
                                        inner join flow.user u on pmo.user_id = u.id
                                    WHERE pmo.archived = false and
                                          pmo.sms_team_id = st.id) tb), '[]') AS "users"
                                     from flow.project_message_team pmt
                                         inner join flow.sms_team st on pmt.sms_team_id = st.id
                                     where pmt.project_id = :projectId and pmt.archived = false
                                   and pmt.sms_team_id in (:userSmsTeamIds)
    """;

  //language=PostgreSQL
  public final static String removeProjectTeam = """
    update flow.project_message_team set archived = true
        where project_id = :projectId and sms_team_id = :smsTeamId
    """;

  //language=PostgreSQL
  public final static String removeUserTeam = """
    update flow.user_message_team set archived = true
        where user_id = :userId and sms_team_id = :smsTeamId
    """;

  //language=PostgreSQL
  public final static String removeProjectTeamOwners = """
      update flow.project_message_owner set archived = true
        where project_id = :projectId and sms_team_id = :smsTeamId
    """;

  //language=PostgreSQL
  public final static String removeUserTeamOwners = """
      update flow.user_message_owner set archived = true
        where owner_user_id = :ownerUserId and sms_team_id = :smsTeamId
    """;

  //language=PostgreSQL
  public final static String deleteProjectConversation = """
    update flow.project_message_properties
     set closed = true,
         date_modified = now(),
         modified_by_id = :modifiedById
       where project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String deleteUserConversation = """
    update flow.user_message_properties
     set closed = true,
         date_modified = now(),
         modified_by_id = :modifiedById
       where user_id = :userId
    """;

  //language=PostgreSQL
  public final static String removeAllProjectTeams = """
      update flow.project_message_team
      set archived = true,
          date_modified = now(),
          modified_by_id = :modifiedById
        where project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String removeAllUserTeams = """
      update flow.user_message_team
      set archived = true,
          date_modified = now(),
          modified_by_id = :modifiedById
        where user_id = :userId
    """;

  //language=PostgreSQL
  public final static String removeAllProjectTeamOwners = """
      update flow.project_message_owner
      set archived = true,
          date_modified = now(),
          modified_by_id = :modifiedById
        where project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String removeAllUserTeamOwners = """
      update flow.user_message_owner
      set archived = true,
          date_modified = now(),
          modified_by_id = :modifiedById
        where owner_user_id = :userId
    """;

  //language=PostgreSQL
  public final static String markProjectSmsAsReadForUser = """
    update flow.notification
    set message_read_tsz   = now(),
        date_modified  = now(),
        modified_by_id = :modifiedById
    where notification_topic_id = :notificationTopicId
      and user_id = :userId
      and (metadata->>'projectId')::bigint = :projectId
      and (metadata->>'smsTeamId')::bigint = :smsTeamId
      and message_read_tsz is null
    """;

  //language=PostgreSQL
  public final static String markProjectSmsAsReadForTeam = """
    update flow.notification
    set message_read_tsz   = now(),
        date_modified  = now(),
        modified_by_id = :modifiedById
    where notification_topic_id = :notificationTopicId
      and (metadata->'projectId')::bigint = :projectId
      and (metadata->'smsTeamId')::bigint = :smsTeamId
      and message_read_tsz is null
    """;

  //language=PostgreSQL
  public final static String markAllUserNotificationAsReadForUser = """
    update flow.notification
    set message_read_tsz   = now(),
        date_modified  = now(),
        modified_by_id = :modifiedById
    where (metadata->>'userId')::bigint = :userId
      and message_read_tsz is null
    """;

  //language=PostgreSQL
  public final static String markUserSmsAsReadForUser = """
    update flow.notification
    set message_read_tsz   = now(),
        date_modified  = now(),
        modified_by_id = :modifiedById
    where notification_topic_id = :notificationTopicId
      and user_id = :ownerUserId
      and (metadata->>'userId')::bigint = :userId
      and (metadata->>'smsTeamId')::bigint = :smsTeamId
      and message_read_tsz is null
    """;

  //language=PostgreSQL
  public final static String markUserSmsAsReadForTeam = """
    update flow.notification
    set message_read_tsz   = now(),
        date_modified  = now(),
        modified_by_id = :modifiedById
    where notification_topic_id = :notificationTopicId
      and (metadata->'userId')::bigint = :userId
      and (metadata->'smsTeamId')::bigint = :smsTeamId
      and message_read_tsz is null
    """;

  //language=PostgreSQL
  public final static String findUserByForProjectTeam = """
    select distinct user_id
    from flow.notification
    where notification_topic_id = :notificationTopicId
      and (metadata -> 'projectId')::bigint = :projectId
      and (metadata -> 'smsTeamId')::bigint = :smsTeamId
    """;

  //language=PostgreSQL
  public final static String findUserByForUserTeam = """
    select distinct user_id
    from flow.notification
    where notification_topic_id = :notificationTopicId
      and (metadata -> 'userId')::bigint = :userId
      and (metadata -> 'smsTeamId')::bigint = :smsTeamId
      and message_read_tsz is null
    """;

  //language=PostgreSQL
  public final static String markSmsAsReadForProject = """
    update flow.notification
    set message_read_tsz   = now(),
        date_modified  = now(),
        modified_by_id = :modifiedById
    where notification_topic_id = :notificationTopicId
      and (metadata->'projectId')::bigint = :projectId
      and message_read_tsz is null
    """;

  //language=PostgreSQL
  public final static String markSmsAsReadForUser = """
    update flow.notification
    set message_read_tsz   = now(),
        date_modified  = now(),
        modified_by_id = :modifiedById
    where notification_topic_id = :notificationTopicId
      and (metadata->'userId')::bigint = :ownerUserId
      and message_read_tsz is null
    """;

  //language=PostgreSQL
  public final static String findUserByForProject = """
    select distinct user_id
    from flow.notification
    where notification_topic_id = :notificationTopicId
      and (metadata -> 'projectId')::bigint = :projectId
    """;

  //language=PostgreSQL
  public final static String findUserByForUser = """
    select distinct user_id
    from flow.notification
    where notification_topic_id = :notificationTopicId
      and (metadata -> 'userId')::bigint = :ownerUserId
    """;

}
