package com.albatross.api.v1.flow.queries;

public class ProjectQuery {

  //language=PostgreSQL
  public final static String getAllForCompanyProcess = """
    select p.id,
       cp.company_id,
       cp.process_id,
       p.contact_id,
       p.project_name
    from flow.company_process cp
    inner join flow.project p on cp.id = p.company_process_id
    where cp.company_id = :companyId
      and cp.process_id = :processId
      and p.archived is not true
    """;

  //language=PostgreSQL
  public final static String getProjectIdByProjectProcessStepId = """
    select project_id
    from flow.project_process_step pps
    where pps.id = :projectProcessStepId
    """;

  //language=PostgreSQL
  public final static String getProjectIdsByPpsIds = """
    select distinct project_id
    from flow.project_process_step pps
    where pps.id = any(:ppsIds::bigint[])
    """;

  //language=PostgreSQL
  public final static String getProjectIdByProjectProcessStepEventId = """
    select pps.project_id
    from flow.project_process_step_event ppse
    inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
    where ppse.id = :projectProcessStepEventId
    """;

  //language=PostgreSQL
  public final static String getProjectsInGeoArea = """
SELECT p.id,
           p.project_name,
           cpst.project_status_type,
           p.latitude,
           p.longitude,
           p.city,
           s.abbreviation as state,
           p.street1,
           p.postal_code
    FROM   flow.project p
          inner join flow.company_process cp on cp.id = p.company_process_id
          inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
          inner join flow.company_state cs on p.company_state_id = cs.id
          inner join flow.state s on cs.state_id = s.id
          left join flow.user_position up on up.id = p.user_position_id
    WHERE  st_makepoint(p.longitude, p.latitude)
           && ST_MakeEnvelope (
               :upperBoundLongitude, :upperBoundLatitude,
               :lowerBoundLongitude, :lowerBoundLatitude,
               4326)
     and case
             when :isParent then cp.company_id = any
                                 (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
             else cp.company_id = :companyId
      end
      and p.archived is false
     and case when array_length(ARRAY[ :companyProjectStatusTypeIds ]::bigint[], 1) > 0 then p.company_project_status_type_id  = any( array[ :companyProjectStatusTypeIds ]::bigint[] ) else 1=1 end
     and case when :searchTypeId::bigint = 2 then up.user_id = :currentUserId::bigint else 1=1 end
    """;

  //language=PostgreSQL
  public final static String getProjectsInGeoAreaDownline = """
SELECT limited_projects.id,
           limited_projects.project_name,
           limited_projects.city,
           limited_projects.state_abbreviation as state,
           limited_projects.project_status_type,
           limited_projects.latitude,
           limited_projects.longitude,
           limited_projects.postal_code,
           limited_projects.street1

        FROM (
               with project_ids as (
                   with positions as (
                       select up.org_id as parent_org_id,up.user_id as user_id
                       from flow.user_position up
                       where (up.end_date is null or up.end_date > now())
                             -- judson had me change this: up.primary_flag is true
                         and up.archived is not true
                         and user_id = :currentUserId
                   ),
                        org_ids as (
                            select t.id
                            from positions p
                                     join lateral flow.org_hierarchy_filter_down_search(array [p.parent_org_id]) as t
                                          on true),
                   all_positions as(
                          select array_agg(up4.id) as user_position_ids
                          from flow.user_position up4
                          inner join positions p4 on p4.user_id = up4.user_id
                       )
                   select array_agg(project_ids) as project_ids
                   from (
                   select distinct p.id as project_ids
                   from org_ids o
                            inner join flow.user_position up2 on up2.org_id = o.id
                          inner join flow.project p on p.user_position_id = up2.id
                   where p.archived is not true
                   union
                   select distinct p.id as project_ids
                   from org_ids o
                            inner join flow.user_position up2 on up2.org_id = o.id
                            inner join flow.contact c on c.owner_user_position_id = up2.id
                            inner join flow.project p on p.contact_id = c.id
                   where p.archived is not true
                   union
                   select  distinct p3.id as project_ids
                   from all_positions p5
                            inner join flow.contact c on c.owner_user_position_id = any(p5.user_position_ids)
                            inner join flow.project p3 on p3.contact_id = c.id
                   where p3.archived is not true

                  union
                      select  distinct p3.id as project_ids
                       from all_positions p5
                        inner join flow.project p3 on p3.user_position_id = any(p5.user_position_ids)
                      where p3.archived is not true
                       )as foo)
               select p.id,
                      p.project_name,
                      p.contact_id,
                      p.date_created,
                      p.street1,
                      p.street2,
                      p.city,
                      s.state,
                      s.abbreviation           as state_abbreviation,
                      p.postal_code            as postal_code,
                      cp.status_type_id,
                      st.status_type,
                      p.company_project_status_type_id,
                      cpst.project_status_type,
                      pr.process_name,
                      (select row_to_json(contact1)
                       from (
                                select c.id,
                                       c.phone,
                                       c.mobile
                            ) contact1)::jsonb as contact,
                      cpst.project_status_type_id,
                      cpst.color as company_project_status_type_color,
                      p.latitude,
                      p.longitude,
                      p.company_state_id
               from flow.project p
                        inner join project_ids pi on p.id = any (pi.project_ids)
                        inner join flow.company_process cp on cp.id = p.company_process_id
                        inner join flow.process pr on pr.id = cp.process_id
                        inner join flow.status_type st on st.id = cp.status_type_id
                        inner join flow.company_project_status_type cpst
                                   on cpst.id = p.company_project_status_type_id
                        inner join flow.contact c on c.id = p.contact_id
                        left join flow.company_state cs on cs.id = p.company_state_id
                        left join flow.state s on s.id = cs.state_id
               where
                 case
                   when :isParent then cp.company_id = any
                                       (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
                   else cp.company_id = :companyId
                 end
                 and p.archived is not true
                 and case when array_length(ARRAY[ :companyProjectStatusTypeIds ]::bigint[], 1) > 0 then p.company_project_status_type_id  = any( array[ :companyProjectStatusTypeIds ]::bigint[] ) else 1=1 end
                 and st_makepoint(p.longitude, p.latitude)
                   && ST_MakeEnvelope (
                                      :upperBoundLongitude, :upperBoundLatitude,
                                      :lowerBoundLongitude, :lowerBoundLatitude,
                                      4326)
           ) as limited_projects
    """;

