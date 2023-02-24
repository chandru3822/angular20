package com.albatross.api.v1.flow.queries;

public class OrgQuery {

  //language=PostgreSQL
  public final static String getAllForCompany = """
    select o.*,
           p.org_name as parentOrgName,
           ot.org_type,
           s.abbreviation as state_abbreviation
    from flow.org o
      left join flow.org p on p.id = o.parent_org_id
      inner join flow.org_type ot on ot.id = o.org_type_id
      left join flow.company_state cs on o.company_state_id = cs.id
      left join flow.state s on cs.state_id = s.id
    where o.company_id = :companyId
      and o.archived is not true
    order by o.org_name
    """;

  //language=PostgreSQL
  public final static String getAllActive = """
    select
        o.id,
        o.org_name
    from flow.org o
    where
      o.company_id = :companyId and
      o.archived is not true and
      o.active_flag is true
    order by o.org_name
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
                                WHERE cfg.org_attachment_type_id = oat.id AND cfg.archived is not true
                                order by cfg.group_order) cfGroups), '[]') AS custom_field_groups
       from flow.org_attachment_type oat
              inner join flow.attachment_type at on oat.attachment_type_id = at.id
       where oat.id = :id
       and oat.company_id = :companyId
    """;

  //language=PostgreSQL
  public final static String getUsersInOrg = """
    select u.id,
               u.first_name || ' ' || u.last_name as full_name,
               p.position,
               primary_flag
        from flow.user_position up
          inner join flow.user u on up.user_id = u.id
          inner join flow.position p on up.position_id = p.id
        where up.org_id = :orgId
          and up.archived is false
          and u.archived is false
          and up.primary_flag is true
          and up.start_date <= now() and (up.end_date is null or up.end_date >= now())
        order by full_name
        """;

  //language=PostgreSQL
  public final static String getSchedulingOrgs = """
    select o.id,
         o.company_id,
         o.company_timezone_id,
         o.org_name,
         o.parent_org_id,
         o.org_type_id,
         o.active_flag,
         o.schedulable,
         o.available_to_children,
         o.company_state_id,
         cs.state_id,
         p.org_name as parentOrgName,
         o.org_name as title,
         ot.org_type
        from flow.org o
                 left join flow.org p on p.id = o.parent_org_id
                 inner join flow.org_type ot on ot.id = o.org_type_id
                 left join flow.company_state cs on cs.id = o.company_state_id
        where case when :isParent and :isSchedulingTool
            then o.company_id = any (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
            else (o.company_id = :companyId OR (:isSchedulingTool AND o.company_id = :parentCompanyId AND o.available_to_children is true )) end
          and case when :companyStateId::bigint is not null
              then o.company_state_id = :companyStateId::bigint and o.schedulable is true
              else o.schedulable is true end
          and o.archived is not true
          and o.active_flag is true
        order by o.org_name
        """;

  //language=PostgreSQL
  public final static String getOrgsByType = """
    select o.*,
            p.org_name as parentOrgName,
            ot.org_type
     from flow.org o
         left join flow.org p on p.id = o.parent_org_id
         inner join flow.org_type ot on ot.id = o.org_type_id
     where o.company_id = :companyId
       and o.org_type_id = :typeId
       and o.active_flag is true
       and o.archived is not true
     order by o.org_name
     """;

  //language=PostgreSQL
  public final static String searchOrgs = """
    select o.*,
               p.org_name as parentOrgName,
               ot.org_type
        from flow.org o
            left join flow.org p on p.id = o.parent_org_id
            inner join flow.org_type ot on ot.id = o.org_type_id
        where o.company_id = :companyId
            and o.org_name ILIKE '%' || :query || '%'
            and o.archived is not true
        order by o.org_name
        limit :limit
        offset :offset
        """;

  //language=PostgreSQL
  public final static String searchOrgCount = """
      select count(*)
      from flow.org o
          left join flow.org p on p.id = o.parent_org_id
          inner join flow.org_type ot on ot.id = o.org_type_id
      where o.company_id = :companyId
          and o.archived is not true
          and o.org_name ILIKE '%' || :query || '%'
    """;

