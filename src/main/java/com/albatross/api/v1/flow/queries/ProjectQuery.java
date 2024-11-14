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
SELECT     p.id,
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
select id,
       project_name,
       city,
       state,
       project_status_type,
       latitude,
       longitude,
       postalcode as postal_code,
       street1
from flow.density_projects_with_down_line(:companyId::bigint,
                                          :currentUserId::bigint,
                                          :isParent,
                                          ARRAY [ :companyProjectStatusTypeIds ]::bigint[],
                                          :upperBoundLatitude::numeric,
                                          :upperBoundLongitude::numeric,
                                          :lowerBoundLatitude::numeric,
                                          :lowerBoundLongitude::numeric)
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
                                                            :sortColumn::character varying, :sortDirection::character varying,
                                                            :includeCommissionDetails::boolean,
                                                            :searchColumn::character varying,
                                                            array[ :partnerIds ]::bigint[])
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
                                  :sortDirection::character varying,
                                  :searchColumn::character varying,
                                  array[ :partnerIds ]::bigint[])
    """;


  //language=PostgreSQL
  public final static String searchByOwner = """
select *
    from flow.search_projects_by_user(:query::character varying, :companyId::bigint,
                                 :userId::bigint,  :isParent::boolean,:limit::bigint, :offset::bigint,
                                                            :companyProjectStatusTypeId::bigint,
                                                            :sortColumn::character varying, :sortDirection::character varying,
                                                            :includeCommissionDetails::boolean,
                                                            :searchColumn::character varying,
                                                            array[ :partnerIds ]::bigint[])
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
  public final static String addChildren = """
    select * from flow.add_project_children(:projectId::bigint, :companyId::bigint, :userId::bigint,
                              :childProjectCount::bigint, :childCompanyProcessId::bigint)
  """;

  //language=PostgreSQL
  public final static String updateProjectContactId = """
    update flow.project
      set contact_id = :contactId,
          modified_by_id = :userId,
          date_modified = now()
    where id = :projectId
  """;

  //language=PostgreSQL
  public final static String getChildren = """
  select
        p.id,
        p.project_name as "projectName",
        p.street1,
        p.city,
        p.postal_code as "postalCode",
        p.date_created as "dateCreated",
        p.object_category_id as "objectCategoryId",
        oc.object_category as "objectCategory",
        p.company_project_status_type_id as "companyProjectStatusTypeId",
        cpst.project_status_type_id as "projectStatusTypeId",
        cpst.project_status_type as "projectStatusType",
        pst.project_status_type as "rootProjectStatusType"
      from flow.project p
        inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
        inner join flow.object_category oc on oc.id = p.object_category_id
        inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
     where p.parent_id = :projectId
     and p.archived is false
     order by p.id
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
        p.company_process_id,
        p.time_zone,
        p.latitude,
        p.longitude,
        pst.project_status_type as "rootProjectStatusType",
        pro.process_name,
        p.contact_id,
        p.object_category_id,
        oc.object_category,
        contactOc.object_category as contact_object_category,
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
                     ust.has_access as "hasAccess",
                     pos.sms_enabled as "hasSmsAccess"
                  FROM flow."user" u
                    inner join flow.user_position up on up.user_id = u.id
                    inner join flow.position pos on pos.id = up.position_id
                    inner join flow.company_user_status cus on cus.user_id = u.id
                    inner join flow.user_status_type ust on cus.user_status_type_id = ust.id and ust.company_id = ct.company_id
                  WHERE up.id = p.user_position_id) o) AS owner,
        (SELECT row_to_json(o)
            FROM (select
                                            p2.id,
                                            p2.project_name as "projectName",
                                            p2.street1,
                                            p2.city,
                                            p2.contact_id as "contactId",
                                            p2.postal_code as "postalCode",
                                            p2.date_created as "dateCreated",
                                            p2.object_category_id as "objectCategoryId",
                                            oc.object_category as "objectCategory",
                                            p2.company_project_status_type_id as "companyProjectStatusTypeId",
                                            cpst.project_status_type_id as "projectStatusTypeId",
                                            cpst.project_status_type as "projectStatusType",
                                            pst.project_status_type as "rootProjectStatusType",
                                            oc.object_category as "objectCategory",
                                            p2.object_category_id as "objectCategoryId"
                                          from flow.project p2
                                            inner join flow.company_project_status_type cpst on p2.company_project_status_type_id = cpst.id
                                            inner join flow.object_category oc on oc.id = p2.object_category_id
                                            inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
                                         where p2.id = p.parent_id
                                         and p2.archived is false) o) AS parent_project,
        p.project_name,
        ct.first_name,
        ct.last_name,
        p.company_project_status_type_id,
        cpst.project_status_type,
        cpst.project_status_type_id,
        cot.status_read_only,
        cot.status_read_only_allow,
        cot.owner_read_only,
        cot.owner_read_only_allow,
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
       SELECT array_to_json(array_agg(row_to_json(childCompanyProcesses)))
       FROM (
              select cp2.id,
                     p2.process_name as "childProcessName"
              from flow.company_process cp2
                       inner join flow.process p2 on p2.id = cp2.process_id
              where cp2.company_id = :companyId
                and cp2.archived is not true
                and p2.object_category_id in (
                  select occoc.child_object_category_id
                  from flow.object_category_child_object_category occoc
                           inner join flow.process p3 on p3.object_category_id = occoc.object_category_id
                           inner join flow.company_process cp3 on cp3.process_id = p3.id
                  where occoc.archived is false
                    and cp3.id = p.company_process_id
              )
              order by p2.process_name) childCompanyProcesses), '[]') AS "childCompanyProcesses",
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
                                AND wlp.archived is not true) wlp), '[]') AS "ownerReadOnlyWhiteListedPositions",
                    coalesce((
                                SELECT array_to_json(array_agg(row_to_json(projects)))
                                FROM (
                                         select
                                            p2.id,
                                            p2.project_name as "projectName",
                                            p2.street1,
                                            p2.city,
                                            p2.postal_code as "postalCode",
                                            p2.date_created as "dateCreated",
                                            p2.object_category_id as "objectCategoryId",
                                            oc.object_category as "objectCategory",
                                            p2.company_project_status_type_id as "companyProjectStatusTypeId",
                                            cpst.project_status_type_id as "projectStatusTypeId",
                                            cpst.project_status_type as "projectStatusType",
                                            pst.project_status_type as "rootProjectStatusType"
                                          from flow.project p2
                                            inner join flow.company_project_status_type cpst on p2.company_project_status_type_id = cpst.id
                                            inner join flow.object_category oc on oc.id = p2.object_category_id
                                            inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
                                         where p2.parent_id = p.id
                                         and p2.archived is false
                                         order by p2.id
                                         limit 3
                                     ) projects), '[]') AS "childProjects"
      from flow.company_process cp
      inner join flow.project p on cp.id = p.company_process_id
      inner join flow.object_category oc on oc.id = p.object_category_id
      inner join flow.contact ct on ct.id = p.contact_id
      inner join flow.object_category contactOc on contactOc.id = ct.object_category_id
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
        and cp.company_id = :companyId
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
      insert into flow.project (contact_id, company_process_id, project_name, company_project_status_type_id, street1, city, company_state_id, company_country_id, postal_code, latitude, longitude, time_zone, created_by_id, date_created, modified_by_id, date_modified, user_position_id, object_category_id)
      values (:contactId, :processId, trim(:projectName), :companyProjectStatusTypeId, :street1, :city, :companyStateId, :companyCountryId, trim(:postalCode), :latitude, :longitude, :timezone, :createdById, now(), :createdById, now(), :userPositionId, :objectCategoryId)
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
  public final static String getWorkQueueHistoryByProjectId = """
      select wqc.date_entered_queue,
             wqc.date_exited_queue,
             pswqt.work_queue_type_id,
             null as event_name,
             ps.process_step_name,
             case when wqc.date_exited_queue is null then 'Currently in Queue' else 'Work Queue History' end as status,
             wqt.work_queue_type,
             wq_cat.work_queue_category,
             (coalesce(wqc.date_exited_queue::date, now()::date) - wqc.date_entered_queue::date) as days_in_queue
      from flow.work_queue_cycle wqc
               inner join flow.project_process_step pps on pps.id = wqc.project_process_step_id and pps.archived is false
               inner join flow.process_step ps on ps.id = pps.process_step_id and ps.company_id = :companyId
               inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst  on pswqtpsst.id = wqc.process_step_work_queue_type_process_step_status_type_id
               inner join flow.process_step_work_queue_type pswqt on pswqt.id = pswqtpsst.process_step_work_queue_type_id
               inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id
               inner join flow.work_queue_category wq_cat on wq_cat.id = wqt.work_queue_category_id
      where pps.project_id = :projectId
          and wqt.archived is false
          and pswqt.archived is false
      union all
      select wqc.date_entered_queue,
             wqc.date_exited_queue,
             psewqt.work_queue_type_id,
             e.event_name,
             ps.process_step_name,
             case when wqc.date_exited_queue is null then 'Currently in Queue' else 'Work Queue History' end as status,
             wqt.work_queue_type,
             wq_cat.work_queue_category,
             (coalesce(wqc.date_exited_queue::date, now()::date) - wqc.date_entered_queue::date) as days_in_queue
      from flow.work_queue_cycle wqc
               inner join flow.project_process_step_event ppse on ppse.id = wqc.project_process_step_event_id and ppse.archived is false
               inner join flow.process_step_event pse on pse.id = ppse.process_step_event_id
               inner join flow.event e on e.id = pse.event_id
               inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id and pps.archived is false
               inner join flow.process_step ps on ps.id = pps.process_step_id and ps.company_id = :companyId
               inner join flow.process_step_event_work_queue_type_event_status_type psewqtest on psewqtest.id = wqc.process_step_event_work_queue_type_event_status_type_id
               inner join flow.process_step_event_work_queue_type psewqt on psewqt.id = psewqtest.process_step_event_work_queue_type_id
               inner join flow.work_queue_type wqt on wqt.id = psewqt.work_queue_type_id
               inner join flow.work_queue_category wq_cat on wq_cat.id = wqt.work_queue_category_id
      where pps.project_id = :projectId
          and wqt.archived is false
          and psewqt.archived is false
      order by date_exited_queue desc nulls first, date_entered_queue desc
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
        e.hidden as eventHidden,
        e.hidden_allow as eventHiddenAllow,
        (select cfga.id
            from flow.project_process_step_event_custom_field_value ppsecfv
               inner join flow.custom_field_group_assignment cfga
                 on ppsecfv.custom_field_group_assignment_id = cfga.id
                  and cfga.archived is false and cfga.display_on_snippet is true
               inner join flow.custom_field cf on cf.id = cfga.custom_field_id
            where ppsecfv.project_process_step_event_id = ppse.id) as "customFieldDisplayValueGroupAssignmentId",
        ppse.resource_id,
        cest.event_status_type_id,
        cest.id as company_event_status_type_id,
        case when sl.system_list_type_id = 1 then o.org_name else concat(u.first_name, ' ', u.last_name) end as resource,
        coalesce((
                  SELECT array_to_json(array_agg(row_to_json(wlp)))
                  FROM (
                         SELECT wlp.id,
                                wlp.position_id as "positionId",
                                wlp.event_id as "eventId",
                                wlp.created_by_id as "createdById",
                                wlp.modified_by_id as "modifiedById",
                                wlp.archived
                         FROM flow.white_listed_position wlp
                         WHERE wlp.white_list_type_id = 17
                           AND wlp.archived is not true
                           and wlp.company_id = :companyId
                           and wlp.event_id = e.id) wlp), '[]') AS "eventHiddenWhiteListedPositions"
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
         and case when e.hidden and :systemAdmin::boolean is false and e.hidden_allow
                       then pse.event_id = ( select wlp2.event_id from flow.white_listed_position wlp2
                                             where wlp2.event_id = pse.event_id
                                               and wlp2.white_list_type_id = 17
                                               and wlp2.archived is not true
                                               and wlp2.company_id = :companyId
                                               and wlp2.position_id = any(array[ :userPositions ]::bigint[]) limit 1
            )
            when e.hidden and :systemAdmin::boolean is false and not e.hidden_allow
            --case when below is empty, then true else do below
                      then case when ( select wlp2.event_id from flow.white_listed_position wlp2
                                             where wlp2.event_id = pse.event_id
                                               and wlp2.white_list_type_id = 17
                                               and wlp2.company_id = :companyId
                                               and wlp2.archived is not true
                                         limit 1
            ) is null then true
                       else pse.event_id = ( select wlp2.event_id from flow.white_listed_position wlp2
                                             where wlp2.event_id = pse.event_id
                                               and wlp2.white_list_type_id = 17
                                               and wlp2.company_id = :companyId
                                               and wlp2.archived is not true
                                         limit 1
            ) end
                   else 1=1 end
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
  public final static String getObjectTypeByProcess = """
    select object_category_id
    from flow.process p
    where p.id = :processId
 """;

  //language=PostgreSQL
  public final static String getOwners = """
select * from flow.get_project_available_owners(:companyId::bigint, :parentCompanyId::bigint, :isParent::bool)
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

    public final static String updateAddressByContactId = """