  //language=PostgreSQL
  public final static String existsInHierarchy = """
    select p.id
    from flow.project p
      inner join flow.company_process cp on cp.id = p.company_process_id
      inner join flow.company c on c.id = cp.company_id
    where p.id = :projectId
      and p.archived is not true
      and c.id = any (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
    """;

  //language=PostgreSQL
  public final static String exists = """
    select p.id
    from flow.project p
    where p.id = :projectId
    and p.archived is not true
    """;

  //language=PostgreSQL
  public final static String getCompanyId = """
    select cp.company_id
    from flow.project p
        inner join flow.company_process cp on cp.id = p.company_process_id
    where p.id = :projectId
      and p.archived is not true
    """;

  //language=PostgreSQL
  public final static String searchDownline = """
select *
    from flow.search_projects_with_down_line(:query::character varying, :companyId::bigint,
                                                            :userId::bigint,
                                                            :isParent::boolean,
                                                            :limit::bigint, :offset::bigint,
                                                            :companyProjectStatusTypeId::bigint,
                                                            :sortColumn::character varying, :sortDirection::character varying)
    """;

  //language=PostgreSQL
  public final static String searchDownlineCount = """
      select *
      from flow.search_projects_with_down_line_count(:query::character varying, :companyId::bigint,
                                                              :userId::bigint,
                                                              :isParent::boolean,
                                                            :companyProjectStatusTypeId::bigint)
    """;

  //language=PostgreSQL
  public final static String search = """
    select *
    from flow.search_all_projects(:query::character varying,
                                  :companyId::bigint,
                                  :isParent::boolean,
                                  :limit::bigint,
                                  :offset::bigint,
                                  :companyProjectStatusTypeId::bigint,
                                  :sortColumn::character varying,
                                  :sortDirection::character varying)
    """;

  //language=PostgreSQL
  public final static String searchCount = """
    select * from flow.search_all_projects_count(:query::character varying, :companyId::bigint, :isParent::boolean,
                                                            :companyProjectStatusTypeId::bigint)
    """;

  //language=PostgreSQL
  public final static String searchByOwner = """
select *
    from flow.search_projects_by_user(:query::character varying, :companyId::bigint,
                                 :userId::bigint,  :isParent::boolean,:limit::bigint, :offset::bigint,
                                                            :companyProjectStatusTypeId::bigint,
                                                            :sortColumn::character varying, :sortDirection::character varying)
    """;

