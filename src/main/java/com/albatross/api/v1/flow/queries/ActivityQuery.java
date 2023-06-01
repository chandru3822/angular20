package com.albatross.api.v1.flow.queries;

public class ActivityQuery {

  //language=PostgreSQL
  public final static String getActivityTopicsByProject = """
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
                                                    pa2.linked,
                                                    pa2.project_id as "projectId",
                                                    pa2.activity_type_id as "activityTypeId",
                                                    pa2.date_modified as "dateModified",
                                                    pa2.date_created as "dateCreated",
                                                    pa2.linked_pps_id as "linkedPpsId",
                                                    pa2.linked_ppse_id as "linkedPpseId",
                                                    case when pa2.linked_ppse_id is not null then
                                                           ( select concat(e.event_name, ' (', ppse.id, ')')
                                                             from flow.project_process_step_event ppse
                                                                    inner join flow.process_step_event pse on pse.id = ppse.process_step_event_id
                                                                    inner join flow.event e on e.id = pse.event_id
                                                             where ppse.id = pa2.linked_ppse_id
                                                           )
                                                         when pa2.linked_pps_id is not null then
                                                           ( select concat(ps.process_step_name, ' (', pps.id, ')')
                                                             from flow.project_process_step pps
                                                                    inner join flow.process_step ps on ps.id = pps.process_step_id
                                                             where pps.id = pa2.linked_pps_id
                                                           )
                                                      end as "linkLabel",
                                                    pa2.pinned,
                                                    pa2.created_by_id as "createdById",
                                                    concat(u.first_name, ' ', u.last_name) as "createdBy",
                                                    concat(p.position, ' (', o.org_name, ')') as "createdByPosition",
                                                    pa2.pinned_by_id as "pinnedById",
                                                    concat(pin.first_name, ' ', pin.last_name) as "pinnedBy",
                                                    pa2.archived,
                                                    pa2.modified_by_id as "modifiedById",
                                                    concat(mod.first_name, ' ', mod.last_name) as "modifiedBy",
                                                    pa2.activity_type_id as "activityTypeId"
                                             from flow.project_activity_hashtag pah2
                                                    inner join flow.project_activity pa2 on pa2.id = pah2.project_activity_id and pa2.project_id = :sourceId and pa2.archived is false
                                                    inner join flow."user" u on u.id = pa2.created_by_id
                                                    inner join flow."user" mod on mod.id = pa2.modified_by_id
                                                    inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true and up.archived is false
                                                    inner join flow.position p on p.id = up.position_id
                                                    inner join flow.org o on o.id = up.org_id
                                                    left join flow."user" pin on pin.id = pa2.pinned_by_id
                                             where pa2.activity_type_id = a.id
                                               and pah2.archived is false
                                               and pa2.archived is false
                                               and pah2.hashtag_id = pah.hashtag_id
                                    ) ht), '[]')::jsonb as "activities"
                            from flow.project_activity_hashtag pah
                                   inner join flow.project_activity pa on pa.id = pah.project_activity_id and pa.project_id = :sourceId and pa.archived is false
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
                                                           pa2.linked,
                                                           pa2.project_id as "projectId",
                                                           pa2.activity_type_id as "activityTypeId",
                                                           pa2.date_modified as "dateModified",
                                                           pa2.date_created as "dateCreated",
                                                           pa2.linked_pps_id as "linkedPpsId",
                                                           pa2.linked_ppse_id as "linkedPpseId",
                                                           case when pa2.linked_ppse_id is not null then
                                                                  ( select concat(e.event_name, ' (', ppse.id, ')')
                                                                    from flow.project_process_step_event ppse
                                                                           inner join flow.process_step_event pse on pse.id = ppse.process_step_event_id
                                                                           inner join flow.event e on e.id = pse.event_id
                                                                    where ppse.id = pa2.linked_ppse_id
                                                                  )
                                                                when pa2.linked_pps_id is not null then
                                                                  ( select concat(ps.process_step_name, ' (', pps.id, ')')
                                                                    from flow.project_process_step pps
                                                                           inner join flow.process_step ps on ps.id = pps.process_step_id
                                                                    where pps.id = pa2.linked_pps_id
                                                                  )
                                                             end as "linkLabel",
                                                           pa2.pinned,
                                                           pa2.created_by_id as "createdById",
                                                           concat(u.first_name, ' ', u.last_name) as "createdBy",
                                                           concat(p.position, ' (', o.org_name, ')') as "createdByPosition",
                                                           pa2.pinned_by_id as "pinnedById",
                                                           concat(pin.first_name, ' ', pin.last_name) as "pinnedBy",
                                                           pa2.archived,
                                                           pa2.modified_by_id as "modifiedById",
                                                           concat(mod.first_name, ' ', mod.last_name) as "modifiedBy",
                                                           pa2.activity_type_id as "activityTypeId"
                                                    from flow.project_activity pa2
                                                           inner join flow."user" u on u.id = pa2.created_by_id
                                                           inner join flow."user" mod on mod.id = pa2.modified_by_id
                                                           inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true and up.archived is false
                                                           inner join flow.position p on p.id = up.position_id
                                                           inner join flow.org o on o.id = up.org_id
                                                           left join flow."user" pin on pin.id = pa2.pinned_by_id
                                                    where pa2.archived is false
                                                      and pa2.project_id = :sourceId
                                                      and pa2.activity_type_id = a.id
                                                      and pa2.id not in (
                                                      select pah2.project_activity_id from flow.project_activity_hashtag pah2
                                                      where pah2.project_activity_id = pa2.id
                                                        and pah2.archived is false
                                                    )
                                                  ) ht), '[]')::jsonb as "activities"
                            from flow.project_activity pa
                            where pa.archived is false
                              and pa.project_id = :sourceId
                              and pa.activity_type_id = a.id
                              and pa.id not in (
                              select pah.project_activity_id from flow.project_activity_hashtag pah
                              where pah.project_activity_id = pa.id
                                and pah.archived is false
                            )
                            order by fake_display_order, hashtag
                          ) ht), '[]') AS "activityTypeHashtags"
    from flow.activity_type a
    order by a.display_order
  """;

