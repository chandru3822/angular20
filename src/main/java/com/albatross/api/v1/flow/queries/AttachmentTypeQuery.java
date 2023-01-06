package com.albatross.api.v1.flow.queries;

public class AttachmentTypeQuery {

  //language=PostgreSQL
  public final static String getTypesForCompany = """
      select at.*,
             kp.key_pattern
      from flow.attachment_type at
        inner join flow.key_pattern kp on kp.id = at.key_pattern_id
      where company_id = :companyId
      and at.archived is not true
      and at.is_system is not true
    """;

  //language=PostgreSQL
  public final static String getAllUsingType = """
    select concat('Process Step: ', ps.process_step_name) as process_step_name
          from flow.process_step_attachment_type at
                 inner join flow.process_step ps on at.process_step_id = ps.id
          where at.attachment_type_id = :typeId
            and at.archived is false
            and ps.archived is false
          union
          select concat('Event: ', e.event_name) as process_step_name
          from flow.event_attachment_type at
                 inner join flow.event e on at.event_id = e.id
          where at.attachment_type_id = :typeId
            and at.archived is false
            and e.archived is false
          union
          select 'Project' as process_step_name
          from flow.project_attachment_type at
          where at.attachment_type_id = :typeId
            and at.archived is false
          union
          select 'Contact' as process_step_name
          from flow.contact_attachment_type at
          where at.attachment_type_id = :typeId
            and at.archived is false
          union
          select 'Organization' as process_step_name
          from flow.org_attachment_type at
          where at.attachment_type_id = :typeId
            and at.archived is false
          union
          select 'User' as process_step_name
          from flow.user_attachment_type at
          where at.attachment_type_id = :typeId
            and at.archived is false
          order by process_step_name
      """;

  //language=PostgreSQL
  public final static String getSystemTypes = """
      select at.*,
             kp.key_pattern
      from flow.attachment_type at
        inner join flow.key_pattern kp on kp.id = at.key_pattern_id
      where at.archived is not true
      and at.is_system is true
      order by at.attachment_type
    """;

  //language=PostgreSQL
  public final static String getType = """
    select at.id,
                 at.attachment_type,
                 at.company_id,
                 at.archived,
                 at.key_pattern_id,
                 kp.key_pattern,
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
                                                                   cfga.field_order as "fieldOrder",
                                                                   cfga.required,
                                                                   cfga.archived,
                                                                   cfga.read_only as "customFieldGroupAssignmentReadOnly",
                                                                   cfga.hidden as "customFieldGroupAssignmentHidden",
                                                                   cfga.detail_view as "detailView",
                                                                   cf.field_name as "fieldName",
                                                                   cf.system_readonly as "systemReadonly",
                                                                   cfg1.group_name as "groupName",
                                                                   ot.object_type as "objectType"
                                                            FROM flow.custom_field_group_assignment cfga
                                                                   inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                                                                   inner join flow.custom_field_group cfg1 on cfg1.id = cfga.custom_field_group_id
                                                                   inner join flow.attachment_type at on cfg1.attachment_type_id = at.id
                                                                   inner join flow.company_object_type cot on cot.id = cfg1.company_object_type_id
                                                                   inner join flow.object_type ot on ot.id = cot.object_type_id
                                                            WHERE cfga.custom_field_group_id = cfg.id
                                                              AND cfg.archived is not true
                                                              and cfga.archived is not true
                                                              and cf.archived is not true
                                                            ORDER by field_order, field_name) customFields), '[]') AS "customFields"
                                   FROM flow.custom_field_group cfg
                                          inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
                                   WHERE cfg.attachment_type_id = at.id AND cfg.archived is not true
                                   order by cfg.group_order) cfGroups), '[]') AS custom_field_groups
          from flow.attachment_type at
                 inner join flow.key_pattern kp on kp.id = at.key_pattern_id
          where at.company_id = :companyId
            and at.id = :typeId
          order by at.attachment_type;
      """;