  //language=PostgreSQL
  public final static String searchByOwnerCount = """
    select * from flow.search_projects_by_user_count(:query::character varying, :companyId::bigint, :userId::bigint, :isParent::boolean,
                                                            :companyProjectStatusTypeId::bigint)
    """;

  //language=PostgreSQL
  public final static String countsByStatus = """
    select *
    from flow.project_count_by_company_status(:companyId::bigint)
    """;

  //language=PostgreSQL
  public final static String countsByStatusByUser = """
    select *
    from flow.project_count_by_company_status_by_user(:companyId::bigint,
                                                            :userId::bigint,
                                                            :viewCustom::boolean)
    """;

  //language=PostgreSQL
  public final static String generateReport = """
    select
      p.id as "ID",
      p.project_name as "Name",
      p.date_created as "Date Created",
      st.status_type as "Status",
      pr.process_name as "Process"
    from flow.project p
    inner join flow.company_process cp on cp.id = p.company_process_id
    inner join flow.process pr on pr.id = cp.process_id
    inner join flow.status_type st on st.id = cp.status_type_id
    where
      cp.company_id = :companyId and
      p.archived is not true and
      p.project_name ilike '%' || :query || '%'
    order by p.date_created desc
    """;

  //language=PostgreSQL
  public final static String get = """
select
        p.id,
        p.street1,
        p.street2,
        p.city,
        p.company_state_id,
        s.state,
        s.abbreviation as state_abbreviation,
        p.postal_code,
        p.company_country_id,
        c.country,
        ct.phone,
        ct.email,
        ct.mobile,
        p.contact_id,
        p.date_created,
        cp.company_id,
        cp.process_id,
        p.time_zone,
        p.latitude,
        p.longitude,
        pst.project_status_type as "rootProjectStatusType",
        pro.process_name,
        p.contact_id,
        p.created_by_id,
        concat(u.first_name, ' ', u.last_name) as created_by,
        comp.company_name,
        (SELECT row_to_json(o)
            FROM (SELECT u.id as "userId",
                     u.first_name as "firstName",
                     u.last_name as "lastName",
                     concat(u.first_name, ' ', u.last_name) as "fullName",
                     pos.position,
                     u.phone_number as "phoneNumber",
                     up.id as "userPositionId",
                     ust.has_access as "hasAccess"
                  FROM flow."user" u
                    inner join flow.user_position up on up.user_id = u.id
                    inner join flow.position pos on pos.id = up.position_id
                    inner join flow.company_user_status cus on cus.user_id = u.id
                    inner join flow.user_status_type ust on cus.user_status_type_id = ust.id and ust.company_id = ct.company_id
                  WHERE up.id = p.user_position_id) o) AS owner,
        p.project_name,
        ct.first_name,
        ct.last_name,
        p.company_project_status_type_id,
        cpst.project_status_type,
        cpst.project_status_type_id,
        cot.status_read_only,
        cot.owner_read_only,
        coalesce((
             SELECT array_to_json(array_agg(row_to_json(tags)))
             FROM (
                    SELECT pt.id,
                           pt.project_id as "projectId",
                           pt.tag_id as "tagId",
                           t.tag_name as "tagName",
                           t.font_color as "fontColor",
                           t.bg_color as "bgColor",
                           pt.created_by_id as "createdById",
                           pt.modified_by_id as "modifiedById",
                           pt.archived
                    FROM flow.project_tag pt
                      inner join flow.tag t on t.id = pt.tag_id
                    WHERE pt.project_id = p.id
                      AND pt.archived is not true) tags), '[]') AS "tags",
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
                              WHERE wlp.white_list_type_id = 3
                                and wlp.company_id = comp.id
                                AND wlp.archived is not true) wlp), '[]') AS "statusReadOnlyWhiteListedPositions",
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
                              WHERE wlp.white_list_type_id = 4
                                and wlp.company_id = comp.id
                                AND wlp.archived is not true) wlp), '[]') AS "ownerReadOnlyWhiteListedPositions"
      from flow.company_process cp
      inner join flow.project p on cp.id = p.company_process_id
      inner join flow.contact ct on ct.id = p.contact_id
      inner join flow.process pro on pro.id = cp.process_id
      inner join flow.company comp on cp.company_id = comp.id
      inner join flow.company_object_type cot on cot.company_id = comp.id and cot.object_type_id = 1
      inner join flow."user" u on u.id = p.created_by_id
      left join flow.company_state cs on cs.id = p.company_state_id
      left join flow.state s on s.id = cs.state_id
      left join flow.company_country cc on cc.id = p.company_country_id
      left join flow.country c on c.id = cc.country_id
      inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
      inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
      where p.id = :projectId
        and case when :isParent
            then cp.company_id = any (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
            else cp.company_id = :companyId end
            and p.archived is not true
    """;