  //language=PostgreSQL
  public final static String getProjectActivities = """
      select pa.id,
             pa.project_id,
             pa.activity_type_id,
             pa.date_modified,
             pa.note,
             pa.date_created,
             pa.linked,
             pa.linked_pps_id,
             pa.linked_ppse_id,
             case when pa.linked_ppse_id is not null then
              ( select concat(e.event_name, ' (', ppse.id, ')')
                from flow.project_process_step_event ppse
                inner join flow.process_step_event pse on pse.id = ppse.process_step_event_id
                inner join flow.event e on e.id = pse.event_id
                where ppse.id = pa.linked_ppse_id
               )
              when pa.linked_pps_id is not null then
              ( select concat(ps.process_step_name, ' (', pps.id, ')')
                from flow.project_process_step pps
                inner join flow.process_step ps on ps.id = pps.process_step_id
                where pps.id = pa.linked_pps_id
               )
              end as link_label,
             pa.pinned,
             pa.created_by_id,
             concat(u.first_name, ' ', u.last_name) as "createdBy",
             concat(p.position, ' (', o.org_name, ')') as "createdByPosition",
             pa.pinned_by_id as "pinnedById",
             concat(pin.first_name, ' ', pin.last_name) as "pinnedBy",
             pa.modified_by_id,
             concat(mod.first_name, ' ', mod.last_name) as "modifiedBy",
             pa.archived,
             pa.activity_type_id,
             coalesce((SELECT array_to_json(array_agg(row_to_json(ht)))
                                             FROM (select pah.id,
                                                          pah.project_activity_id as "projectActivityId",
                                                          pah.hashtag_id as "hashtagId",
                                                          pah.date_created as "dateCreated",
                                                          pah.date_modified as "dateModified",
                                                          pah.created_by_id as "createdById",
                                                          pah.modified_by_id as "modifiedById",
                                                          h.hashtag_type_id as "hashtagTypeId",
                                                          pah.archived,
                                                          h.hashtag,
                                                          ht.hashtag_type
                                                  from flow.project_activity_hashtag pah
                                                  inner join flow.hashtag h on h.id = pah.hashtag_id
                                                  inner join flow.hashtag_type ht on ht.id = h.hashtag_type_id
                                                  where pah.project_activity_id = pa.id
                                                  and pah.archived is false) ht), '[]') AS "activityHashtags"
      from flow.project_activity pa
        inner join flow."user" u on u.id = pa.created_by_id
        inner join flow."user" mod on mod.id = pa.modified_by_id
        inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true and up.archived is false
        inner join flow.position p on p.id = up.position_id
        inner join flow.org o on o.id = up.org_id
        left join flow."user" pin on pin.id = pa.pinned_by_id
      where pa.archived is false
       and pa.project_id = :sourceId
    """;

  //language=PostgreSQL
  public final static String archiveProjectActivity = """
      update flow.project_activity
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
      where id = :activityId
    """;

  //language=PostgreSQL
  public final static String saveProjectActivityPinned = """
      update flow.project_activity
      set pinned = :pinned,
          date_pinned = now(),
          pinned_by_id = :userId
      where id = :activityId
    """;