  //language=PostgreSQL
  public final static String exportOrgs = """
    select
           o.org_name,
           ot.org_type,
           p.org_name as "parent_org_name",
           o.active_flag
       from flow.org o
           left join flow.org p on p.id = o.parent_org_id
           inner join flow.org_type ot on ot.id = o.org_type_id
       where o.company_id = :companyId
           and o.org_name ILIKE '%' || :query || '%'
           and o.archived is not true
       order by o.org_name desc
       """;

  //language=PostgreSQL
  public final static String updateOrg = """
    update flow.org
         set org_name = :orgName,
             parent_org_id = :parentOrgId,
             org_type_id = :orgTypeId,
             schedulable = :schedulable,
             available_to_children = :availableToChildren,
             company_timezone_id = :companyTimezoneId,
             company_state_id = :companyStateId,
             active_flag = :active,
             date_modified = now(),
             modified_by_id = :modifiedById
        where id = :id
        """;

  //language=PostgreSQL
  public final static String insertOrg = """
    insert into flow.org(company_id, org_name, parent_org_id, org_type_id, schedulable, company_state_id, available_to_children, company_timezone_id, date_created, date_modified, created_by_id)
        values(:companyId, :orgName, :parentOrgId, :orgTypeId, :schedulable, :companyStateId, :availableToChildren, :companyTimezoneId, now(), now(), :createdById)
        """;

  //language=PostgreSQL
  public final static String getOne = """
    select o.*,
               p.org_name as parent_org_name,
               ot.org_type,
               ot.org_parent_type_id as parent_org_type_id,
               s.abbreviation as state_abbreviation,
               s.state,
               t.timezone,
               coalesce((
                      SELECT array_to_json(array_agg(row_to_json(childOrgs)))
                      FROM (
                             SELECT childOrg.id,
                                    childOrg.org_name as "orgName",
                                    childOrg.active_flag as "activeFlag",
                                    childOrgType.org_type as "orgType"
                             FROM flow.org childOrg
                               inner join flow.org_type childOrgType on childOrg.org_type_id = childOrgType.id
                             WHERE childOrg.parent_org_id = o.id
                               and childOrg.archived is not true
                             order by childOrg.active_flag desc, childOrg.org_name
                           ) childOrgs), '[]') AS "childOrgs"
        from flow.org o
            left join flow.company_state cs on o.company_state_id = cs.id
            left join flow.state s on cs.state_id = s.id
            left join flow.company_timezone ct on o.company_timezone_id = ct.id
            left join flow.timezone t on ct.timezone_id = t.id
            left join flow.org p on p.id = o.parent_org_id
            inner join flow.org_type ot on ot.id = o.org_type_id
        where o.id = :id
          and o.archived is false
          and o.company_id = :companyId
        """;

  //language=PostgreSQL
  public final static String getOrgFiltersForCompany = """
    select of.id,
               of.org_level_id,
               ol.level,
               ol.level_name,
               of.rank,
               ol.company_id,
               of.show_type
        from flow.org_filter of
            inner join flow.org_level ol on ol.id = of.org_level_id
        where ol.company_id = :companyId
        order by of.rank
        """;

  //language=PostgreSQL
  public final static String getOneOrgFilter = """
    select of.id,
           of.org_level_id,
           ol.level_name,
           of.rank,
           ol.company_id,
           of.show_type
    from flow.org_filter of
        inner join flow.org_level ol on ol.id = of.org_level_id
    where of.id = :id
    """;

  //language=PostgreSQL
  public final static String saveOrgCalendarToUser = """
    insert into flow.user_org_access(org_id, user_id, created_by_id, date_created, modified_by_id, date_modified)
          values (:orgId, :userId, :createdById, now(), :createdById, now())
    """;

  //language=PostgreSQL
  public final static String updateOrgFilter = """
    update flow.org_filter
           set org_level_id = :orgLevelId,
               rank = :rank,
               show_type = :showType
         where id = :id
     """;

  //language=PostgreSQL
  public final static String insertOrgFilter = """
      insert into flow.org_filter(org_level_id, rank, show_type)
      values (:orgLevelId, :rank, :showType)
    """;