  //language=PostgreSQL
  public final static String update = """
    update flow.project set
    project_name = trim(:projectName),
    street1 = :street1,
    city = :city,
    company_state_id = :companyStateId,
    company_country_id = :companyCountryId,
    postal_code = :postalCode,
    modified_by_id = :modifiedById,
    date_modified = now(),
    latitude = :latitude,
    longitude = :longitude,
    time_zone = :timezone
    where id = :id
    """;

  //language=PostgreSQL
  public final static String delete = """
    update flow.project set
    archived = true,
    modified_by_id = :modifiedById,
    date_modified = now()
    where id = :projectId
    """;

  //language=PostgreSQL
  public final static String insert = """
insert into flow.project (contact_id, company_process_id, project_name, company_project_status_type_id, street1, city, company_state_id, company_country_id, postal_code, latitude, longitude, time_zone, created_by_id, date_created, modified_by_id, date_modified)
      values (:contactId, :processId, trim(:projectName), :companyProjectStatusTypeId, :street1, :city, :companyStateId, :companyCountryId, trim(:postalCode), :latitude, :longitude, :timezone, :createdById, now(), :createdById, now())
    """;

  //language=PostgreSQL
  public final static String getProcessStepsByProjectId = """
select
      ps.id as process_step_id,
      pps.id as project_process_step_id,
      pps.process_step_complete_date,
      pps.project_id,
      pps.date_created,
      pps.main,
      ps.process_step_name,
      coalesce(pps.date_modified, pps.date_created) as last_updated,
      cpsst.process_step_status_type,
      cpsst.process_step_status_type_id,
      cpsst.id as company_process_step_status_type_id,
      (
        select row_to_json(o) from (
          select
            u.id as "userId",
            u.first_name as "firstName",
            u.last_name as "lastName",
            concat(u.first_name, ' ', u.last_name) AS "fullName",
            p.position
        from flow.user u
        inner join flow.user_position up on up.user_id = u.id
        inner join flow.position p on p.id = up.position_id
        where up.id = pps.user_position_id
      ) o
    ) AS owner
    from flow.project p
    inner join flow.project_process_step pps on pps.project_id = p.id
    inner join flow.process_step ps on ps.id = pps.process_step_id
    inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
    left join flow.user_position up on up.id = pps.user_position_id
    left join flow.user u on u.id = up.user_id
    where
      p.id = :projectId and
        case when :isParent
            then ps.company_id = any (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
            else ps.company_id = :companyId end
      and pps.archived is not true
      and p.archived is not true
      and case when :statusTypeId::bigint is not null then :statusTypeId::bigint = cpsst.process_step_status_type_id else 1=1 end
    order by ps.process_step_name
    """;

  //language=PostgreSQL
  public final static String getEventsByProjectId = """
select
        ppse.id,
        pps.id as project_process_step_id,
        pps.project_id,
        ppse.process_step_event_id as process_step_event_id,
        ppse.date_created,
        ps.process_step_name,
        ppse.start_time,
        ppse.end_time,
        pps.company_process_step_status_type_id,
        cpsst.process_step_status_type_id,
        coalesce(ppse.date_modified, ppse.date_created) as last_updated,
        cest.event_status_type,
        pse.unique_behavior_type_id,
        e.id as event_id,
        e.event_name,
        ppse.resource_id,
        cest.event_status_type_id,
        cest.id as company_event_status_type_id,
        case when sl.system_list_type_id = 1 then o.org_name else concat(u.first_name, ' ', u.last_name) end as resource
      from flow.project p
             inner join flow.project_process_step pps on pps.project_id = p.id
             inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
             inner join flow.project_process_step_event ppse on ppse.project_process_step_id = pps.id
             inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
             inner join flow.event e on pse.event_id = e.id
             inner join flow.process_step ps on ps.id = pps.process_step_id
             inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
             inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
             inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
             inner join flow.system_list sl on sl.id = csl.system_list_id
             left join flow.user_position up on up.id = ppse.resource_id and sl.system_list_type_id = 2
             left join flow.user u on u.id = up.user_id
             left join flow.org o on o.id = ppse.resource_id and sl.system_list_type_id = 1
      where p.id = :projectId
        and pps.archived is not true
        and ppse.archived is not true
        and p.archived is not true
        and case when :statusTypeId::bigint is not null then :statusTypeId::bigint = cest.event_status_type_id else 1=1 end
      order by ppse.start_time nulls last, ppse.end_time nulls last, ppse.id
    """;