  //language=PostgreSQL
  public final static String getProjectActivity = """
      select pa.id,
             pa.project_id,
             pa.date_modified,
             pa.activity_type_id,
             pa.note,
             pa.pinned,
             pa.linked,
             pa.linked_pps_id,
             pa.linked_ppse_id,
             case when pa.linked_ppse_id is not null then
              ( select concat(e.event_name, ' (', ppse.id, ')')
                from flow.project_process_step_event ppse
                inner join flow.process_step_event pse on pse.id = ppse.process_step_event_id
                inner join flow.event e on e.id = pse.event_id
                where ppse.id = pa.linked_ppse_id
               )
              when pa.linked_pps_id is not null then
              ( select concat(ps.process_step_name, ' (', pps.id, ')')
                from flow.project_process_step pps
                inner join flow.process_step ps on ps.id = pps.process_step_id
                where pps.id = pa.linked_pps_id
               )
              end as link_label,
             pa.date_created,
             pa.created_by_id,
             concat(u.first_name, ' ', u.last_name) as "createdBy",
             concat(p.position, ' (', o.org_name, ')') as "createdByPosition",
             pa.pinned_by_id as "pinnedById",
             concat(pin.first_name, ' ', pin.last_name) as "pinnedBy",
             pa.modified_by_id,
             concat(mod.first_name, ' ', mod.last_name) as "modifiedBy",
             pa.archived,
             pa.activity_type_id,
              coalesce((SELECT array_to_json(array_agg(row_to_json(ht)))
                                             FROM (select pah.id,
                                                          pah.project_activity_id as "projectActivityId",
                                                          pah.hashtag_id as "hashtagId",
                                                          pah.date_created as "dateCreated",
                                                          pah.date_modified as "dateModified",
                                                          pah.created_by_id as "createdById",
                                                          pah.modified_by_id as "modifiedById",
                                                          h.hashtag_type_id as "hashtagTypeId",
                                                          pah.archived,
                                                          h.hashtag,
                                                          ht.hashtag_type
                                                  from flow.project_activity_hashtag pah
                                                  inner join flow.hashtag h on h.id = pah.hashtag_id
                                                  inner join flow.hashtag_type ht on ht.id = h.hashtag_type_id
                                                  where pah.project_activity_id = pa.id
                                                  and pah.archived is false) ht), '[]') AS "activityHashtags"
      from flow.project_activity pa
        inner join flow."user" u on u.id = pa.created_by_id
        inner join flow."user" mod on mod.id = pa.modified_by_id
        inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true and up.archived is false
        inner join flow.position p on p.id = up.position_id
        inner join flow.org o on o.id = up.org_id
        left join flow."user" pin on pin.id = pa.pinned_by_id
      where pa.archived is false
       and pa.id = :id
    """;

  //language=PostgreSQL
  public final static String addProjectActivity = """
      insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id, archived, activity_type_id, linked, linked_pps_id,linked_ppse_id)
      values (:sourceId, now(), :note, now(), :userId, :userId, false, :activityTypeId, :linked, :linkedPpsId, :linkedPpseId);
    """;

  //language=PostgreSQL
  public final static String editProjectActivity = """
      update flow.project_activity
      set note = :note,
          date_modified = case when note != :note then now() else date_modified end,
          modified_by_id = case when note != :note then :userId else modified_by_id end,
          linked = :linked,
          linked_pps_id = :linkedPpsId,
          linked_ppse_id = :linkedPpseId
      where id = :activityId;
    """;


  //language=PostgreSQL
  public final static String archiveProjectActivityHashtag = """
      update flow.project_activity_hashtag pah
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
      where id = :id
    """;

  //language=PostgreSQL
  public final static String setProjectActivityModified = """
      update flow.project_activity pa
      set date_modified = now(),
          modified_by_id = :userId
      where id = :activityId
    """;

  //language=PostgreSQL
  public final static String upsertProjectActivityHashtag = """
    insert into flow.project_activity_hashtag(project_activity_id, hashtag_id, date_created, date_modified, created_by_id, modified_by_id)
    values (:activityId, :hashtagId, now(), now(), :userId, :userId)
    on conflict (project_activity_id, hashtag_id)
    do update set archived = false, date_modified = now(), modified_by_id = :userId;
  """;


  //language=PostgreSQL
  public final static String getProjectActivityHashtags = """
    select pah.id,
           pah.project_activity_id,
           pah.hashtag_id,
           pah.date_created,
           pah.date_modified,
           pah.created_by_id,
           pah.modified_by_id,
           pah.archived,
           h.hashtag,
           h.hashtag_type_id,
           ht.hashtag_type
    from flow.project_activity_hashtag pah
    inner join flow.hashtag h on h.id = pah.hashtag_id
    inner join flow.hashtag_type ht on ht.id = h.hashtag_type_id
    where pah.project_activity_id = :activityId
      and pah.archived is false
  """;


  //language=PostgreSQL
  public final static String addSystemActivity = """
    select from flow.add_system_activity(:activityId, :objectTypeId, :projectId, :ppsId, :ppseId);
  """;
}