update flow.project
set street1 = :street1,
    city = :city,
    company_state_id = :companyStateId,
    company_country_id = :companyCountryId,
    postal_code = :postalCode,
    modified_by_id = :modifiedById,
    date_modified = now(),
    latitude = :latitude,
    longitude = :longitude,
    time_zone = :timezone
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
                                                                                       AND wlp.company_id = :companyId
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

  public final static String getStatusFieldsByProject = """
          with fields as (select cpsfa.id,
                                                       cpsfa.company_project_status_type_id,
                                                       coalesce(dvcfc.display_name, dvfc.display_name) as field_name,
                                                       cpsfa.display_order,
                                                       case
                                                           when dvcfc.id is not null then ubt.return_data_type_id
                                                           when dvfc.id is not null and def.data_type_id is not null then def.data_type_id
                                                           when dvfc.id is not null and def.data_type_id is null
                                                               then (select t.data_type_id
                                                                     from flow.custom_field_group_assignment c
                                                                              inner join flow.custom_field f on f.id = c.custom_field_id
                                                                              inner join flow.company_data_type t on t.id = f.company_data_type_id
                                                                     where c.id = dvfc.custom_field_group_assignment_id)
                                                           end                                                      as data_type_id,
                                                       case
                                                           when cpsfa.data_view_child_field_config_id is not null then
                                                               (select flow.get_value_for_data_view_child_field(cpsfa.data_view_child_field_config_id,
                                                                                                                :projectId))::text
                                                           else (select flow.get_value_for_data_view_field(cpsfa.data_view_field_config_id,
                                                                                                           :projectId)) end::text as field_value
                                                from flow.company_project_status_field_assignment cpsfa
                                                         inner join flow.company_project_status_type cpst
                                                                    on cpsfa.company_project_status_type_id = cpst.id
                                                                        and case when :companyProjectStatusTypeId::int is not null then
                                                                                         cpst.id = :companyProjectStatusTypeId::int else true end
                                                         left join flow.data_view_field_config dvfc on cpsfa.data_view_field_config_id = dvfc.id
                                                         left join flow.data_view_child_field_config dvcfc
                                                                   on cpsfa.data_view_child_field_config_id = dvcfc.id
                                                         left join flow.default_field def on def.id = dvfc.default_field_id
                                                         left join flow.unique_behavior_type ubt on ubt.id = dvcfc.unique_behavior_type_id
                                                where cpsfa.archived is false
                                                  and cpst.company_id = :companyId)
                                select cpst.id,
                                       cpst.project_status_type_id,
                                       cpst.project_status_type,
                                       cpst.company_id,
                                       cpst.icon_tag,
                                       cpst.display_order,
                                       cpst.description,
                                       cpst.is_milestone,
                                       coalesce((
                                                    SELECT array_to_json(array_agg(row_to_json(assignedFields)))
                                                    FROM (
                                                             SELECT id,
                                                                    data_type_id as "dataTypeId",
                                                                    field_name as "fieldName",
                                                                    field_value as "fieldValue",
                                                                    f.display_order as "displayOrder"
                                                             FROM fields f
                                                             WHERE f.company_project_status_type_id = cpst.id
                                                             order by f.display_order) assignedFields), '[]') AS "assignedFields"
                                from flow.company_project_status_type cpst
                                where cpst.archived is false
                                  and cpst.is_milestone is true
                                  and cpst.company_id = :companyId
                                  and case when :companyProjectStatusTypeId::int is not null then
                                                   cpst.id = :companyProjectStatusTypeId::int else true end
                                order by cpst.display_order;
    """;
}