  //language=PostgreSQL
  public final static String deleteAttachmentType = """
          update flow.attachment_type
          set archived = true,
              modified_by_id = :modifiedById,
              date_modified = now()
          where id = :id
    """;

  //language=PostgreSQL
  public final static String updateType = """
        update flow.attachment_type
          set attachment_type = :attachmentType,
              modified_by_id = :modifiedById,
              date_modified = now()
        where id = :id
    """;

  //language=PostgreSQL
  public final static String insertType = """
        insert into flow.attachment_type(attachment_type, company_id, key_pattern_id,
                                         created_by_id, date_created, modified_by_id, date_modified)
        values (:attachmentType, :companyId, :keyPatternId, :createdById, now(), :createdById, now())
        returning id
    """;

  //language=PostgreSQL
  public final static String getProcessStepTypesByPps = """
    select psat.id,
               at.attachment_type,
               psat.attachment_type_id,
               psat.process_step_id,
               psat.date_created,
               psat.linkable,
               psat.allow_upload,
               psat.focused,
               psat.date_modified,
               psat.created_by_id,
               psat.modified_by_id,
               psat.archived,
               case when :allowUpload::boolean is true then (
                 select cfga.id
                  from flow.custom_field_group_assignment cfga
                         left join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.attachment_type_id = psat.attachment_type_id and cfg.archived is false
                         left join flow.custom_field_group cfg2 on cfga.custom_field_group_id = cfg2.id and cfg2.project_attachment_type_id = psat.id and cfg2.archived is false
                  where cfga.archived is false
                    and (cfg2.id is not null or cfg.id is not null)
                  limit 1
           ) is not null else false end as has_fields_assigned
        from flow.process_step_attachment_type psat
               inner join flow.project_process_step pps on pps.id = :ppsId and pps.process_step_id = psat.process_step_id
               inner join flow.attachment_type at on at.id = psat.attachment_type_id
        where psat.archived is not true
            and at.company_id = :companyId
            and case when :allowUpload::boolean is true then psat.allow_upload is true else 1=1 end
            and case when :focused::boolean is true then psat.focused is true else 1=1 end
            and case when :linkable::boolean is true then psat.linkable is true else 1=1 end
        order by at.attachment_type
      """;

  //language=PostgreSQL
  public final static String getEventTypesByPpsEventId = """
    select eat.id,
                 at.attachment_type,
                 eat.attachment_type_id,
                 eat.event_id,
                 eat.date_created,
                 eat.date_modified,
                 eat.linkable,
                 eat.allow_upload,
                 eat.focused,
                 eat.created_by_id,
                 eat.modified_by_id,
                 eat.archived,
                case when :allowUpload::boolean is true then (
                   select cfga.id
                  from flow.custom_field_group_assignment cfga
                         left join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.attachment_type_id = eat.attachment_type_id and cfg.archived is false
                         left join flow.custom_field_group cfg2 on cfga.custom_field_group_id = cfg2.id and cfg2.project_attachment_type_id = eat.id and cfg2.archived is false
                  where cfga.archived is false
                    and (cfg2.id is not null or cfg.id is not null)
                  limit 1
                 ) is not null else false end as has_fields_assigned
          from flow.event_attachment_type eat
                 inner join flow.attachment_type at on at.id = eat.attachment_type_id
                 inner join flow.event e on eat.event_id = e.id
                 inner join flow.process_step_event pse on e.id = pse.event_id
                 inner join flow.project_process_step_event ppse on pse.id = ppse.process_step_event_id and ppse.id = :ppsEventId
          where  eat.archived is not true
            and case when :allowUpload::boolean is true then eat.allow_upload is true else 1=1 end
            and case when :focused::boolean is true then eat.focused is true else 1=1 end
            and case when :linkable::boolean is true then eat.linkable is true else 1=1 end
          order by at.attachment_type
      """;

