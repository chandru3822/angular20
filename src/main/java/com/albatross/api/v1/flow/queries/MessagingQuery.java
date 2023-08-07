package com.albatross.api.v1.flow.queries;

public class MessagingQuery {

  //language=PostgreSQL
  public final static String getProjects = """
    with projects as (select distinct on (p.id) p.id                                   as project_id,
                                                p.contact_id,
                                                p.project_name,
                                                c.search_phones                        as mobile,
                                                s.abbreviation                         as state,
                                                concat(u.first_name, ' ', u.last_name) as "name"
                      from flow.project p
                               inner join flow.contact c ON c.id = p.contact_id
                               left outer join flow.company_state cs on p.company_state_id = cs.id
                               left outer join flow.state s ON s.id = cs.state_id
                               inner join flow.project_message_properties pmp on pmp.project_id = p.id
                               left join flow.project_message_team pmt on pmt.project_id = p.id and pmt.archived is false
                               left join flow.project_message_owner pmo2
                                         on pmo2.sms_team_id = pmt.sms_team_id and pmo2.project_id = p.id and pmo2.archived is false
                               left join flow.user u on pmo2.user_id = u.id
                      where case
                                when array_length( array [ :notifProjectIds  ]::bigint[], 1) > 0 then
                                    (p.id = any ( array [ :notifProjectIds ]::bigint[] ))
                                else 1=1 end
                            and case
                                when :query::varchar is not null then
                                            lower(p.project_name) like '%' || lower(:query) || '%' or
                                            p.id::varchar like '%' || lower(:query) || '%'  or
                                            lower(concat(u.first_name, ' ', u.last_name)) like '%' || lower(:query) || '%'
                                else 1 = 1 end
                        and (pmt.sms_team_id = any (array [ :smsTeamIds ]::bigint[]) and
                             (exists(select id
                                     from flow.project_message_owner pmo3
                                     where case
                                               when array_length( array [ :ownerIds ]::bigint[], 1) > 0 then
                                                       (pmo3.user_id = any ( array [ :ownerIds ]::bigint[] )) and
                                                       pmo3.sms_team_id = any (array [ :smsTeamIds ]::bigint[])
                                                       and pmo3.project_id = p.id and pmo3.archived is false
                                               end) or
                              case
                                  when :unassigned is true then
                                      pmo2.id is null end)
                          )
                        ),
         last_message as (select distinct on (project_id) project_id, message, recipient_type_id, last_message_sent, outbound_message from
                                 (select p.project_id,
                                         q.message,
                                         q.recipient_type_id,
                                         max(q.created) as last_message_sent,
                                         true           as outbound_message
                                  from flow.sms_queue q
                                           inner join projects p on q.search_to_phone = p.mobile
                                  where q.recipient_type_id = 2
                                     AND error_message IS NULL
                                     OR (LOWER(error_message) IN ('api.twilio.com:443 failed to respond')
                                      -- so we don't retry very very old texts
                                      AND created >= '2017-11-08')
                                  group by p.project_id, message, recipient_type_id
                                  union all
                                select p.project_id,
                                         body               as message,
                                         2                  as recipient_type_id,
                                         max(date_received) as last_message_sent,
                                         false              as outbound_message
                                  from flow.sms_reply sr
                                           inner join projects p on sr.search_from_phone = p.mobile
                                  where sr.to_phone = '+18014480212'
                                  group by p.project_id, body, recipient_type_id) lastm order by project_id, last_message_sent desc
                            )
    select p.project_id,
           p.project_name,
           p.state,
           (coalesce((SELECT array_to_json(array_agg(row_to_json(st)))
                      FROM (select st.id,
                                   st.team_name                                              as "teamName",
                                   coalesce((SELECT array_to_json(array_agg(row_to_json(tb)))
                                             FROM (SELECT pmo.id,
                                                          pmo.user_id                            as "userId",
                                                          concat(u.first_name, ' ', u.last_name) as "name",
                                                          pmo.sms_team_id                        as "smsTeamId",
                                                          pmo.archived
                                                   FROM flow.project_message_owner pmo
                                                            inner join flow.user u on pmo.user_id = u.id
                                                       and pmo.project_id = pmt.project_id
                                                       and pmo.sms_team_id = pmt.sms_team_id
                                                       and pmo.archived is false) tb), '[]') AS "users"
                            from flow.project_message_team pmt
                                     inner join flow.sms_team st on pmt.sms_team_id = st.id
                            where pmt.project_id = p.project_id
                              and pmt.archived is false) st), '[]'))                       as "smsTeamOwners",
           (coalesce((select array_to_json(array_agg(row_to_json(mh)))
                      from (select distinct on (lm.project_id) lm.message,
                                                               lm.recipient_type_id as "recipientTypeId",
                                                               lm.last_message_sent as "lastMessageSent",
                                                               lm.outbound_message as "outboundMessage"
                            from last_message lm
                            where lm.project_id = p.project_id
                            order by lm.project_id, lm.last_message_sent desc) mh), '[]')) as message_history
    from projects p where
        (case when :showInbox then
            (select lm.outbound_message from last_message lm where lm.project_id = p.project_id order by lm.last_message_sent desc limit 1) is false
        else
            ((select lm.outbound_message from last_message lm where lm.project_id = p.project_id order by lm.last_message_sent desc limit 1) is null
                or
            (select lm.outbound_message from last_message lm where lm.project_id = p.project_id order by lm.last_message_sent desc limit 1) is true)
        end)
    limit :limit offset :offset;
        """;

