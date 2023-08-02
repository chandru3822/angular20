package com.albatross.api.v1.flow.queries;

public class UserActivityQuery {

  //language=PostgreSQL
  public final static String getActivityTopicsByUser = """
    select a.id,
           a.activity_type,
           a.display_order,
           coalesce((SELECT array_to_json(array_agg(row_to_json(ht)))
                     FROM (

                            select pah.hashtag_id as "hashtagId",
                                   h.hashtag,
                                   count(pah.*) as "activityCount",
                                   0 as fake_display_order,
                                   max(pa.date_modified) as "lastUpdated",
                                   coalesce((SELECT array_to_json(array_agg(row_to_json(ht)))
                                     from (
                                             select pa2.id,
                                                    pa2.note,
                                                    pa2.user_id as "userId",
                                                    pa2.activity_type_id as "activityTypeId",
                                                    pa2.date_modified as "dateModified",
                                                    pa2.date_created as "dateCreated",
                                                    pa2.pinned,
                                                    pa2.created_by_id as "createdById",
                                                    concat(u.first_name, ' ', u.last_name) as "createdBy",
                                                    case when ups.user_position_id is not null then concat(ups.position, ' (', ups.org_name, ')') end as "createdByPosition",
                                                    pa2.pinned_by_id as "pinnedById",
                                                    concat(pin.first_name, ' ', pin.last_name) as "pinnedBy",
                                                    pa2.archived,
                                                    pa2.modified_by_id as "modifiedById",
                                                    concat(mod.first_name, ' ', mod.last_name) as "modifiedBy",
                                                    pa2.activity_type_id as "activityTypeId",
                                                    coalesce((SELECT array_to_json(array_agg(row_to_json(ht)))
                                                       FROM (select pah3.id,
                                                                    pah3.user_activity_id as "userActivityId",
                                                                    pah3.hashtag_id as "hashtagId",
                                                                    pah3.date_created as "dateCreated",
                                                                    pah3.date_modified as "dateModified",
                                                                    pah3.created_by_id as "createdById",
                                                                    pah3.modified_by_id as "modifiedById",
                                                                    h3.hashtag_type_id as "hashtagTypeId",
                                                                    pah3.archived,
                                                                    h3.hashtag,
                                                                    ht3.hashtag_type
                                                            from flow.user_activity_hashtag pah3
                                                            inner join flow.hashtag h3 on h3.id = pah3.hashtag_id
                                                            inner join flow.hashtag_type ht3 on ht3.id = h3.hashtag_type_id
                                                            where pah3.user_activity_id = pah2.user_activity_id
                                                            and pah3.archived is false) ht), '[]') AS "activityHashtags"
                                             from flow.user_activity_hashtag pah2
                                                    inner join flow.user_activity pa2 on pa2.id = pah2.user_activity_id and pa2.user_id = :sourceId and pa2.archived is false
                                                    inner join flow."user" u on u.id = pa2.created_by_id
                                                    inner join flow."user" mod on mod.id = pa2.modified_by_id
                                                    left join flow."user" pin on pin.id = pa2.pinned_by_id
                                                    left JOIN (SELECT DISTINCT up.id as user_position_id, up.user_id, p.position, o.org_name, o.id as org_id
                                                                              from flow.user_position up
                                                                                       inner join flow.position p on p.id = up.position_id and p.company_id = :companyId
                                                                                       inner join flow.org o on o.id = up.org_id and o.company_id = :companyId
                                                                              where up.primary_flag is true
                                                                                and up.archived is false) AS ups ON ups.user_id = pa2.created_by_id
                                             where pa2.activity_type_id = a.id
                                               and pah2.archived is false
                                               and pa2.archived is false
                                               and pah2.hashtag_id = pah.hashtag_id
                                    ) ht), '[]')::jsonb as "activities"
                            from flow.user_activity_hashtag pah
                                   inner join flow.user_activity pa on pa.id = pah.user_activity_id and pa.user_id = :sourceId and pa.archived is false
                                   inner join flow.hashtag h on h.id = pah.hashtag_id and pa.activity_type_id = a.id
                            where pa.activity_type_id = a.id
                              and pah.archived is false
                            group by hashtag_id, hashtag
                            union
                            select -1 as "hashtagId",
                                   'uncategorized' as hashtag,
                                   count(pa.*) as "activityCount",
                                   1 as fake_display_order,
                                   max(pa.date_modified) as "lastUpdated",
                                   coalesce((SELECT array_to_json(array_agg(row_to_json(ht)))
                                             from (
                                                    select pa2.id,
                                                           pa2.note,
                                                           pa2.user_id as "userId",
                                                           pa2.activity_type_id as "activityTypeId",
                                                           pa2.date_modified as "dateModified",
                                                           pa2.date_created as "dateCreated",
                                                           pa2.pinned,
                                                           pa2.created_by_id as "createdById",
                                                           concat(u.first_name, ' ', u.last_name) as "createdBy",
                                                           case when ups.user_position_id is not null then concat(ups.position, ' (', ups.org_name, ')') end as "createdByPosition",
                                                           pa2.pinned_by_id as "pinnedById",
                                                           concat(pin.first_name, ' ', pin.last_name) as "pinnedBy",
                                                           pa2.archived,
                                                           pa2.modified_by_id as "modifiedById",
                                                           concat(mod.first_name, ' ', mod.last_name) as "modifiedBy",
                                                           pa2.activity_type_id as "activityTypeId"
                                                    from flow.user_activity pa2
                                                           inner join flow."user" u on u.id = pa2.created_by_id
                                                           inner join flow."user" mod on mod.id = pa2.modified_by_id
                                                           left join flow."user" pin on pin.id = pa2.pinned_by_id
                                                           left JOIN (SELECT DISTINCT up.id as user_position_id, up.user_id, p.position, o.org_name, o.id as org_id
                                                                                     from flow.user_position up
                                                                                              inner join flow.position p on p.id = up.position_id and p.company_id = :companyId
                                                                                              inner join flow.org o on o.id = up.org_id and o.company_id = :companyId
                                                                                     where up.primary_flag is true
                                                                                       and up.archived is false) AS ups ON ups.user_id = pa2.created_by_id
                                                    where pa2.archived is false
                                                      and pa2.user_id = :sourceId
                                                      and pa2.activity_type_id = a.id
                                                      and pa2.id not in (
                                                      select pah2.user_activity_id from flow.user_activity_hashtag pah2
                                                      where pah2.user_activity_id = pa2.id
                                                        and pah2.archived is false
                                                    )
                                                  ) ht), '[]')::jsonb as "activities"
                            from flow.user_activity pa
                            where pa.archived is false
                              and pa.user_id = :sourceId
                              and pa.activity_type_id = a.id
                              and pa.id not in (
                              select pah.user_activity_id from flow.user_activity_hashtag pah
                              where pah.user_activity_id = pa.id
                                and pah.archived is false
                            )
                            order by fake_display_order, hashtag
                          ) ht), '[]') AS "activityTypeHashtags"
    from flow.activity_type a
    order by a.display_order
  """;