  //language=PostgreSQL
  public final static String getFocusedTypesForProject = """
    select at.attachment_type,
               oat.attachment_type_id,
               linkable,
               allow_upload
         from flow.project_attachment_type oat
                inner join flow.attachment_type at on oat.attachment_type_id = at.id
         where oat.company_id = :companyId
           and oat.archived is not true
           and oat.focused is true
         order by attachment_type
     """;

  //language=PostgreSQL
  public final static String getFocusedTypesForPps = """
    select at.attachment_type,
           psat.attachment_type_id,
           linkable
          from flow.process_step_attachment_type psat
            inner join flow.attachment_type at on psat.attachment_type_id = at.id
            inner join flow.project_process_step pps on pps.process_step_id = psat.process_step_id and pps.id = :ppsId
          where psat.archived is not true
            and psat.focused is true
          order by attachment_type
      """;

  //language=PostgreSQL
  public final static String getFocusedTypesForPpsEvent = """
        select at.attachment_type,
               eat.attachment_type_id,
               linkable
        from flow.event_attachment_type eat
            inner join flow.attachment_type at on eat.attachment_type_id = at.id
            inner join flow.project_process_step_event ppse on ppse.id = :ppsEventId
            inner join flow.process_step_event pse on pse.id = ppse.process_step_event_id and pse.event_id = eat.event_id
        where eat.archived is not true
          and eat.focused is true
        order by attachment_type
    """;

  //language=PostgreSQL
  public final static String getCombinedTypesForProject = """
    with types as (
            select distinct at.attachment_type,
                            oat.attachment_type_id
            from flow.project_attachment_type oat
                   inner join flow.attachment_type at on oat.attachment_type_id = at.id
            where oat.company_id = :companyId
              and oat.archived is not true -- 27
            union
            select distinct at.attachment_type,
                            psat.attachment_type_id
            from flow.process_step_attachment_type psat
                   inner join flow.attachment_type at on at.id = psat.attachment_type_id
            where psat.archived is not true
              and at.company_id = :companyId -- 68
            union
            select distinct at.attachment_type,
                            eat.attachment_type_id
            from flow.event_attachment_type eat
                   inner join flow.attachment_type at on at.id = eat.attachment_type_id
                   inner join flow.event e on eat.event_id = e.id
            where eat.archived is not true
              and e.company_id = :companyId
            order by attachment_type
          ), types_with_linkable as (
            select t.*,
                   case
                     when :ppsId::bigint is null and :ppsEventId::bigint is null then
                       (select linkable
                        from flow.project_attachment_type pat
                        where pat.company_id = :companyId
                          and pat.attachment_type_id = t.attachment_type_id
                          and pat.archived is false)
                     when :ppsId::bigint is not null and :ppsEventId::bigint is null then
                       (select linkable
                        from flow.project_process_step pps
                               inner join flow.process_step ps on ps.id = pps.process_step_id
                               inner join flow.process_step_attachment_type p on p.process_step_id = ps.id
                        where pps.id = :ppsId::bigint
                          and p.attachment_type_id = t.attachment_type_id
                          and p.archived is false
                       )
                     when :ppsEventId::bigint is not null then
                       (select linkable
                        from flow.project_process_step_event ppse
                               inner join flow.process_step_event pse on pse.id = ppse.process_step_event_id
                               inner join flow.event e2 on e2.id = pse.event_id
                               inner join flow.event_attachment_type eat2 on eat2.event_id = e2.id
                        where ppse.id = :ppsEventId::bigint
                          and eat2.attachment_type_id = t.attachment_type_id
                          and eat2.archived is false
                       )
                     else false end as linkable
            from types t
          )
          select attachment_type,
                 attachment_type_id,
                 coalesce(linkable, false) as linkable
          from types_with_linkable
      """;