  //language=PostgreSQL
  public final static String getProjectsCount = """
    with projects as (select distinct on (p.id) p.id                                   as project_id,
                                               p.contact_id,
                                               p.project_name,
                                               c.search_phones                        as mobile,
                                               s.abbreviation                         as state,
                                               concat(u.first_name, ' ', u.last_name) as "name"
                     from flow.project p
                              inner join flow.contact c ON c.id = p.contact_id
                              left outer join flow.company_state cs on p.company_state_id = cs.id
                              left outer join flow.state s ON s.id = cs.state_id
                              inner join flow.project_message_properties pmp on pmp.project_id = p.id
                              left join flow.project_message_team pmt on pmt.project_id = p.id and pmt.archived is false
                              left join flow.project_message_owner pmo2
                                        on pmo2.sms_team_id = pmt.sms_team_id and pmo2.project_id = p.id and pmo2.archived is false
                              left join flow.user u on pmo2.user_id = u.id
                     where case
                               when :query::varchar is not null then
                                           lower(p.project_name) like '%' || lower(:query) || '%' or
                                           p.id::varchar like '%' || lower(:query) || '%'  or
                                           lower(concat(u.first_name, ' ', u.last_name)) like '%' || lower(:query) || '%'
                               else 1 = 1 end
                       and (pmt.sms_team_id = any (array [ :smsTeamIds ]::bigint[]) and
                            (exists(select id
                                    from flow.project_message_owner pmo3
                                    where case
                                              when array_length( array [ :ownerIds ]::bigint[], 1) > 0 then
                                                      (pmo3.user_id = any ( array [ :ownerIds ]::bigint[] )) and
                                                      pmo3.sms_team_id = any (array [ :smsTeamIds ]::bigint[])
                                                      and pmo3.project_id = p.id and pmo3.archived is false
                                              end) or
                             case
                                 when :unassigned is true then
                                     pmo2.id is null end)
                         )
                     ),
          last_message as (select distinct on (project_id) project_id, last_message_sent, outbound_message from (select p.project_id,
                                        max(q.created) as last_message_sent,
                                        true           as outbound_message
                                 from flow.sms_queue q
                                          inner join projects p on q.search_to_phone = p.mobile
                                 where error_message IS NULL
                                    OR (LOWER(error_message) IN ('api.twilio.com:443 failed to respond')
                                     -- so we don't retry very very old texts
                                     AND created >= '2017-11-08')
                                     AND q.recipient_type_id = 2
                                 group by p.project_id
                                 union all
                               select p.project_id,
                                        max(date_received) as last_message_sent,
                                        false              as outbound_message
                                 from flow.sms_reply sr
                                          inner join projects p on sr.search_from_phone = p.mobile
                                 where sr.to_phone = '+18014480212'
                                 group by p.project_id) lastm order by project_id, last_message_sent desc
                           )
      select p.project_id
             from projects p
               left join last_message lm on lm.project_id = p.project_id where
       case
             when :showInbox
                 then lm.outbound_message is false
             else lm.outbound_message is null or lm.outbound_message is true
             end
       """;