  //language=PostgreSQL
  public final static String getProjectDetailTemplateFields = """
     select primary_financier_name as primaryFinancier, installation_start_time, installation_end_time, closer_appointment_start as localCloserAppointmentStartTime,
            ahj_inspection_work_date as ahjInspectionWorkStartTime
      from brs.project_details
    where project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String getCombinedAttachments = """
select
        a.id,
        a.size,
        a.uuid,
        a.display_name,
        a.date_created,
        concat(u.first_name, ' ', u.last_name) as uploaded_by,
        a.date_modified,
        substring(a.filename, '\\.([^\\.]+)$') as file_extension,
        a.filename,
        a.attachment_type_id,
        a.content_type,
        a.s3_key,
        a.archived,
        pa.linked,
        att.attachment_type,
        (select * from flow.attachment_linked(a.id::bigint, :projectId::bigint, :ppsId::bigint, :ppsEventId::bigint)) as linked_to_selected,
        orgn.*
      from flow.project_attachment pa
             inner join flow.attachment a on a.id = pa.attachment_id
             inner join flow.attachment_type att on a.attachment_type_id = att.id
             inner join flow.project_attachment_type uat on uat.attachment_type_id = att.id and uat.archived is false
             left join lateral ( select * from flow.get_attachment_origin(a.id)) orgn on true
             inner join flow."user" u on u.id = a.created_by_id
      where pa.project_id = :projectId
        and a.company_id = :companyId
        and pa.archived is not true
        and att.archived is false
        and pa.linked is not true
        and a.archived is not true
      union
      select
        a.id,
        a.size,
        a.uuid,
        a.display_name,
        a.date_created,
        concat(u.first_name, ' ', u.last_name) as uploaded_by,
        a.date_modified,
        substring(a.filename, '\\.([^\\.]+)$') as file_extension,
        a.filename,
        a.attachment_type_id,
        a.content_type,
        a.s3_key,
        a.archived,
        ppsa.linked,
        att.attachment_type,
        (select * from flow.attachment_linked(a.id::bigint, :projectId::bigint, :ppsId::bigint, :ppsEventId::bigint)) as linked_to_selected,
        orgn.*
      from flow.project_process_step_attachment ppsa
             inner join flow.attachment a on a.id = ppsa.attachment_id
             inner join flow.project_process_step pps on pps.id = ppsa.project_process_step_id
             inner join flow.process_step ps on pps.process_step_id = ps.id
             inner join flow.attachment_type att on a.attachment_type_id = att.id
             inner join flow.process_step_attachment_type uat on uat.attachment_type_id = att.id and uat.archived is false and uat.process_step_id = ps.id
             inner join flow."user" u on u.id = a.created_by_id
             left join lateral ( select * from flow.get_attachment_origin(a.id)) orgn on true
      where pps.project_id = :projectId
        and a.company_id = :companyId
        and ppsa.archived is not true
        and ppsa.linked is not true
        and a.archived is not true
      union
      select
        a.id,
        a.size,
        a.uuid,
        a.display_name,
        a.date_created,
        concat(u.first_name, ' ', u.last_name) as uploaded_by,
        a.date_modified,
        substring(a.filename, '\\.([^\\.]+)$') as file_extension,
        a.filename,
        a.attachment_type_id,
        a.content_type,
        a.s3_key,
        a.archived,
        ppsa.linked,
        att.attachment_type,
        (select * from flow.attachment_linked(a.id::bigint, :projectId::bigint, :ppsId::bigint, :ppsEventId::bigint)) as linked_to_selected,
        orgn.*
      from flow.project_process_step_event_attachment ppsa
             inner join flow.attachment a on a.id = ppsa.attachment_id
             inner join flow.project_process_step_event ppse on ppse.id = ppsa.project_process_step_event_id
             inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
             inner join flow.event e on pse.event_id = e.id
             inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
             inner join flow.attachment_type att on a.attachment_type_id = att.id
             inner join flow.event_attachment_type uat on uat.attachment_type_id = att.id and uat.archived is false and uat.event_id = e.id
             inner join flow."user" u on u.id = a.created_by_id
             left join lateral ( select * from flow.get_attachment_origin(a.id)) orgn on true
      where pps.project_id = :projectId
        and a.company_id = :companyId
        and a.archived is not true
        and ppsa.linked is not true
        and ppsa.archived is not true
      order by date_created desc
    """;

  //language=PostgreSQL
  public final static String getAttachments = """
select
      a.id,
      a.size,
      a.uuid,
      a.date_created,
      concat(u.first_name, ' ', u.last_name) as uploaded_by,
      a.date_modified,
      substring(a.filename, '\\.([^\\.]+)$') as file_extension,
      a.filename,
      a.attachment_type_id,
      a.content_type,
      a.display_name,
      a.s3_key,
      a.archived,
      pa.linked,
      att.attachment_type,
      orgn.*
    from flow.project_attachment pa
      inner join flow.attachment a on a.id = pa.attachment_id
      inner join flow.attachment_type att on a.attachment_type_id = att.id
      inner join flow."user" u on u.id = a.created_by_id
      inner join flow.project_attachment_type uat on uat.attachment_type_id = att.id and uat.archived is false
      left join lateral ( select * from flow.get_attachment_origin(a.id)) orgn on true
    where pa.project_id = :projectId
      and a.company_id = :companyId
      and pa.archived is false
      and uat.archived is false
      and case when :linked is true then pa.linked is true and uat.linkable is true else pa.linked is false end
      and a.archived is not true
    order by pa.date_created desc
    """;

  //language=PostgreSQL
  public final static String linkAttachment = """
    insert into flow.project_attachment(attachment_id, project_id, created_by_id, linked)
    values(:attachmentId, :projectId, :userId, true)
    """;

  //language=PostgreSQL
  public final static String unlinkAttachment = """
    update flow.project_attachment
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
    where attachment_id = :attachmentId
    and project_id = :projectId
    and linked is true
    """;

  //language=PostgreSQL
  public final static String getAttachmentById = """
select
      a.id,
      a.uuid,
      a.size,
      a.display_name,
      a.date_created,
      concat(u.first_name, ' ', u.last_name) as uploaded_by,
      a.date_modified,
      substring(a.filename, '\\.([^\\.]+)$') as file_extension,
      a.filename,
      a.attachment_type_id,
      a.content_type,
      a.s3_key,
      a.archived,
      true as main
    from flow.project_attachment pa
           inner join flow.attachment a on a.id = pa.attachment_id
           inner join flow."user" u on u.id = a.created_by_id
    where pa.id = :id
      and a.archived is not true
    """;

  //language=PostgreSQL
  public final static String addAttachment = """
    insert into flow.project_attachment(attachment_id, project_id, created_by_id, date_created, modified_by_id, date_modified, linked)
    values (:attachmentId, :projectId, :createdById, now(), :createdById, now(), :linked)
    """;

  //language=PostgreSQL
  public final static String updateOwner = """
 update flow.project
        set user_position_id = :ownerUserPositionId,
            modified_by_id = :modifiedById,
            date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getOwners = """
select * from flow.get_project_available_owners(:companyId::bigint, :parentCompanyId::bigint, :isParent::bool)
    """;