  //attachment type queries that work for different object types
//  public static String getTypes(String tablePrefix) {
//    //language=PostgreSQL
//    return """
//      select oat.id,
//               oat.company_id,
//               oat.attachment_type_id,
//               oat.archived,
//               oat.focused,
//               oat.linkable,
//               oat.allow_upload,
//               at.attachment_type,
//               oat.display_order
//        from flow.%s_attachment_type oat
//               inner join flow.attachment_type at on oat.attachment_type_id = at.id
//        where oat.company_id = :companyId
//          and oat.archived is not true
//        order by at.attachment_type
//      """.formatted(tablePrefix);
//  }
//language=PostgreSQL
  public final static String userGetAvailableTypes = """
    select at.id,
                 at.attachment_type,
                 at.archived
          from flow.attachment_type at
          where at.archived is not true
            and at.company_id = :companyId
            and at.is_system is false
            and not exists (
              select oat.attachment_type_id
              from flow.user_attachment_type oat
              where oat.company_id = :companyId
                and oat.attachment_type_id = at.id
                and oat.archived is not true
            )
          order by at.attachment_type
      """;

  //  USER - should prob move to own file
  //language=PostgreSQL
  public final static String userGetTypes = """
    select oat.id,
               oat.company_id,
               oat.attachment_type_id,
               oat.archived,
               at.attachment_type,
               oat.focused,
               oat.linkable,
               oat.allow_upload,
               oat.display_order
        from flow.user_attachment_type oat
               inner join flow.attachment_type at on oat.attachment_type_id = at.id
        where oat.company_id = :companyId
          and oat.archived is not true
        order by at.attachment_type
      """;

  //language=PostgreSQL
  public final static String projectGetAvailableTypes = """
      select at.id,
                   at.attachment_type,
                   at.archived
            from flow.attachment_type at
            where at.archived is not true
              and at.company_id = :companyId
              and at.is_system is false
              and not exists (
                select oat.attachment_type_id
                from flow.project_attachment_type oat
                where oat.company_id = :companyId
                  and oat.attachment_type_id = at.id
                  and oat.archived is not true
              )
            order by at.attachment_type
    """;


  //  PROJECT - should prob move to own file
  //language=PostgreSQL
  public final static String projectGetTypes = """
       select oat.id,
                 oat.company_id,
                 oat.attachment_type_id,
                 oat.archived,
                 at.attachment_type,
                 oat.focused,
                 oat.linkable,
                 oat.allow_upload,
                 oat.display_order
          from flow.project_attachment_type oat
                 inner join flow.attachment_type at on oat.attachment_type_id = at.id
          where oat.company_id = :companyId
            and oat.archived is not true
          order by at.attachment_type
    """;


  //language=PostgreSQL
  public final static String eventGetAvailableTypes = """
      select at.id,
                   at.attachment_type,
                   at.archived
            from flow.attachment_type at
            where at.archived is not true
              and at.company_id = :companyId
              and at.is_system is false
              and not exists (
                select oat.attachment_type_id
                from flow.event_attachment_type oat
                where oat.event_id = :eventId
                  and oat.attachment_type_id = at.id
                  and oat.archived is not true
              )
            order by at.attachment_type
    """;

  //  EVENT - should prob move to own file
  //language=PostgreSQL
  public final static String eventGetTypes = """
      select oat.id,
                 oat.event_id,
                 oat.attachment_type_id,
                 oat.archived,
                 at.attachment_type,
                 oat.focused,
                 oat.linkable,
                 oat.allow_upload,
                 oat.display_order
          from flow.event_attachment_type oat
                 inner join flow.attachment_type at on oat.attachment_type_id = at.id
          where oat.event_id = :eventId
            and oat.archived is not true
          order by at.attachment_type
    """;

  //language=PostgreSQL
  public final static String contactGetAvailableTypes = """
    select at.id,
                 at.attachment_type,
                 at.archived
          from flow.attachment_type at
          where at.archived is not true
            and at.company_id = :companyId
            and at.is_system is false
            and not exists (
              select oat.attachment_type_id
              from flow.contact_attachment_type oat
              where oat.company_id = :companyId
                and oat.attachment_type_id = at.id
                and oat.archived is not true
            )
          order by at.attachment_type
      """;