  //language=PostgreSQL
  public final static String getProject = """
    select p.id                                                     as projectId,
              p.project_name,
              s.abbreviation                                           as state,
              c.company_id,
              (coalesce((SELECT array_to_json(array_agg(row_to_json(st)))
                         FROM (select st.id,
                                      st.team_name                                                        as "teamName",
                                      coalesce((SELECT array_to_json(array_agg(row_to_json(tb)))
                                                FROM (SELECT pmo.id,
                                                             pmo.user_id                            as "userId",
                                                             concat(u.first_name, ' ', u.last_name) as "name",
                                                             pmo.sms_team_id                        as "smsTeamId",
                                                             pmo.archived
                                                      FROM flow.project_message_owner pmo
                                                               inner join flow.user u on pmo.user_id = u.id
                                                      WHERE pmo.archived = false
                                                        and pmo.project_id = p.id
                                                        and pmo.sms_team_id = pmt.sms_team_id) tb), '[]') AS "users"
                               from flow.project_message_team pmt
                                        inner join flow.sms_team st on pmt.sms_team_id = st.id
                               where pmt.project_id = p.id
                                 and pmt.archived = false) st), '[]')) as "smsTeamOwners"
       from flow.project p
                inner join flow.project_message_properties pmp on p.id = pmp.project_id
                inner join flow.contact c ON c.id = p.contact_id
                left outer join flow.company_state cs on cs.id = p.company_state_id
                left outer join flow.state s on s.id = cs.state_id
       where p.id = :projectId
       """;

  //language=PostgreSQL
  public final static String getUsers = """
    with users as (select distinct on (u.id)    u.id                                   as user_id,
                                                concat(u.first_name, ' ', u.last_name) as "name",
                                                u.search_phone                        as mobile
                      from flow.user u
                               inner join flow.user_message_properties ump on ump.user_id = u.id
                               left join flow.user_message_team umt on umt.user_id = u.id and umt.archived is false
                               left join flow.user_message_owner umo2
                                         on umo2.sms_team_id = umt.sms_team_id and umo2.user_id = u.id and umo2.archived is false
                      where case
                                when array_length( array [ :notifUserIds  ]::bigint[], 1) > 0 then
                                    (u.id = any ( array [ :notifUserIds ]::bigint[] ))
                                else 1=1 end
                            and case
                                when :query::varchar is not null then
                                            u.id::varchar like '%' || lower(:query) || '%'  or
                                            lower(concat(u.first_name, ' ', u.last_name)) like '%' || lower(:query) || '%'
                                else 1 = 1 end
                        and (umt.sms_team_id = any (array [ :smsTeamIds ]::bigint[]) and
                             (exists(select id
                                     from flow.user_message_owner umo3
                                     where case
                                               when array_length( array [ :ownerIds ]::bigint[], 1) > 0 then
                                                       (umo3.user_id = any ( array [ :ownerIds ]::bigint[] )) and
                                                       umo3.sms_team_id = any (array [ :smsTeamIds ]::bigint[])
                                                       and umo3.owner_user_id = u.id and umo3.archived is false
                                               end) or
                              case
                                  when :unassigned is true then
                                      umo2.id is null end)
                          )
                        ),
         last_message as (select distinct on (user_id) user_id, message, recipient_type_id, last_message_sent, outbound_message from
                                 (select u.user_id,
                                         q.message,
                                         q.recipient_type_id,
                                         max(q.created) as last_message_sent,
                                         true           as outbound_message
                                  from flow.sms_queue q
                                           inner join users u on q.search_to_phone = u.mobile
                                  where q.recipient_type_id = 1
                                     AND error_message IS NULL
                                     OR (LOWER(error_message) IN ('api.twilio.com:443 failed to respond')
                                      -- so we don't retry very very old texts
                                      AND created >= '2017-11-08')
                                  group by u.user_id, message, recipient_type_id
                                  union all
                                select u.user_id,
                                         body               as message,
                                         1                  as recipient_type_id,
                                         max(date_received) as last_message_sent,
                                         false              as outbound_message
                                  from flow.sms_reply sr
                                           inner join users u on sr.search_from_phone = u.mobile
                                  where sr.to_phone = '+18014480029'
                                  group by u.user_id, body, recipient_type_id) lastm order by user_id, last_message_sent desc
                            )
    select u.user_id,
           u.name as "fullName",
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
                              and umt.archived is false) st), '[]'))                       as "smsTeamOwners",
           (coalesce((select array_to_json(array_agg(row_to_json(mh)))
                      from (select distinct on (lm.user_id) lm.message,
                                                               lm.recipient_type_id as "recipientTypeId",
                                                               lm.last_message_sent as "lastMessageSent",
                                                               lm.outbound_message as "outboundMessage"
                            from last_message lm
                            where lm.user_id = u.user_id
                            order by lm.user_id, lm.last_message_sent desc) mh), '[]')) as message_history
    from users u where
        (case when :showInbox then
            (select lm.outbound_message from last_message lm where lm.user_id = u.user_id order by lm.last_message_sent desc limit 1) is false
        else
            ((select lm.outbound_message from last_message lm where lm.user_id = u.user_id order by lm.last_message_sent desc limit 1) is null
                or
            (select lm.outbound_message from last_message lm where lm.user_id = u.user_id order by lm.last_message_sent desc limit 1) is true)
        end)
    limit :limit offset :offset;
        """;