  //language=PostgreSQL
  public final static String getUserActivities = """
      select pa.id,
             pa.user_id,
             pa.activity_type_id,
             pa.date_modified,
             pa.note,
             pa.date_created,
             pa.pinned,
             pa.created_by_id,
             concat(u.first_name, ' ', u.last_name) as "createdBy",
             ups.position  as "createdByPosition",
             ups.org_name  as "createdByPositionOrg",
             ups.org_id        as "createdByPositionOrgId",
             pa.pinned_by_id as "pinnedById",
             concat(pin.first_name, ' ', pin.last_name) as "pinnedBy",
             pa.modified_by_id,
             concat(mod.first_name, ' ', mod.last_name) as "modifiedBy",
             pa.archived,
             pa.activity_type_id,
             coalesce((SELECT array_to_json(array_agg(row_to_json(ht)))
                                             FROM (select pah.id,
                                                          pah.user_activity_id as "userActivityId",
                                                          pah.hashtag_id as "hashtagId",
                                                          pah.date_created as "dateCreated",
                                                          pah.date_modified as "dateModified",
                                                          pah.created_by_id as "createdById",
                                                          pah.modified_by_id as "modifiedById",
                                                          h.hashtag_type_id as "hashtagTypeId",
                                                          pah.archived,
                                                          h.hashtag,
                                                          ht.hashtag_type
                                                  from flow.user_activity_hashtag pah
                                                  inner join flow.hashtag h on h.id = pah.hashtag_id
                                                  inner join flow.hashtag_type ht on ht.id = h.hashtag_type_id
                                                  where pah.user_activity_id = pa.id
                                                  and pah.archived is false) ht), '[]') AS "activityHashtags"
      from flow.user_activity pa
        inner join flow."user" u on u.id = pa.created_by_id
        inner join flow."user" mod on mod.id = pa.modified_by_id
        left join flow."user" pin on pin.id = pa.pinned_by_id
        left JOIN (SELECT DISTINCT up.id as user_position_id, up.user_id, p.position, o.org_name, o.id as org_id
                                  from flow.user_position up
                                           inner join flow.position p on p.id = up.position_id and p.company_id = :companyId
                                           inner join flow.org o on o.id = up.org_id and o.company_id = :companyId
                                  where up.primary_flag is true
                                    and up.archived is false) AS ups ON ups.user_id = pa.created_by_id
      where pa.archived is false
       and pa.user_id = :sourceId
    """;