  //  CONTACT - should prob move to own file
  //language=PostgreSQL
  public final static String contactGetTypes = """
    select oat.id,
               oat.company_id,
               oat.attachment_type_id,
               oat.archived,
               oat.focused,
               oat.linkable,
               oat.allow_upload,
               at.attachment_type,
               oat.display_order
        from flow.contact_attachment_type oat
               inner join flow.attachment_type at on oat.attachment_type_id = at.id
        where oat.company_id = :companyId
          and oat.archived is not true
        order by at.attachment_type
      """;

  //language=PostgreSQL
  public final static String orgGetAvailableTypes = """
    select at.id,
                 at.attachment_type,
                 at.archived
          from flow.attachment_type at
          where at.archived is not true
            and at.company_id = :companyId
            and at.is_system is false
            and not exists (
              select oat.attachment_type_id
              from flow.org_attachment_type oat
              where oat.company_id = :companyId
                and oat.attachment_type_id = at.id
                and oat.archived is not true
            )
          order by at.attachment_type
      """;

  //  ORG - should prob move to own file
  //language=PostgreSQL
  public final static String orgGetTypes = """
      select oat.id,
             oat.company_id,
             oat.attachment_type_id,
             oat.archived,
             at.attachment_type,
             oat.focused,
             oat.linkable,
             oat.allow_upload,
             oat.display_order
      from flow.org_attachment_type oat
             inner join flow.attachment_type at on oat.attachment_type_id = at.id
      where oat.company_id = :companyId
        and oat.archived is not true
      order by at.attachment_type
    """;

//  public static String getAvailableTypes(String tablePrefix) {
//    //language=PostgreSQL
//    return """
//      select at.id,
//                   at.attachment_type,
//                   at.archived
//            from flow.attachment_type at
//            where at.archived is not true
//              and at.company_id = :companyId
//              and at.is_system is false
//              and not exists (
//                select oat.attachment_type_id
//                from flow.%s_attachment_type oat
//                where oat.company_id = :companyId
//                  and oat.attachment_type_id = at.id
//                  and oat.archived is not true
//              )
//            order by at.attachment_type
//      """.formatted(tablePrefix);
//  }

  public final static String contactAddType = """
      insert into flow.contact_attachment_type(company_id, attachment_type_id, created_by_id, display_order)
      values (:companyId, :attachmentTypeId, :createdById,
              (select coalesce(max(display_order) + 1, 0) from flow.contact_attachment_type
               where company_id = :companyId and archived is false))
    """;

  public final static String orgAddType = """
      insert into flow.org_attachment_type(company_id, attachment_type_id, created_by_id, display_order)
      values (:companyId, :attachmentTypeId, :createdById,
              (select coalesce(max(display_order) + 1, 0) from flow.org_attachment_type
               where company_id = :companyId and archived is false))
    """;

  //language=PostgreSQL
  public final static String userAddType = """
      insert into flow.user_attachment_type(company_id, attachment_type_id, created_by_id, display_order)
      values (:companyId, :attachmentTypeId, :createdById,
              (select coalesce(max(display_order) + 1, 0) from flow.user_attachment_type
               where company_id = :companyId and archived is false))
    """;

  //language=PostgreSQL
  public final static String projectAddType = """
          insert into flow.project_attachment_type(company_id, attachment_type_id, created_by_id, display_order)
          values (:companyId, :attachmentTypeId, :createdById,
                  (select coalesce(max(display_order) + 1, 0) from flow.project_attachment_type
                   where company_id = :companyId and archived is false))
    """;