  //language=PostgreSQL
  public final static String getUsersCount = """
    with users as (select distinct on (u.id) u.id                                   as user_id,
                                               u.search_phone                        as mobile,
                                               concat(u.first_name, ' ', u.last_name) as "name"
                     from flow.user u
                              inner join flow.user_message_properties ump on ump.user_id = u.id
                              left join flow.user_message_team umt on umt.user_id = u.id and umt.archived is false
                              left join flow.user_message_owner umo2
                                        on umo2.sms_team_id = umt.sms_team_id and umo2.user_id = u.id and umo2.archived is false
                     where case
                               when :query::varchar is not null then
                                           u.id::varchar like '%' || lower(:query) || '%'  or
                                           lower(concat(u.first_name, ' ', u.last_name)) like '%' || lower(:query) || '%'
                               else 1 = 1 end
                       and (umt.sms_team_id = any (array [ :smsTeamIds ]::bigint[]) and
                            (exists(select id
                                    from flow.user_message_owner umo3
                                    where case
                                              when array_length( array [ :ownerIds ]::bigint[], 1) > 0 then
                                                      (umo3.user_id = any ( array [ :ownerIds ]::bigint[] )) and
                                                      umo3.sms_team_id = any (array [ :smsTeamIds ]::bigint[])
                                                      and umo3.owner_user_id  = u.id and umo3.archived is false
                                              end) or
                             case
                                 when :unassigned is true then
                                     umo2.id is null end)
                         )
                     ),
          last_message as (select distinct on (user_id) user_id, last_message_sent, outbound_message from (select u.user_id,
                                        max(q.created) as last_message_sent,
                                        true           as outbound_message
                                 from flow.sms_queue q
                                          inner join users u on q.search_to_phone = u.mobile
                                 where error_message IS NULL
                                    OR (LOWER(error_message) IN ('api.twilio.com:443 failed to respond')
                                     -- so we don't retry very very old texts
                                     AND created >= '2017-11-08')
                                     AND q.recipient_type_id = 1
                                 group by u.user_id
                                 union all
                               select u.user_id,
                                        max(date_received) as last_message_sent,
                                        false              as outbound_message
                                 from flow.sms_reply sr
                                          inner join users u on sr.search_from_phone = u.mobile
                                 where sr.to_phone = '+18014480029'
                                 group by u.user_id) lastm order by user_id, last_message_sent desc
                           )
      select u.user_id
             from users u
               left join last_message lm on lm.user_id = u.user_id where
       case
             when :showInbox
                 then lm.outbound_message is false
             else lm.outbound_message is null or lm.outbound_message is true
             end
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
      and (metadata -> 'userId')::bigint = :ownerUserId
      and (metadata -> 'smsTeamId')::bigint = :smsTeamId
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
