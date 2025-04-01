package com.albatross.api.v1.flow.queries;

public class CapacityQuery {

    //language=PostgreSQL
    public final static String getForRange = """
            SELECT
              vrsc.id,
              vrsc.max_capacity,
              vrsc.start_time as "start",
              vrsc.end_time as "end"
            FROM flow.virtual_resource_slot_capacity vrsc
            WHERE vrsc.start_time > :rangeStart::timestamp without time zone and
            	      vrsc.start_time < :rangeEnd::timestamp without time zone and
            	      vrsc.org_id = :orgId and
            	      vrsc.archived = false
            """;

    //language=PostgreSQL
    public final static String insertForRange = """
            insert into flow.virtual_resource_slot_capacity (company_id, org_id, max_capacity, start_time, end_time, date_modified, created_by_id, modified_by_id)
            values (:companyId, :orgId, :maxCapacity, :startTime, :endTime, now(), :createdById, :createdById)
            returning id, max_capacity, start_time, end_time;
            """;

    //language=PostgreSQL
    public final static String updateForScheduleId = """
            update flow.virtual_resource_slot_capacity
            set max_capacity = :maxCapacity
            where id = :scheduleId
            returning id, max_capacity, start_time, end_time;
            """;

    //language=PostgreSQL
    public final static String getBookedForRanged = """
        select ppse.id as "ppseId",
               cfv.timestamp_value as "startTime",
               p.id as "projectId",
               s.abbreviation as "state",
               c.first_name || ' ' || c.last_name as "customerName",
               ppse.date_created as "appointmentCreated"
        from flow.project_process_step_event ppse
                 join flow.project_process_step_event_custom_field_value cfv on cfv.project_process_step_event_id = ppse.id
                 join flow.project_process_step pps on pps.id = ppse.project_process_step_id
                 join flow.project p on p.id = pps.project_id
                 join flow.state s on s.id = p.company_state_id
                 join flow.contact c on c.id = p.contact_id
        where ppse.process_step_event_id = 14
          and cfv.custom_field_group_assignment_id = 26708
          and ppse.archived is not true
          and ppse.cancelled_date is null
          and cfv.timestamp_value between :startTime::timestamp and :endTime::timestamp
    """;

    //language=PostgreSQL
    public final static String getOrgEventCount = """
        select
        	COUNT(ppse.id)
        from flow.project_process_step pps
        	     inner join flow.project_process_step_event ppse on pps.id = ppse.project_process_step_id
        	     inner join flow.project p on p.id = pps.project_id
        	     inner join flow.process_step ps on ps.id = pps.process_step_id
        	     inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
        	     inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
        where  ppse.start_time is not null
          and ppse.end_time is not null
          and p.archived is false
          and ppse.archived is not true
          and ppse.resource_id is not null
          and case when :startTime::timestamp is not null and :endTime::timestamp is not null
        	           then ppse.start_time between :startTime::timestamp and :endTime::timestamp OR
        	                ppse.end_time between :startTime::timestamp and :endTime::timestamp OR
        	                :startTime::timestamp between ppse.start_time and ppse.end_time else 1=1 end
          and ps.company_id = :companyId
          and ps.archived is not true
          and cest.event_status_type_id != 3 -- dont include cancelled events
          and cpst.project_status_type_id != 2 -- don't include process steps for cancelled projects
          and ppse.resource_id is not null
          and ppse.resource_id in (select upv.user_position_id from flow.user_positions_vw upv where position_id = :positionId and org_id=:orgId)
    """;

    //language=PostgreSQL
    public final static String duplicateCapacityWeek = """
    select * from brs.duplicate_capacity_week(:userId, :companyId, :orgId, :currentWeekStart, :currentWeekEnd)
    """;

    //language=PostgreSQL
    public final static String upsertMaxCapacity = """
        insert into flow.virtual_resource_slot_capacity(company_id, org_id, max_capacity, start_time, end_time, date_modified, created_by_id, modified_by_id)
        VALUES (:companyId, :orgId, :maxCapacity, :startTime, :endTime, now(), :userId, :userId)
         on conflict (company_id, org_id, start_time, end_time)
         do update
         set archived = false,
            max_capacity=:maxCapacity,
            date_modified=now(),
            modified_by_id=:userId
       """;
}