  //language=PostgreSQL
  public final static String eventAddType = """
          insert into flow.event_attachment_type(event_id, attachment_type_id, created_by_id, display_order)
          values (:eventId, :attachmentTypeId, :createdById,
                  (select coalesce(max(display_order) + 1, 0) from flow.event_attachment_type
                   where event_id = :eventId and archived is false))
    """;


//  public static String addType(String tablePrefix) {
//    //language=PostgreSQL
//    return """
//      insert into flow.%s_attachment_type(company_id, attachment_type_id, created_by_id, display_order)
//      values (:companyId, :attachmentTypeId, :createdById,
//              (select coalesce(max(display_order) + 1, 0) from flow.%s_attachment_type
//               where company_id = :companyId and archived is false))
//      """.formatted(tablePrefix, tablePrefix);
//  }

  public final static String updateDisplayOrder(String tablePrefix) {
    //language=PostgreSQL
    return """
      update flow.%s_attachment_type
          set display_order = :displayOrder,
              modified_by_id = :modifiedById,
              date_modified = now()
          where id = :id
      """.formatted(tablePrefix);
  }

  public final static String update(String tablePrefix) {
    //language=PostgreSQL
    return """
      update flow.%s_attachment_type
          set focused = :focused,
              linkable = :linkable,
              allow_upload = :allowUpload,
              modified_by_id = :modifiedById,
              date_modified = now()
          where id = :id
      """.formatted(tablePrefix);
  }


  public final static String deleteType(String tablePrefix) {
    //language=PostgreSQL
    return """
      update flow.%s_attachment_type
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
      where id = :id
      """.formatted(tablePrefix);
  }


  //language=PostgreSQL
  public final static String projectGetAssignedTypes = """
          select oat.id,
                     oat.company_id,
                     oat.attachment_type_id,
                     oat.archived,
                     at.attachment_type,
                     oat.focused,
                     oat.linkable,
                     oat.allow_upload,
                     oat.display_order,
                     case when :allowUpload::boolean is true then (
                       select cfga.id
                       from flow.custom_field_group_assignment cfga
                              left join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.attachment_type_id = oat.attachment_type_id and cfg.archived is false
                              left join flow.custom_field_group cfg2 on cfga.custom_field_group_id = cfg2.id and cfg2.project_attachment_type_id = oat.id and cfg2.archived is false
                       where cfga.archived is false
                         and (cfg2.id is not null or cfg.id is not null)
                       limit 1
                     ) is not null else false end as has_fields_assigned
              from flow.project_attachment_type oat
                     inner join flow.attachment_type at on oat.attachment_type_id = at.id
              where oat.company_id = :companyId
                and oat.archived is not true
                and case when :allowUpload::boolean is true then oat.allow_upload is true else 1=1 end
                and case when :focused::boolean is true then oat.focused is true else 1=1 end
                and case when :linkable::boolean is true then oat.linkable is true else 1=1 end
              order by at.attachment_type
    """;

  //language=PostgreSQL
  public final static String contactGetAssignedTypes = """
    select oat.id,
               oat.company_id,
               oat.attachment_type_id,
               oat.archived,
               at.attachment_type,
               oat.focused,
               oat.linkable,
               oat.allow_upload,
               oat.display_order,
               (
                 select cfga.id
                 from flow.custom_field_group_assignment cfga
                        left join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.attachment_type_id = oat.attachment_type_id and cfg.archived is false
                        left join flow.custom_field_group cfg2 on cfga.custom_field_group_id = cfg2.id and cfg2.project_attachment_type_id = oat.id and cfg2.archived is false
                 where cfga.archived is false
                   and (cfg2.id is not null or cfg.id is not null)
                 limit 1
               ) is not null as has_fields_assigned
        from flow.contact_attachment_type oat
               inner join flow.attachment_type at on oat.attachment_type_id = at.id
        where oat.company_id = :companyId
          and oat.archived is not true
          and case when :allowUpload::boolean is true then oat.allow_upload is true else 1=1 end
          and case when :focused::boolean is true then oat.focused is true else 1=1 end
          and case when :linkable::boolean is true then oat.linkable is true else 1=1 end
        order by at.attachment_type
      """;