  //language=PostgreSQL
  public final static String deleteOrgFilter = """
    delete from flow.org_filter
         where id = :id
     """;

  //language=PostgreSQL
  public final static String getOrgsByHierarchyFilter = """
    select * from flow.org_hierarchy_filter_down(ARRAY[ :selectedOrgs ]::bigint[])
    union
    select * from flow.org_hierarchy_filter_up(ARRAY[ :selectedOrgs ]::bigint[])
    order by org_level_id, org_name
    """;

  //language=PostgreSQL
  public final static String getOrgsForLevel = """
    select o.id,
               o.company_id,
               o.company_timezone_id,
               org_name,
               parent_org_id,
               org_type_id,
               active_flag,
               ot.org_type,
               ot.org_level_id,
               of.show_type
        from flow.org o
             inner join flow.org_type ot on ot.id = o.org_type_id
             inner join flow.org_level ol on ol.id = ot.org_level_id
             inner join flow.org_filter of on of.org_level_id = ol.id
        where o.company_id = :companyId
          and ot.org_level_id = :orgLevelId
          and o.archived is not true
          and o.active_flag is true
        order by o.org_name
        """;

  //language=PostgreSQL
  public final static String getOrgCalendarsForUser = """
      select uoa.id,
             o.org_name,
             o.company_timezone_id,
             o.id as org_id,
             uoa.user_id,
             uoa.org_id,
             uoa.archived
      from flow.user_org_access uoa
               inner join flow.org o on o.id = uoa.org_id
      where uoa.user_id = :userId
          and uoa.archived is not true
          and o.archived is not true
          and (o.company_id = :companyId OR o.available_to_children is true)
      order by o.org_name
    """;

  //language=PostgreSQL
  public final static String getOneOrgCalendarAccess = """
      select uoa.id,
             o.org_name,
             o.company_timezone_id,
             uoa.user_id,
             uoa.org_id,
             uoa.archived
      from flow.user_org_access uoa
               inner join flow.org o on o.id = uoa.org_id
      where uoa.id = :id
    """;


  //language=PostgreSQL
  public final static String deleteOrgCalendarFromUser = """
      update flow.user_org_access
        set archived = true,
            date_modified = now(),
            modified_by_id = :modifiedById
      where id = :id
    """;

  //language=PostgreSQL
  public final static String getOrgAttachments = """
    select
          a.id,
          a.size,
          a.uuid,
          a.date_created,
          a.date_modified,
          a.filename,
          a.attachment_type_id,
          a.display_name,
          a.content_type,
          a.s3_key,
          a.archived,
          oa.linked,
          substring(filename, '\\.([^\\.]+)$') as file_extension,
          oa.org_id,
          concat(u.first_name, ' ', u.last_name) AS uploaded_by,
          att.attachment_type,
          orgn.*
        from flow.org_attachment oa
               inner join flow.attachment a on a.id = oa.attachment_id
               inner join flow."user" u ON a.created_by_id = u.id
               inner join flow.attachment_type att on a.attachment_type_id = att.id
               inner join flow.org_attachment_type uat on uat.attachment_type_id = att.id and uat.archived is false
               left join lateral ( select * from flow.get_attachment_origin(a.id)) orgn on true
        where oa.org_id = :orgId
          and uat.archived is false
          and case when :linked is true then oa.linked is true and uat.linkable is true else oa.linked is false end
          and a.company_id = :companyId
          and oa.archived is false
          and a.archived is not true
        order by oa.date_created desc
        """;

  //language=PostgreSQL
  public final static String linkAttachment = """
    insert into flow.org_attachment(attachment_id, org_id, created_by_id, linked)
    values(:attachmentId, :orgId, :userId, true)
    """;

  //language=PostgreSQL
  public final static String unlinkAttachment = """
    update flow.org_attachment
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
    where attachment_id = :attachmentId
    and org_id = :orgId
    and linked is true
    """;

  //language=PostgreSQL
  public final static String addAttachment = """
    insert into flow.org_attachment(attachment_id, org_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:attachmentId, :orgId, :createdById, now(), :createdById, now())
    """;

}
