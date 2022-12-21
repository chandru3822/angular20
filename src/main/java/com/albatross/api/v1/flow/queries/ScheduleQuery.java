package com.albatross.api.v1.flow.queries;

public class ScheduleQuery {

  //language=PostgreSQL
  public final static String getUserPositionIdsForUsers = """
    select id
        from flow.user_position up
        where user_id = any(array[ :userIds ]::bigint[])
        """;

  //language=PostgreSQL
  public final static String getEventsByProject = """
    select p.id,
               p.project_name,
               c.id as contact_id,
               c.phone,
               c.mobile,
               coalesce((
                          SELECT array_to_json(array_agg(row_to_json(steps)))
                          FROM (
                                 SELECT ppse.id,
                                        ps.process_step_name as "processStepName",
                                        pps.id as "projectProcessStepId",
                                        ps.id as "processStepId",
                                        pse.id as "processStepEventId",
                                        pse.event_id as "eventId",
                                        e.event_name as "eventName",
                                        pps.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
                                        cpsst.process_step_status_type as "processStepStatusType",
                                        cpsst.process_step_status_type_id as "processStepStatusTypeId",
                                        ppse.start_time as "startTime",
                                        ppse.end_time as "endTime",
                                        ppse.save_version as "saveVersion",
                                        pps.project_id as "projectId",
                                        cest.event_status_type as "eventStatusType",
                                        cest.id as "companyEventStatusTypeId",
                                        cest.event_status_type_id as "eventStatusTypeId",
                                        case when sl.system_list_type_id = 1 then o.org_name else concat(u.first_name, ' ', u.last_name) end as "resource"
                                 from flow.project_process_step_event ppse
                                        inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
                                        inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
                                        inner join flow.event e on pse.event_id = e.id
                                        inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
                                        inner join flow.process_step ps on pps.process_step_id = ps.id
                                        inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
                                        inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
                                        left join flow.user_position up on up.id = ppse.resource_id
                                        left join flow.user u on u.id = up.user_id
                                        left join flow.org o on o.id = ppse.resource_id
                                        inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
                                        inner join flow.system_list sl on sl.id = csl.system_list_id
                                 where pps.project_id = :projectId
                                   and pps.archived is not true
                                   and pps.main is true
                                   and ppse.archived is not true
                                 order by start_time, end_time
                               ) steps), '[]') AS "events"
        from flow.project p
               inner join flow.contact c on p.contact_id = c.id
        where p.id = :projectId
          and p.archived is false
        """;

  //language=PostgreSQL
  public final static String getEvents = """
    select
          pps.process_step_id,
          pps.project_id,
          pps.id as project_process_step_id,
          ppse.id as project_process_step_event_id,
          pse.id as process_step_event_id,
          e.event_name,
          cest.event_status_type_id,
          e.id as event_id,
          sl.system_list_type_id,
          ppse.start_time as start,
          ppse.end_time as "end",
          ppse.resource_id as resource_id,
          ppse.save_version,
          u.id as user_id,
          c.id as contact_id,
          c.first_name as contact_first_name,
          c.last_name as contact_last_name,
          c.phone,
          c.mobile,
          p.latitude,
          p.longitude,
          p.street1,
          p.city,
          p.postal_code,
          s.abbreviation as state_abbreviation,
          case when sl.system_list_type_id = 1 then o.org_name else concat(u.first_name, ' ', u.last_name) end as resource_name,
          p.project_name,
          ps.process_step_name,
          p.company_state_id,
          s.state,
          pps.company_process_step_status_type_id,
          cpsst.process_step_status_type,
          cpsst.process_step_status_type_id
        from flow.project_process_step pps
               inner join flow.project_process_step_event ppse on pps.id = ppse.project_process_step_id
               inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
               inner join flow.event e on pse.event_id = e.id
               inner join flow.project p on p.id = pps.project_id
               inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
               inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
               inner join flow.process_step ps on ps.id = pps.process_step_id
               inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
               inner join flow.contact c on c.id = p.contact_id
               inner join flow.company_state cs on cs.id = p.company_state_id
               inner join flow.state s on s.id = cs.state_id
               inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
               left join flow.user_position up on up.id = ppse.resource_id
               left join flow.user u on u.id = up.user_id
               left join flow.org o on o.id = ppse.resource_id
               inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
               inner join flow.system_list sl on sl.id = csl.system_list_id
        where  ppse.start_time is not null
          and ppse.end_time is not null
          and p.archived is false
          and ppse.archived is not true
          and ppse.resource_id is not null
          and case when :startTime::timestamp is not null and :endTime::timestamp is not null
                     then ppse.start_time between :startTime::timestamp and :endTime::timestamp OR
                          ppse.end_time between :startTime::timestamp and :endTime::timestamp else 1=1 end
          and case when :isParent
                     then ps.company_id = any (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
                   else ps.company_id = :companyId end
          and ps.archived is not true
          and case when :includeCancelled::boolean is false
            then cest.event_status_type_id != 3
             else true end -- dont include cancelled events unless they told us to, we include active events on cancelled PS cuz BR told us to
          and cpst.project_status_type_id != 2 --dont include process steps for cancelled projects
          and ppse.resource_id is not null
          and ppse.resource_id = any(array[ :combined ]::bigint[])
        """;