  //language=PostgreSQL
  public final static String orgGetAssignedTypes = """
    select oat.id,
               oat.company_id,
               oat.attachment_type_id,
               oat.archived,
               at.attachment_type,
               oat.focused,
               oat.linkable,
               oat.allow_upload,
               oat.display_order,
               (
                 select cfga.id
                 from flow.custom_field_group_assignment cfga
                        left join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.attachment_type_id = oat.attachment_type_id and cfg.archived is false
                        left join flow.custom_field_group cfg2 on cfga.custom_field_group_id = cfg2.id and cfg2.project_attachment_type_id = oat.id and cfg2.archived is false
                 where cfga.archived is false
                   and (cfg2.id is not null or cfg.id is not null)
                 limit 1
               ) is not null as has_fields_assigned
        from flow.org_attachment_type oat
               inner join flow.attachment_type at on oat.attachment_type_id = at.id
        where oat.company_id = :companyId
          and oat.archived is not true
          and case when :allowUpload::boolean is true then oat.allow_upload is true else 1=1 end
          and case when :focused::boolean is true then oat.focused is true else 1=1 end
          and case when :linkable::boolean is true then oat.linkable is true else 1=1 end
        order by at.attachment_type
      """;


  //language=PostgreSQL
  public final static String userGetAssignedTypes = """
    select oat.id,
               oat.company_id,
               oat.attachment_type_id,
               oat.archived,
               at.attachment_type,
               oat.focused,
               oat.linkable,
               oat.allow_upload,
               oat.display_order,
              (
                 select cfga.id
                 from flow.custom_field_group_assignment cfga
                        left join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.attachment_type_id = oat.attachment_type_id and cfg.archived is false
                        left join flow.custom_field_group cfg2 on cfga.custom_field_group_id = cfg2.id and cfg2.project_attachment_type_id = oat.id and cfg2.archived is false
                 where cfga.archived is false
                   and (cfg2.id is not null or cfg.id is not null)
                 limit 1
               ) is not null as has_fields_assigned
        from flow.user_attachment_type oat
               inner join flow.attachment_type at on oat.attachment_type_id = at.id
        where oat.company_id = :companyId
          and oat.archived is not true
          and case when :allowUpload::boolean is true then oat.allow_upload is true else 1=1 end
          and case when :focused::boolean is true then oat.focused is true else 1=1 end
          and case when :linkable::boolean is true then oat.linkable is true else 1=1 end
        order by at.attachment_type
      """;


//  public static String getAssignedTypes(String tablePrefix) {
//    //language=PostgreSQL
//    return """
//      select oat.id,
//               oat.company_id,
//               oat.attachment_type_id,
//               oat.archived,
//               at.attachment_type,
//               oat.focused,
//               oat.linkable,
//               oat.allow_upload,
//               oat.display_order,
//               (
//                 select cfga.id
//                 from flow.custom_field_group_assignment cfga
//                        left join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.attachment_type_id = oat.attachment_type_id and cfg.archived is false
//                        left join flow.custom_field_group cfg2 on cfga.custom_field_group_id = cfg2.id and cfg2.project_attachment_type_id = oat.id and cfg2.archived is false
//                 where cfga.archived is false
//                   and (cfg2.id is not null or cfg.id is not null)
//                 limit 1
//               ) is not null as has_fields_assigned
//        from flow.%s_attachment_type oat
//               inner join flow.attachment_type at on oat.attachment_type_id = at.id
//        where oat.company_id = :companyId
//          and oat.archived is not true
//          and case when :allowUpload::boolean is true then oat.allow_upload is true else 1=1 end
//          and case when :focused::boolean is true then oat.focused is true else 1=1 end
//          and case when :linkable::boolean is true then oat.linkable is true else 1=1 end
//        order by at.attachment_type
//      """.formatted(tablePrefix);
//  }

}