  //language=PostgreSQL
  public final static String archiveUserActivity = """
      update flow.user_activity
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
      where id = :activityId
    """;

  //language=PostgreSQL
  public final static String saveUserActivityPinned = """
      update flow.user_activity
      set pinned = :pinned,
          date_pinned = now(),
          pinned_by_id = :userId
      where id = :activityId
    """;

  //language=PostgreSQL
  public final static String getUserActivity = """
      select pa.id,
             pa.user_id,
             pa.date_modified,
             pa.activity_type_id,
             pa.note,
             pa.pinned,
             pa.date_created,
             pa.created_by_id,
             concat(u.first_name, ' ', u.last_name) as "createdBy",
             case when ups.user_position_id is not null then concat(ups.position, ' (', ups.org_name, ')') end as "createdByPosition",
             pa.pinned_by_id as "pinnedById",
             concat(pin.first_name, ' ', pin.last_name) as "pinnedBy",
             pa.modified_by_id,
             concat(mod.first_name, ' ', mod.last_name) as "modifiedBy",
             pa.archived,
             pa.activity_type_id,
              coalesce((SELECT array_to_json(array_agg(row_to_json(ht)))
                                             FROM (select pah.id,
                                                          pah.user_activity_id as "userActivityId",
                                                          pah.hashtag_id as "hashtagId",
                                                          pah.date_created as "dateCreated",
                                                          pah.date_modified as "dateModified",
                                                          pah.created_by_id as "createdById",
                                                          pah.modified_by_id as "modifiedById",
                                                          h.hashtag_type_id as "hashtagTypeId",
                                                          pah.archived,
                                                          h.hashtag,
                                                          ht.hashtag_type
                                                  from flow.user_activity_hashtag pah
                                                  inner join flow.hashtag h on h.id = pah.hashtag_id
                                                  inner join flow.hashtag_type ht on ht.id = h.hashtag_type_id
                                                  where pah.user_activity_id = pa.id
                                                  and pah.archived is false) ht), '[]') AS "activityHashtags"
      from flow.user_activity pa
        inner join flow."user" u on u.id = pa.created_by_id
        inner join flow."user" mod on mod.id = pa.modified_by_id
        left join flow."user" pin on pin.id = pa.pinned_by_id
        left JOIN (SELECT DISTINCT up.id as user_position_id, up.user_id, p.position, o.org_name, o.id as org_id
                                  from flow.user_position up
                                           inner join flow.position p on p.id = up.position_id and p.company_id = :companyId
                                           inner join flow.org o on o.id = up.org_id and o.company_id = :companyId
                                  where up.primary_flag is true
                                    and up.archived is false) AS ups ON ups.user_id = pa.created_by_id
      where pa.archived is false
       and pa.id = :id
    """;

  //language=PostgreSQL
  public final static String addUserActivity = """
      insert into flow.user_activity(user_id, date_modified, note, date_created, created_by_id, modified_by_id, archived, activity_type_id)
      values (:sourceId, now(), :note, now(), :userId, :userId, false, :activityTypeId);
    """;

  //language=PostgreSQL
  public final static String editUserActivity = """
      update flow.user_activity
      set note = :note,
          date_modified = case when note != :note then now() else date_modified end,
          modified_by_id = case when note != :note then :userId else modified_by_id end
      where id = :activityId;
    """;


  //language=PostgreSQL
  public final static String archiveUserActivityHashtag = """
      update flow.user_activity_hashtag pah
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
      where id = :id
    """;

  //language=PostgreSQL
  public final static String setUserActivityModified = """
      update flow.user_activity pa
      set date_modified = now(),
          modified_by_id = :userId
      where id = :activityId
    """;

  //language=PostgreSQL
  public final static String upsertUserActivityHashtag = """
    insert into flow.user_activity_hashtag(user_activity_id, hashtag_id, date_created, date_modified, created_by_id, modified_by_id)
    values (:activityId, :hashtagId, now(), now(), :userId, :userId)
    on conflict (user_activity_id, hashtag_id)
    do update set archived = false, date_modified = now(), modified_by_id = :userId;
  """;


  //language=PostgreSQL
  public final static String getUserActivityHashtags = """
    select pah.id,
           pah.user_activity_id,
           pah.hashtag_id,
           pah.date_created,
           pah.date_modified,
           pah.created_by_id,
           pah.modified_by_id,
           pah.archived,
           h.hashtag,
           h.hashtag_type_id,
           ht.hashtag_type
    from flow.user_activity_hashtag pah
    inner join flow.hashtag h on h.id = pah.hashtag_id
    inner join flow.hashtag_type ht on ht.id = h.hashtag_type_id
    where pah.user_activity_id = :activityId
      and pah.archived is false
  """;

}