  //language=PostgreSQL
  public final static String getAvailability = """
    select *
        from flow.get_availability(:startTime::timestamp, :endTime::timestamp, array[ :orgIds ]::bigint[], array[ :userIds ]::bigint[]);
        """;

  //language=PostgreSQL
  public final static String getProjects = """
    select
          pps.process_step_id,
          pps.project_id,
          pps.id as project_process_step_id,
          ppse.company_event_status_type_id,
          cest.event_status_type_id,
          cest.event_status_type as "companyEventStatusType",
          ps.company_id,
          pse.event_id,
          e.event_name,
          array_to_json(cf.system_list_option_ids) as system_list_option_ids,
          sl.system_list_type_id,
          sl.id as system_list_id,
          ppse.id as project_process_step_event_id,
          ppse.start_time as start,
          ppse.end_time as "end",
          ppse.resource_id as resource_id,
          p.latitude,
          p.contact_id,
          p.longitude,
          case when sl.system_list_type_id = 1 then o.org_name else concat(u.first_name, ' ', u.last_name) end as resource_name,
          p.project_name,
          ps.process_step_name,
          p.company_state_id,
          s.state,
          p.street1,
          p.city,
          ppse.save_version,
          p.postal_code,
          s.abbreviation as state_abbreviation,
          pps.company_process_step_status_type_id,
          cpsst.process_step_status_type,
          cpsst.process_step_status_type_id
        from flow.project_process_step pps
               inner join flow.project_process_step_event ppse on pps.id = ppse.project_process_step_id
               inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
               inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
               inner join flow.event e on pse.event_id = e.id
               inner join flow.project p on p.id = pps.project_id
               inner join flow.process_step ps on ps.id = pps.process_step_id
               inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
               inner join flow.company_state cs on cs.id = p.company_state_id
               inner join flow.state s on s.id = cs.state_id
               inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
               left join flow.user_position up on up.id = ppse.resource_id
               left join flow.user u on u.id = up.user_id
               left join flow.org o on o.id = ppse.resource_id
               inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
               inner join flow.system_list sl on sl.id = csl.system_list_id
        where case when :isParent
                     then ps.company_id = any (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
                   else ps.company_id = :companyId end
          and ps.archived is not true
          and p.archived is false
          and case when :isParent then
                       p.company_state_id in (select id from flow.company_state where state_id = (select state_id from flow.company_state where id = :companyStateId))
                   else p.company_state_id = :companyStateId end
          and case when ppse.start_time is not null then ppse.start_time >= :startTime::timestamp else 1=1 end
          and case when ppse.end_time is not null then ppse.end_time <= :endTime::timestamp else 1=1 end
          and pse.event_id  = any(array[ :eventIds ])
          and cpsst.process_step_status_type_id = :processStepStatusTypeId
          and cest.event_status_type_id = :eventStatusTypeId
          and lower(translate(coalesce(p.project_name, ''), '*,.& ', '')) like
              '%' || lower(trim(translate(:search, '*,.& ', ''))) || '%'
        order by p.date_created desc
        limit :limit
        offset :offset
        """;

