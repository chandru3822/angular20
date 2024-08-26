package com.albatross.api.v1.flow.queries;

public class MessagingQuery {

  //language=PostgreSQL
  public final static String getConversations = """
       with owners as (
                       select distinct sto.sms_thread_id
                       from flow.sms_thread_owner sto
                       where sto.archived is false
                         and (sto.sms_team_id = any (array [ :smsTeamIds ]::bigint[])
                           and
                              (case when :unassigned is true then sto.user_id is null
                                    else sto.user_id = any (array [ :ownerIds ]::bigint[]) end))
                   ), results as (select st.id,
                                         st.date_created,
                                         st.closed,
                                         st.internal_phone,
                                         st.external_phone,
                                         st.search_external_phone,
                                         st.inbound,
                                         st.recipient_type_id,
                                         st.parent_id,
                                         st.message,
                                         case
                                             when st.recipient_type_id = 1 then
                                                 (select concat(u.first_name, ' ', u.last_name)
                                                  from flow.user u
                                                  where u.archived is false
                                                    and (u.search_phone = st.search_external_phone)
                                                  limit 1)
                                             else
                                                 (select concat(c.first_name, ' ', c.last_name)
                                                  from flow.contact c
                                                  where c.archived is false
                                                    and (c.search_phones = st.search_external_phone)
                                                  order by c.date_created desc
                                                  limit 1) end                                     as full_name,
                                         case
                                             when st.recipient_type_id = 2 then
                                                 (select s.abbreviation
                                                  from flow.contact c
                                                           inner join flow.company_state cs on c.company_state_id = cs.id
                                                           inner join flow.state s on cs.state_id = s.id
                                                  where c.archived is false
                                                    and (c.search_phones = st.search_external_phone)
                                                  order by c.date_created desc
                                                  limit 1)
                                                  end                                              as state_abbreviation
                                               ,
                                         (coalesce((SELECT array_to_json(array_agg(row_to_json(st)))
                                                    FROM (select st2.id,
                                                                 st2.team_name                                             as "teamName",
                                                                 coalesce((SELECT array_to_json(array_agg(row_to_json(tb)))
                                                                           FROM (SELECT pmo.id,
                                                                                        pmo.user_id                            as "userId",
                                                                                        concat(u.first_name, ' ', u.last_name) as "name",
                                                                                        pmo.sms_team_id                        as "smsTeamId",
                                                                                        pmo.archived
                                                                                 FROM flow.sms_thread_owner pmo
                                                                                          inner join flow.user u on pmo.user_id = u.id
                                                                                 WHERE pmo.archived = false
                                                                                   and pmo.sms_thread_id = sto2.sms_thread_id
                                                                                   and pmo.sms_team_id = sto2.sms_team_id
                                                                                   and pmo.user_id is not null) tb), '[]') AS "users"
                                                          from flow.sms_thread_owner sto2
                                                                   inner join flow.sms_team st2 on sto2.sms_team_id = st2.id and st2.archived is false
                                                          where sto2.sms_thread_id = st.parent_id
                                                            and sto2.user_id is null
                                                            and sto2.archived = false) st), '[]')) as "smsTeamOwners"
                                  from flow.sms_thread st
                                           inner join owners o on st.parent_id = o.sms_thread_id
                                           inner join flow.recipient_type rt on st.recipient_type_id = rt.id
                                  where st.inbound = :showInbox
                                    and st.is_last_inserted is true
                                    and st.archived is false
                                    and case
                                      when array_length(array [ :notifThreadIds ]::bigint[], 1) > 0 then
                                          (st.parent_id = any (array [ :notifThreadIds ]::bigint[]))
                                      else 1 = 1 end
                                    and case
                                            when :showExternal and not :showInternal then rt.external is true
                                            when :showInternal and not :showExternal then rt.external is false
                                            else true end)
                   select *,
                    count(*) over() as total_rows
                   from results r
                   where case
                       when lower(trim(:query::text)) is not null then r.search_external_phone like '%' || lower(trim(:query::text)) || '%' OR
                            lower(r.full_name) like '%' || lower(trim(:query::text)) || '%'
                       else true end
                   ORDER BY CASE
                                WHEN :sortAscending::boolean is true THEN r.date_created
                                END ASC,
                            CASE
                                WHEN :sortAscending::boolean is false THEN r.date_created
                                END DESC
                   limit :limit
                   offset :offset
    """;