  //language=PostgreSQL
  public final static String getDefaultProjectStatusTypeByCompanyId = """
    select
      id,
      project_status_type_id,
      project_status_type,
      archived,
      date_created,
      date_modified,
      created_by_id,
      modified_by_id,
      company_id
    from flow.company_project_status_type cpst
    where company_id = :companyId
      and is_default is true
      and archived is not true
    """;

  //language=PostgreSQL
  public final static String getStatusesForWqt = """
select
        null::bigint as id,
        'Category' as header,
        null::bigint as "projectStatusTypeId",
        null::bigint as "companyProjectStatusTypeId",
        false as archived,
        null::text as "uniqueText",
        null::text as "group",
        false as is_root,
        null::text as project_status_type,
        null::text as root_project_status_type,
        0 as display_sort
      union all
      select
        null::bigint as id,
        null::text as header,
        pst.id as "projectStatusTypeId",
        null::bigint as "companyProjectStatusTypeId",
        pst.archived,
        concat(pst.project_status_type, 'PST')::text as "uniqueText",
        'Category' as "group",
        true as is_root,
        pst.project_status_type,
        pst.project_status_type as root_project_status_type,
        1 as display_sort
      from flow.project_status_type pst
      where pst.archived is not true
      union all
      select
        null::bigint as id,
        'Project Status' as header,
        null::bigint as "projectStatusTypeId",
        null::bigint as "companyProjectStatusTypeId",
        false as archived,
        null::text as "uniqueText",
        null::text as "group",
        false as is_root,
        null::text as project_status_type,
        null::text as root_project_status_type,
        2 as display_sort
      union all
      select
        null::bigint as id,
        null::text as header,
        pst.id as "projectStatusTypeId",
        cpst.id as "companyProjectStatusTypeId",
        cpst.archived,
        concat(cpst.project_status_type, 'CPST')::text as "uniqueText",
        'Process Step' as "group",
        false as is_root,
        cpst.project_status_type,
        pst.project_status_type as root_project_status_type,
        3 as display_sort
      from flow.company_project_status_type cpst
             inner join flow.project_status_type pst on pst.id = cpst.project_status_type_id
      where cpst.company_id = :companyId
        and cpst.archived is not true
      order by display_sort, root_project_status_type, project_status_type
    """;