  //language=PostgreSQL
  public final static String getAvailableProjectResources = """
    select *
          from flow.get_system_list_options(:companyId::bigint, :systemListId::bigint, true, array[ :systemListOptionIds ]::bigint[], :resourceId::bigint)
        """;

  //language=PostgreSQL
  public final static String getProject = """
    select pps.process_step_id,
           pps.project_id,
           ps.company_id,
           ppse.id as project_process_step_event_id,
           ppse.save_version,
           ppse.process_step_event_id,
           pse.event_id,
           e.event_name,
           ppse.company_event_status_type_id,
           cest.event_status_type_id,
           sl.id as system_list_id,
           array_to_json(cf.system_list_option_ids) as system_list_option_ids,
           pps.id as project_process_step_id,
           sl.system_list_type_id,
           ppse.id as project_process_step_event_id,
           ppse.start_time as start,
           ppse.end_time as "end",
           ppse.resource_id as resource_id,
           c.first_name as contact_first_name,
           c.last_name as contact_last_name,
           p.latitude,
           p.longitude,
           p.street1,
           p.contact_id,
           p.city,
           p.postal_code,
           s.abbreviation as state_abbreviation,
           case when sl.system_list_type_id = 1 then o.org_name else concat(u.first_name, ' ', u.last_name) end as resource_name,
           p.project_name,
           ps.process_step_name,
           p.company_state_id,
           s.state,
           pps.company_process_step_status_type_id,
           cpsst.process_step_status_type,
           cpsst.process_step_status_type_id,
           case when sl.id is not null then coalesce((
                                                       SELECT array_to_json(array_agg(row_to_json(sys)))
                                                       FROM (
                                                              select *
                                                              from flow.get_system_list_options(ps.company_id::bigint, sl.id::bigint, true, cf.system_list_option_ids::bigint[])
                                                            ) sys), '[]') else '[]' end as resources
    from flow.project_process_step_event ppse
           inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
           inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
           inner join flow.process_step ps on ps.id = pps.process_step_id
           inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
           inner join flow.project p on p.id = pps.project_id
           inner join flow.contact c on c.id = p.contact_id
           inner join flow.company_state cs on cs.id = p.company_state_id
           inner join flow.state s on s.id = cs.state_id
           inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
           inner join flow.event e on pse.event_id = e.id
           inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
           left join flow.user_position up on up.id = ppse.resource_id
           left join flow.user u on u.id = up.user_id
           left join flow.org o on o.id = ppse.resource_id
           inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
           inner join flow.system_list sl on sl.id = csl.system_list_id
    where case when :isParent
                 then ps.company_id = any (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
               else ps.company_id = :companyId end
      and ps.archived is not true
      and pse.archived is not true
      and ppse.archived is not true
      and case when :eventId::bigint is not null then pse.event_id = :eventId::bigint else 1=1 end
      and case when :projectProcessStepEventId::bigint is not null then ppse.id = :projectProcessStepEventId::bigint else 1=1 end
      and case when :projectId::bigint is not null then pps.project_id = :projectId::bigint else 1=1 end
      and case when :processStepStatusTypeId::bigint is null then 1=1 else cpsst.process_step_status_type_id = :processStepStatusTypeId::bigint end
      and case when :eventStatusTypeId::bigint is null then 1=1 else cest.event_status_type_id = :eventStatusTypeId::bigint end

        """;

  //language=PostgreSQL
  public final static String searchProjectsByName = """
      select c.first_name as contact_first_name,
           c.last_name as contact_last_name,
           c.id as contact_id,
           concat(c.first_name, ' ', c.last_name) as contact_full_name,
           p.project_name,
           p.id as project_id
    from flow.project p
           inner join flow.contact c on c.id = p.contact_id
    where c.archived is not true
      and p.archived is not true
      and case when :isParent
                 then c.company_id = any (select id from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
               else c.company_id = :companyId end
      and ((p.id::text like '%' || :search || '%') or
           (p.project_name_search like '%' || lower(trim(translate(:search, '*,.& ', ''))) || '%'))
    order by c.first_name, c.last_name
    limit 50
    """;

}