  //language=PostgreSQL
  public final static String getThread = """
    select
                                                            st.closed,
                                                            rt.external,
                                                            case when st.recipient_type_id = 1 then
                                                                     (select concat(u.first_name, ' ', u.last_name)
                                                                      from flow.user u
                                                                      where u.archived is false
                                                                        and (u.search_phone = st.search_external_phone)
                                                                      limit 1)
                                                                 else
                                                                     (select concat(c.first_name, ' ', c.last_name)
                                                                      from flow.contact c
                                                                      where c.archived is false
                                                                        and (c.search_phones = st.search_external_phone)
                                                                      order by c.date_created desc
                                                                      limit 1) end as full_name,
                                                            case when st.recipient_type_id = 2 then
                                                                     (select s.abbreviation
                                                                      from flow.contact c
                                                                               inner join flow.company_state cs on c.company_state_id = cs.id
                                                                               inner join flow.state s on cs.state_id = s.id
                                                                      where c.archived is false
                                                                        and (c.search_phones = st.search_external_phone)
                                                                      order by c.date_created desc
                                                                      limit 1
                                                                     )
                                                                end as state_abbreviation,
                                                            (coalesce((SELECT array_to_json(array_agg(row_to_json(st)))
                                                                       FROM (select st2.id,
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
                                                                               and sto.archived = false) st), '[]')) as "smsTeamOwners",
                                                            case when rt.external then
                                                                coalesce((SELECT ARRAY_TO_JSON(array_agg(row_to_json(projects)))
                                                                      FROM (SELECT p.id as "id",
                                                                                   p.project_name as "fullName",
                                                                                   cpst.project_status_type as "projectStatusType",
                                                                                   p.date_modified as "dateModified"
                                                                            FROM flow.project p
                                                                                     inner join flow.contact c on p.contact_id = c.id
                                                                                     inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
                                                                            WHERE p.archived is false
                                                                              and c.archived is false
                                                                              and c.search_phones = st.search_external_phone
                                                                            order by p.date_modified desc
                                                                           ) projects),'[]')
                                                                else
                                                                    coalesce((SELECT ARRAY_TO_JSON(array_agg(row_to_json(users)))
                                                                              FROM (SELECT u.id as "id",
                                                                                           concat(u.first_name, ' ', u.last_name) as "fullName"
                                                                                    FROM flow.user u
                                                                                    WHERE u.archived is false
                                                                                      and u.search_phone = st.search_external_phone
                                                                                    order by u.date_modified desc
                                                                                   ) users),'[]') end
                                                                AS sources
                                                        from flow.sms_thread st
                                                                 inner join flow.recipient_type rt on st.recipient_type_id = rt.id
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
  public final static String getThreadsBySmsTeam = """
    select distinct sms_thread_id
      from flow.sms_thread_owner pmt
        where pmt.sms_team_id = :smsTeamId
        and archived = false
    """;

  //language=PostgreSQL
  public final static String updateThreadClosedValue = """
    update flow.sms_thread
    set closed = :closed,
        date_modified = now()
      where parent_id = :smsThreadId
    """;

  //language=PostgreSQL
  public final static String getOwnersForThread = """
    select distinct user_id, sms_team_id
    from flow.sms_thread_owner
     where sms_thread_id = :threadId
     and archived is false
    """;

  //language=PostgreSQL
  public final static String getThreadHistory = """
    select * from coalesce((
       SELECT array_to_json(array_agg(row_to_json(history)))
       FROM (
                 select st.team_name, u.first_name || ' ' || u.last_name as "userName", pmoh.date_created, date_removed,
                                                            (select u1.first_name || ' ' || u1.last_name from flow.user u1 where u1.id = pmoh.created_by_id) as "addedBy",
                                                            (select u2.first_name || ' ' || u2.last_name from flow.user u2 where u2.id = pmoh.modified_by_id) as "removedBy"
                                                     from flow.sms_thread_owner_audit pmoh
                                                              inner join flow.sms_team st on pmoh.sms_team_id = st.id
                                                              left join flow.user u on pmoh.user_id = u.id
                                                     where sms_thread_owner_id in (
                                                          select sto.id
                                                              from flow.sms_thread_owner sto
                                                                  where sto.sms_thread_id = :threadId
                                                         )
                                                     order by pmoh.date_modified desc
            ) history), '[]') AS "conversationHistory"
    """;

  //language=PostgreSQL
  public final static String getStaleThreads = """
    select parent_id from flow.sms_thread pmp
    where pmp.is_last_inserted is true 
      and pmp.date_created < ((now() AT TIME ZONE 'US/Mountain') :: DATE) - 3
    """;

  //language=PostgreSQL
  public final static String handleSmsTeamCreation = """
     select clear_unassigned, array_to_json(newly_selected_user_ids) as newly_selected_user_ids
     from flow.handle_sms_team_creation(:threadId::bigint, :teamId::bigint, :currentUserId::bigint, :selectedUserIds::bigint[])
  """;

  //language=PostgreSQL
  public final static String removeThreadOwner = """
    update flow.sms_thread_owner
      set archived = true,
          modified_by_id = :modifiedById,
          date_modified = now()
      where sms_thread_id = :thread_id
      and user_id = :userId
      and sms_team_id = :smsTeamId
    """;


  //language=PostgreSQL
  public final static String removeEntireThreadTeam = """
    update flow.sms_thread_owner
        set archived = true,
          date_modified = now(),
          modified_by_id = :modifiedById
        where sms_thread_id = :threadId
      and sms_team_id = :smsTeamId
    """;

  //language=PostgreSQL
  public final static String closeThread = """
    update flow.sms_thread
     set closed = true,
         date_modified = now()
       where parent_id = :threadId
    """;

  //language=PostgreSQL
  public final static String removeAllThreadTeams = """
      update flow.sms_thread_owner
      set archived = true,
          date_modified = now(),
          modified_by_id = :modifiedById
        where sms_thread_id = :threadId
        and user_id is null
    """;

  //language=PostgreSQL
  public final static String markThreadSmsAsReadForUser = """
    update flow.notification
    set message_read_tsz   = now(),
        date_modified  = now(),
        modified_by_id = :modifiedById
    where notification_topic_id = :notificationTopicId
      and user_id = :userId
      and (metadata->>'threadId')::bigint = :threadId
      and (metadata->>'smsTeamId')::bigint = :smsTeamId
      and message_read_tsz is null
    """;

  //language=PostgreSQL
  public final static String markThreadSmsAsReadForTeam = """
    update flow.notification
    set message_read_tsz   = now(),
        date_modified  = now(),
        modified_by_id = :modifiedById
    where notification_topic_id = :notificationTopicId
      and (metadata->'threadId')::bigint = :threadId
      and (metadata->'smsTeamId')::bigint = :smsTeamId
      and message_read_tsz is null
    """;

  //language=PostgreSQL
  public final static String findUserByForThreadTeam = """
    select distinct user_id
    from flow.notification
    where notification_topic_id = :notificationTopicId
      and (metadata -> 'threadId')::bigint = :threadId
      and (metadata -> 'smsTeamId')::bigint = :smsTeamId
    """;

  //language=PostgreSQL
  public final static String markSmsAsReadForThread = """
    update flow.notification
    set message_read_tsz   = now(),
        date_modified  = now(),
        modified_by_id = :modifiedById
    where notification_topic_id = :notificationTopicId
      and (metadata->'threadId')::bigint = :threadId
      and message_read_tsz is null
    """;

  //language=PostgreSQL
  public final static String findUserByForThread = """
    select distinct user_id
    from flow.notification
    where notification_topic_id = :notificationTopicId
      and (metadata -> 'threadId')::bigint = :threadId
    """;

}