  //language=PostgreSQL
  public final static String getCompanyStatuses = """
    select
        cpst.id,
        cpst.project_status_type,
        cpst.display_order,
        cpst.is_default,
        cpst.color,
        pst.id as "projectStatusTypeId",
        cpst.archived,
        pst.project_status_type as "rootProjectStatusType"
    from flow.company_project_status_type cpst
    inner join flow.project_status_type pst on pst.id = cpst.project_status_type_id
    where cpst.company_id = :companyId and cpst.archived is not true
    order by cpst.display_order
    """;

  //language=PostgreSQL
  public final static String getOneCompanyStatus = """
    select
        cpst.id,
        cpst.project_status_type,
        cpst.display_order,
        cpst.is_default,
        pst.id as "projectStatusTypeId",
        cpst.archived,
        pst.project_status_type as "rootProjectStatusType"
    from flow.company_project_status_type cpst
    inner join flow.project_status_type pst on pst.id = cpst.project_status_type_id
    where cpst.id = :id
    """;

  //language=PostgreSQL
  public final static String getStatuses = """
    select
        pst.id,
        pst.project_status_type,
        pst.archived
    from flow.project_status_type pst
    where pst.archived is not true
    order by pst.project_status_type
    """;

  //language=PostgreSQL
  public final static String updateCompanyStatus = """
    update flow.company_project_status_type
    set project_status_type = :projectStatusType,
        modified_by_id = :currentUserId,
        display_order = :displayOrder,
        color = :color,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getProjectsWithStatusInUse = """
select project_name
    from flow.project
    where company_project_status_type_id = :companyProjectStatusTypeId
      and archived is false
    """;

  //language=PostgreSQL
  public final static String psaWithStatusInUse = """
select psa.action_name, ps.process_step_name
      from flow.process_step_action psa
         inner join flow.process_step ps on ps.id = psa.process_step_id
      where psa.archived is not true and ps.archived is not true
        and psa.company_project_status_type_id = :companyProjectStatusTypeId
    """;

  //language=PostgreSQL
  public final static String getPserWithStatusInUse = """
select e.event_name, ps.process_step_name
      from flow.process_step_event_requirement pser
        inner join flow.process_step_event pse on pser.process_step_event_id = pse.id
        inner join flow.process_step ps on pse.process_step_id = ps.id
        inner join flow.event e on pse.event_id = e.id
      where pser.archived is false and pse.archived is false and pser.process_step_requirement_type_id = 9 and :companyProjectStatusTypeId = any (pser.list_of_value_ids)
    """;

  //language=PostgreSQL
  public final static String getPsrWithStatusInUse = """
select ps.process_step_name
      from flow.process_step_requirement psr
        inner join flow.process_step ps on psr.process_step_id = ps.id
      where psr.archived is false and psr.process_step_requirement_type_id = 9 and :companyProjectStatusTypeId = any (psr.list_of_value_ids)
    """;

  //language=PostgreSQL
  public final static String getPsaWithStatusInUse = """
select psa.action_name, ps.process_step_name
      from flow.process_step_action_logic psl
        inner join flow.process_step_action psa on psa.id = psl.process_step_action_id
        inner join flow.process_step ps on ps.id = psa.process_step_id
      where psa.company_project_status_type_id = :companyProjectStatusTypeId
        and psl.archived is not true
        and psa.archived is not true
      group by psa.action_name, ps.process_step_name
    """;

  //language=PostgreSQL
  public final static String getEventReqWithStatusInUse = """
      select psa.action_name, ps.process_step_name
      from flow.process_step_action_logic psl
        inner join flow.process_step_action psa on psa.id = psl.process_step_action_id
        inner join flow.process_step ps on ps.id = psa.process_step_id
      where psa.company_project_status_type_id = :companyProjectStatusTypeId
        and psl.archived is not true
        and psa.archived is not true
      group by psa.action_name, ps.process_step_name
    """;

  //language=PostgreSQL
  public final static String getActionReqWithStatusInUse = """
 select psa.action_name, ps.process_step_name
      from flow.process_step_action_logic psl
        inner join flow.process_step_action psa on psa.id = psl.process_step_action_id
        inner join flow.process_step ps on ps.id = psa.process_step_id
      where psa.company_project_status_type_id = :companyProjectStatusTypeId
        and psl.archived is not true
        and psa.archived is not true
      group by psa.action_name, ps.process_step_name
    """;

  //language=PostgreSQL
  public final static String deleteCompanyStatus = """
    update flow.company_project_status_type
    set archived = true,
        modified_by_id = :currentUserId,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String saveInitialProjectStatusType = """
update flow.company_project_status_type
      set is_default = false, date_modified = now()
      where company_id = :companyId;
      update flow.company_project_status_type
      set is_default = true, date_modified = now()
      where id = :id
    """;

  //language=PostgreSQL
  public final static String insertCompanyStatus = """
insert into flow.company_project_status_type(project_status_type_id, project_status_type, company_id, display_order, created_by_id, date_created, modified_by_id, date_modified)
    values (:rootProjectStatusTypeId, :projectStatusType, :companyId, (select coalesce(max(display_order) + 1, 0) from flow.company_project_status_type where company_id = :companyId and archived is not true), :currentUserId, now(), :currentUserId, now())
    """;

  //language=PostgreSQL
  public final static String updateStatus = """
    update flow.project
    set company_project_status_type_id = :companyProjectStatusTypeId,
        date_modified = now()
    where id = :projectId
    """;

  //language=PostgreSQL
  public final static String getStatusDetails = """
     select p.id,
            p.company_project_status_type_id as "companyProjectStatusTypeId",
            cpst.project_status_type         as "projectStatusType",
            cpst.project_status_type_id      as "projectStatusTypeId",
            pst.project_status_type          as "rootProjectStatusType"
     from flow.project p
            inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
            inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
     where p.id = :projectId
    """;

  //language=PostgreSQL
  public final static String updateGeoLocation = """
    update flow.project
      set latitude = :latitude,
          longitude = :longitude,
          time_zone = :timeZone,
          date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String updateNameByContactId = """
update flow.project
set project_name = :name,
    modified_by_id = :userId,
    date_modified = now()
where contact_id = :contactId
    """;

  //language=PostgreSQL
  public final static String getProjectInstallationScopeOfWork = """
    select lov.name from flow.project_process_step_custom_field_value ppscfv
        left join flow.list_of_value lov ON ppscfv.int_value = lov.id
    where ppscfv.custom_field_group_assignment_id = 23248 and ppscfv.project_process_step_id =
        (select
             pps.id
         from flow.project p
                  inner join flow.project_process_step pps on pps.project_id = p.id
                  inner join flow.project_process_step_event ppse on ppse.project_process_step_id = pps.id
                  inner join flow.process_step ps on ps.id = pps.process_step_id
                  inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
         where p.id = :projectId
           and pps.archived is not true
           and ppse.archived is not true
           and p.archived is not true
           and ppse.process_step_event_id = 22
           and cest.event_status_type_id =
               (select id from flow.company_event_status_type cest2 where cest2.company_id = :companyId
                                                                      and cest2.event_status_type = 'Active')
         order by ppse.start_time desc limit 1)
    """;

  //language=PostgreSQL
  public final static String getAttachmentType = """
    select oat.id,
                 oat.company_id,
                 oat.attachment_type_id,
                 at.attachment_type,
                 oat.allow_upload,
                 oat.archived,
                 oat.read_only,
                 oat.linkable,
                 oat.focused,
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
                                   WHERE cfg.project_attachment_type_id = oat.id AND cfg.archived is not true
                                   order by cfg.group_order) cfGroups), '[]') AS custom_field_groups
          from flow.project_attachment_type oat
                 inner join flow.attachment_type at on oat.attachment_type_id = at.id
          where oat.id = :id
          and oat.company_id = :companyId
    """;


}
