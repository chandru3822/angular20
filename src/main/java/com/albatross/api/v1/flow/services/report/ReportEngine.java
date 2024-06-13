package com.albatross.api.v1.flow.services.report;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCacheRO;
import com.albatross.api.v1.flow.model.DataTypeRequirement;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEventWorkQueueType;
import com.albatross.api.v1.flow.model.smartlist.Smartlist;
import com.albatross.api.v1.flow.model.smartlist.SmartlistFieldAssignment;
import com.albatross.api.v1.flow.model.smartlist.SmartlistRequirement;
import com.albatross.api.v1.flow.model.smartlist.SmartlistSuperField;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeEventStatus;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeProcessStepStatus;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeProjectStatus;
import com.albatross.api.v1.flow.queries.CustomFieldQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReportEngine {

  private final SecurityService securityService;

  private final SqlCacheRO sqlCacheRO;

  private boolean isUUID(String str) {
    try {
      UUID.fromString(str);
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  public String buildSql(Smartlist smartlist, List<SmartlistFieldAssignment> fields, List<SmartlistRequirement> requirements) {
    return buildSql(smartlist, fields, requirements, null, null, false, null);
  }

  public String buildSql(
    Smartlist smartlist,
    List<SmartlistFieldAssignment> fields,
    List<SmartlistRequirement> requirements,
    String timezone,
    List<Long> installationCrewIds,
    Boolean addProjectContactIdFields,
    Integer limit
  ) {

    //@TODO humes: there is a lot of duplication in this function which could/should be abstracted out

    final Long companyId = securityService.getCurrentUser().getCompanyId();

    List<SmartlistFieldAssignment> joinTables = new ArrayList<>();

    List<Long> usedProcessStepIds = new ArrayList<>();

    StringBuilder withClause = new StringBuilder();
    StringBuilder additionalJoins = new StringBuilder();
    StringBuilder whereClause = new StringBuilder();

    // Get smartlist system lists
    withClause.append(String.format(" \"smartlistSystemList_1\" as (select * from flow.get_smartlist_system_list_options(1::bigint, %s::bigint)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_2\" as (select * from flow.get_smartlist_system_list_options(2::bigint, %s::bigint)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_3\" as (select id, name from flow.get_smartlist_system_list_options(3::bigint, %s::bigint)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_4\" as (select id, name from flow.get_smartlist_system_list_options(4::bigint, %s::bigint)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_5\" as (select id, name from flow.get_smartlist_system_list_options(5::bigint, %s::bigint)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_6\" as (select id, name from flow.get_smartlist_system_list_options(6::bigint, %s::bigint)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_7\" as (select id, name from flow.get_smartlist_system_list_options(7::bigint, %s::bigint)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_8\" as (select id, name from flow.get_smartlist_system_list_options(8::bigint, %s::bigint)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_9\" as (select id, name from flow.get_smartlist_system_list_options(9::bigint, %s::bigint)), ", companyId));

    // Get tables for system lists
    withClause.append(" \"systemList_1\" as (select up.id, concat(u.first_name, ' ', u.last_name::text) as name from flow.user_position up inner join flow.user u on u.id = up.user_id), ");
    withClause.append(" \"systemList_3\" as (select id, org_name::text as name from flow.org), ");
    withClause.append(" \"systemList_4\" as (select id, concat(first_name, ' ', last_name::text) as name from flow.user), ");

    StringBuilder query = new StringBuilder(" select ");

    if (null != smartlist.getWorkQueueTypeId()) {
      query.append(
        """
           flow.project.project_name                                                                             as "Project Name",
           flow.process_step.process_step_name                                                                   as "Process Step Name",
           cpsst.process_step_status_type                                                                        as "Process Step Status Type",
           (select coalesce(extract(days from now()::timestamp - wqc.date_entered_queue),
              DATE_PART('day', now() - flow.project_process_step.date_created)))                                 as "Days In Queue",
           st.abbreviation                                                                                       as "State Abbreviation",
           case when u.id is not null then concat(u.first_name, ' ', u.last_name) end                            as "Owner",
           (select array_to_string(array(
                                              select ps2.process_step_name
                                              from flow.project_process_step pps2
                                                     inner join flow.process_step ps2 on ps2.id = pps2.process_step_id
                                                     inner join flow.company_process_step_status_type cpsst2
                                                                on cpsst2.id = pps2.company_process_step_status_type_id
                                                     inner join flow.process_step_status_type psst2
                                                                on psst2.id = cpsst2.process_step_status_type_id
                                              where pps2.project_id = flow.project.id
                                                and cpsst2.process_step_status_type_id = 1
                                                and pps2.archived is not true
                                                and pps2.id != flow.project_process_step.id
                                              order by ps2.process_step_name
                                            ), ', '))                                                                  as "Active Process Steps",
                 flow.process_step.id                                                                                  as "processStepId",
                 flow.project_process_step.id                                                                          as "projectProcessStepId",
                 wqt.work_queue_type                                                                                   as "workQueueType",
                 wqt.id                                                                                                as "workQueueTypeId",
                 pswqt.id                                                                                              as "processStepWorkQueueTypeId",
                 flow.project_process_step.project_id                                                                  as "projectId",
                 flow.project.company_project_status_type_id                                                           as "companyProjectStatusTypeId",
                 cpst.project_status_type_id                                                                           as "projectStatusTypeId",
                 flow.project.contact_id                                                                               as "contactId",
                 to_char(coalesce(flow.project_process_step.date_modified, flow.project_process_step.date_created), 'MM-DD-YYYY HH12:MI:SS AM') as "lastUpdated",
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
                                     WHERE pt.project_id = flow.project.id
                                       AND pt.archived is not true) tags), '[]') AS "tags",
                 coalesce((
                              SELECT array_to_json(array_agg(row_to_json(owningPositions)))
                              FROM (
                                       SELECT pspop.id,
                                              pspop.process_step_process_id as "processStepProcessId",
                                              pspop.position_id             as "positionId",
                                              pspop.archived
                                       FROM flow.process_step_process_owning_position pspop
                                                inner join flow.process_step_process psp on psp.id = pspop.process_step_process_id
                                       WHERE psp.process_step_id = flow.process_step.id
                                         and pspop.archived is not true) owningPositions), '[]')                        as "Owning Positions",
                 coalesce((
                              SELECT array_to_json(array_agg(row_to_json(notes)))
                              FROM (
                                       select pn.id,
                                              pn.note,
                                              pn.archived,
                                              pn.parent_id as "parentId",
                                              pn.date_created as "dateCreated",
                                              pn.date_modified as "dateModified",
                                              pn.created_by_id as "createdById",
                                              pn.follow_up_date as "followUpDate",
                                              concat(creator.first_name, ' ', creator.last_name) as "createdBy",
                                              pn.modified_by_id as "modifiedById",
                                              pn.project_process_step_id as "projectProcessStepId",
                                              pn.process_step_work_queue_type_id as "processStepWorkQueueTypeId",
                                              coalesce((
                                                           SELECT array_to_json(array_agg(row_to_json(childNotes)))
                                                           FROM (
                                                                    select pn2.id,
                                                                           pn2.note,
                                                                           pn2.archived,
                                                                           pn2.date_created as "dateCreated",
                                                                           pn2.date_modified as "dateModified",
                                                                           pn2.created_by_id as "createdById",
                                                                           pn2.follow_up_date as "followUpDate",
                                                                           concat(creator2.first_name, ' ', creator2.last_name) as "createdBy",
                                                                           pn2.modified_by_id as "modifiedById",
                                                                           pn2.project_process_step_id as "projectProcessStepId",
                                                                           pn2.process_step_work_queue_type_id as "processStepWorkQueueTypeId"
                                                                    from flow.project_process_step_process_step_work_queue_type_note pn2
                                                                             inner join flow.user creator2 on creator2.id = pn2.created_by_id
                                                                    where pn2.archived is not true
                                                                      and pn2.parent_id = pn.id
                                                                    order by pn2.date_created
                                                                ) childNotes), '[]') AS "childNotes"
                                       from flow.project_process_step_process_step_work_queue_type_note pn
                                                inner join flow.user creator on creator.id = pn.created_by_id
                                       where pn.archived is not true
                                         and pn.parent_id is null
                                         and pn.project_process_step_id = flow.project_process_step.id
                                         and pn.process_step_work_queue_type_id = pswqt.id
                                       order by pn.date_created desc
                                   ) notes), '[]')                                                                       as "Notes",
          """
      );
    }

    if (List.of(1, 2, 4).contains(smartlist.getObjectTypeId().intValue()) && addProjectContactIdFields) {
      query.append(" flow.project.id as project_id, ");
      query.append(" flow.contact.id as contact_id, ");
    }

    for (SmartlistFieldAssignment f : fields) {

      if (f.getProcessStepId() != null) {

        // see if there is another field of this same process step. If so, use/set that same ppsTable. If not, set a new random ppsTable
        if (usedProcessStepIds.contains(f.getProcessStepId())) {
          SmartlistFieldAssignment sameProcessStepField = fields.stream().filter(field -> Objects.equals(f.getProcessStepId(), field.getProcessStepId())).findFirst().orElse(null);
          if (sameProcessStepField != null) {
            f.setPpsTable(sameProcessStepField.getPpsTable());
          } else {
            f.setPpsTable(UUID.randomUUID().toString());
          }
        } else {
          usedProcessStepIds.add(f.getProcessStepId());
          f.setPpsTable(UUID.randomUUID().toString());
        }
      }

      if (f.getSmartlistSystemListId() == null) {
        if (f.getCustomFieldGroupAssignmentId() != null && joinTables.stream().noneMatch(t -> t.getId().equals(f.getId()))) {
          // When the field is custom (has a cfgaId), reference table will be a UUID to keep track of that specific relationship/join
          f.setReferenceTable(UUID.randomUUID().toString());

          // If field is a system list, we need the int_value from the object value table to get the actual display value (name column) from the with clause
          if (f.getSystemListTypeId() != null || f.getAllowMultiple()) {
            f.setValueReferenceTable(UUID.randomUUID().toString());
          }
          joinTables.add(f);
        } else if (f.getCustomFieldGroupAssignmentId() == null && f.getProcessStepId() != null && smartlist.getObjectTypeId() != 4) {

          // When the field is system but has a process step ID, reference table will be a UUID to keep track of that specific relationship/join to the same process step
          if (Objects.equals(f.getReferenceTable(), "flow.user") || joinTables.stream().noneMatch(t -> t.getProcessStepId() != null && t.getProcessStepId().equals(f.getProcessStepId()))) {
            if (f.getJoinTable() != null && f.getJoinColumn() != null) {
              // System fields with joins will use this property (for now at least) instead of referenceTable
              f.setValueReferenceTable(UUID.randomUUID().toString());
            } else if (f.getReferenceTable() == null) {
              f.setReferenceTable(UUID.randomUUID().toString());
            }
            joinTables.add(f);
          } else {
            final String uuid = joinTables.stream()
                                          .filter(t -> t.getProcessStepId() != null && t.getProcessStepId().equals(f.getProcessStepId()))
                                          .map(t -> {
                                            if (Objects.equals(f.getReferenceTable(), "flow.user") || Objects.equals(f.getReferenceTable(), "flow.process_step") || Objects.equals(f.getReferenceTable(), "flow.project_process_step")) {
                                              return t.getPpsTable();
                                            } else {
                                              return t.getReferenceTable();
                                            }
                                          })
                                          .findFirst()
                                          .orElse(null);

            if (f.getReferenceTable().equals("flow.user") || Objects.equals(f.getReferenceTable(), "flow.process_step")) {
              f.setValueReferenceTable(uuid);
            } else {
              f.setReferenceTable(uuid);
            }
          }
        } else if (f.getJoinTable() != null && f.getJoinColumn() != null) {
          f.setValueReferenceTable(UUID.randomUUID().toString());
          joinTables.add(f);
        }
      } else {
        f.setValueReferenceTable(UUID.randomUUID().toString());
        joinTables.add(f);
      }

      String location = "";

      final String referenceTable = joinTables.stream()
                                              .filter(t -> t.getCustomFieldGroupAssignmentId() != null && t.getCustomFieldGroupAssignmentId().equals(f.getCustomFieldGroupAssignmentId()))
                                              .map(t -> {
                                                if (Objects.equals(f.getReferenceTable(), "flow.project_process_step")) {
                                                  return t.getPpsTable();
                                                } else if (t.getAllowMultiple()) {
                                                  return t.getValueReferenceTable();
                                                } else {
                                                  return t.getReferenceTable();
                                                }
                                              })
                                              .findFirst()
                                              .orElse(null);

      if (f.getSmartlistSystemListId() != null) {

        final String smartlistSystemListTable = "smartlistSystemList_" + f.getSmartlistSystemListId();

        if (List.of(1, 3, 5, 6, 7, 8, 9).contains(f.getSmartlistSystemListId().intValue())) {
          location = String.format("(select name from \"%s\" where \"%s\".id = %s.%s)", smartlistSystemListTable, smartlistSystemListTable, f.getJoinTable(), f.getJoinColumn());
        } else if (f.getSmartlistSystemListId() == 2 || f.getSmartlistSystemListId() == 4) {

          //          if (smartlist.getObjectTypeId() == 4) {
          //            location = String.format("(" +
          //              "select name " +
          //              "from \"%s\" " +
          //              "inner join flow.company_process_step_status_type cpsst on cpsst.id = flow.project_process_step.%s " +
          //              "where \"%s\".id = cpsst.process_step_status_type_id)", smartlistSystemListTable, f.getJoinColumn(), smartlistSystemListTable);
          //          } else {
          String ppsTable;

          try {
            ppsTable = joinTables.stream()
                                 .filter(t -> t.getProcessStepId() != null && f.getProcessStepId() != null && t.getProcessStepId().equals(f.getProcessStepId()))
                                 .map(t -> {
                                   if (t.getPpsTable() != null) {
                                     return t.getPpsTable();
                                   } else {
                                     return t.getValueReferenceTable();
                                   }
                                 })
                                 .findFirst()
                                 .orElse(null);

            if (ppsTable == null) {
              ppsTable = UUID.randomUUID().toString();
            }
          } catch (NullPointerException e) {
            ppsTable = UUID.randomUUID().toString();
          }

          if (f.getSmartlistSystemListId() == 2) {
            location = String.format("(" +
              "select name " +
              "from \"%s\" " +
              "inner join %s cpsst on cpsst.id = \"%s\".%s " +
              "where \"%s\".id = cpsst.id)", smartlistSystemListTable, f.getJoinTable(), ppsTable, f.getJoinColumn(), smartlistSystemListTable);
          } else {
            location = String.format("(" +
              "select name " +
              "from \"%s\" " +
              "inner join %s cpsst on cpsst.id = \"%s\".%s " +
              "where \"%s\".id = cpsst.process_step_status_type_id)", smartlistSystemListTable, f.getJoinTable(), ppsTable, f.getJoinColumn(), smartlistSystemListTable);
          }
        }
        //        }
      }
      // If field is custom, else it's system
      else if (f.getCustomFieldGroupAssignmentId() != null && referenceTable != null) {
        final String column = ((f.getHasListValues() != null && f.getHasListValues() && !f.getAllowMultiple()) || f.getCustomFieldSql() != null) ? "name" : getReferenceColumn(f.getDataTypeId());
        // if data type id == 2 and timezone is not null, then String.format("(\"%s\".%s at time zone \'%s\')", referenceTable, column, timezone)
        //        ppscfv.timestamp_value
        if (null != timezone && f.getDataTypeId() == 2) {
          //          (site_survey_verified_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
          location = String.format("((\"%s\".%s at time zone \'UTC\') at time zone \'%s\')", referenceTable, column, timezone);
          //          location = String.format("\"%s\".%s", referenceTable, column);
        } else {
          location = String.format("\"%s\".%s", referenceTable, column);
        }
      } else if (Objects.equals(f.getReferenceTable(), "flow.user") && f.getObjectTypeId() != 3 && f.getObjectTypeId() != 5) {
        location = (f.getObjectTypeId() != 4) ? f.getReferenceColumn() : String.format("concat(\"%s\".first_name, ' ', \"%s\".last_name)", f.getValueReferenceTable(), f.getValueReferenceTable());
      } else if (Objects.equals(f.getReferenceTable(), "flow.project_user") || Objects.equals(f.getReferenceTable(), "flow.contact_user")) {
        location = f.getReferenceColumn();
      } else {
        if (smartlist.getObjectTypeId() == 4) {
          if (null != timezone && f.getDataTypeId() == 2) {
            location = String.format("((%s.%s at time zone \'UTC\') at time zone \'%s\')", f.getReferenceTable(), f.getReferenceColumn(), timezone);
          } else {
            location = String.format("%s.%s", f.getReferenceTable(), f.getReferenceColumn());
          }
        } else {
          if (f.getCustomFieldGroupAssignmentId() != null || f.getProcessStepId() != null || (f.getJoinTable() != null && f.getJoinColumn() != null)) {
            String table;

            if (Objects.equals(f.getReferenceTable(), "flow.project_process_step")) {
              table = f.getPpsTable();
            } else {
              table = (f.getJoinTable() != null && f.getJoinColumn() != null) ? f.getValueReferenceTable() : f.getReferenceTable();
            }

            location = String.format("\"%s\".%s", table, f.getReferenceColumn());
          } else {
            location = String.format("%s.%s", f.getReferenceTable(), f.getReferenceColumn());
          }
        }
      }

      if (f.getName().contains("\"")) {
        f.setName(f.getName().replaceAll("\"",""));
      }

      if (Objects.equals(f.getReferenceTable(), "flow.process_step")) {
        if (smartlist.getObjectTypeId() == 4) {
          query.append(String.format("  (select %s from %s where %s.id = %s) as \"%s\", ", f.getReferenceColumn(), f.getReferenceTable(), f.getReferenceTable(), f.getProcessStepId(), f.getName()));
        } else {
          query.append(String.format("  (select %s from %s where %s.id = \"%s\".process_step_id) as \"%s\", ", f.getReferenceColumn(), f.getReferenceTable(), f.getReferenceTable(), f.getValueReferenceTable(), f.getName()));
        }
      } else if (f.getDataTypeId() == 1) {
        query.append(String.format("  to_char(%s, 'YYYY-MM-DD') as \"%s\", ", location, f.getName()));
      } else if (f.getDataTypeId() == 2) {
        query.append(String.format("  to_char(%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", location, f.getName()));
      } else if (f.getDataTypeId() == 7 && f.getSmartlistSystemListId() == null) {
        query.append(String.format("  (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(%s)), ',')) as \"%s\", ", location, f.getName()));
      } else if (f.getDataTypeId() == 9) {
        final long systemListNumber = (f.getSystemListId() == 1 || f.getSystemListId() == 2) ? 1 : f.getSystemListId();

        final String sql = String.format("  (select name from \"%s\" where \"%s\".id = \"%s\".int_value) as \"%s\", ", "systemList_" + systemListNumber, "systemList_" + systemListNumber, f.getValueReferenceTable(), f.getName());
        query.append(sql);
      } else {
        query.append(String.format("  %s as \"%s\", ", location, f.getName()));
      }

      if (f.getCustomFieldSql() != null && withClause.indexOf(f.getCustomFieldSqlKey()) == -1) {
        final String customSql = (f.getCustomFieldSqlSmartlist() != null) ? f.getCustomFieldSqlSmartlist() : f.getCustomFieldSql();
        withClause.append(String.format("  \"%s\" as  (%s), ", f.getCustomFieldSqlKey(), customSql));
      }
    }

    for (SmartlistRequirement r : requirements) {

      if (r.getProcessStepId() != null) {
        usedProcessStepIds.add(r.getProcessStepId());
      }

      // If this custom sql is not already in the "with" clause, add it
      if (r.getCustomFieldSql() != null && withClause.indexOf(r.getCustomFieldSqlKey()) == -1) {
        final String customSql = (r.getCustomFieldSqlSmartlist() != null) ? r.getCustomFieldSqlSmartlist() : r.getCustomFieldSql();
        withClause.append(String.format("  \"%s\" as  (%s), ", r.getCustomFieldSqlKey(), customSql));
      }
    }

    query.deleteCharAt(query.length() - 2);

    final String companySubquery = String.format("select id from flow.company where id = %s or parent_company_id = %s", companyId, companyId);

    if (null == smartlist.getWorkQueueTypeId()) {

      // @TODO: if active flag is false, maybe this should be a user status requirement though
      // assume mountain time for date comparisons
      LocalDateTime dateTimeNow = LocalDateTime.ofInstant(Instant.now(), ZoneId.of("UTC")).withMinute(0).withSecond(0).withNano(0);
      ZonedDateTime zonedNow = dateTimeNow.atZone(ZoneId.of("UTC")).withZoneSameInstant(ZoneId.of("America/Denver"));
      String now = zonedNow.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

      switch (smartlist.getObjectTypeId().intValue()) {
        case 1:
          query.append(" from flow.project ");
          query.append(" left join flow.user_position \"project_user_position\" on \"project_user_position\".id = flow.project.user_position_id ");
          query.append(" left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id ");
          query.append(" inner join flow.company_project_status_type on flow.company_project_status_type.id = flow.project.company_project_status_type_id ");
          query.append(" inner join flow.project_status_type on flow.project_status_type.id = flow.company_project_status_type.project_status_type_id ");
          query.append(" left join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true ");
          query.append(" left join flow.user_position \"contact_user_position\" on \"contact_user_position\".id = flow.contact.owner_user_position_id ");
          query.append(" left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id ");
          query.append(" left join flow.org on flow.org.id = \"project_user_position\".org_id ");

          whereClause.append(" flow.project.archived is not true and ");
          whereClause.append(String.format(" flow.company_project_status_type.company_id = any(%s) and ", companySubquery));
          break;
        case 2:
          query.append(" from flow.contact ");
          query.append(" left join flow.user_position \"contact_user_position\" on \"contact_user_position\".id = flow.contact.owner_user_position_id ");
          query.append(" left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id ");
          query.append(" left join flow.project on flow.project.contact_id = flow.contact.id ");
          query.append(" left join flow.company_project_status_type on flow.company_project_status_type.id = flow.project.company_project_status_type_id ");
          query.append(" left join flow.project_status_type on flow.project_status_type.id = flow.company_project_status_type.project_status_type_id ");
          query.append(" left join flow.user_position \"project_user_position\" on \"project_user_position\".id = flow.project.user_position_id ");
          query.append(" left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id ");
          query.append(" left join flow.org on flow.org.id = \"contact_user_position\".org_id ");

          whereClause.append(" flow.project.archived is not true and ");
          whereClause.append(String.format(" flow.contact.company_id = any(%s) and ", companySubquery));
          break;
        case 3:
          query.append(" from flow.user ");
          query.append(" inner join flow.user_position on flow.user_position.user_id = flow.user.id and flow.user_position.archived is not true ");
          query.append(" inner join flow.position on flow.position.id = flow.user_position.position_id and flow.position.archived is not true ");
          query.append(" inner join flow.company_user_status on flow.company_user_status.user_id = flow.user.id and flow.company_user_status.archived is not true ");
          query.append(" inner join flow.user_status_type on flow.user_status_type.id = flow.company_user_status.user_status_type_id and flow.user_status_type.archived is not true ");
          query.append(" inner join flow.org on flow.org.id = flow.user_position.org_id and flow.org.archived is not true ");
          query.append(" inner join flow.org_type on flow.org_type.id = flow.org.org_type_id and flow.org_type.archived is not true ");
          query.append(" inner join flow.org_level on flow.org_level.id = flow.org_type.org_level_id ");
          query.append(" inner join flow.user_position_hierarchy_vw on flow.user_position_hierarchy_vw.user_position_id = flow.user_position.id ");
          // TODO: Level = 5 for Region is BlueRaven specific, make generic at some point to support other companies
          query.append(" left join lateral jsonb_array_elements(user_position_hierarchy_vw.hierarchy) obj(val) ON obj.val->>'level' = '5' ");


          whereClause.append(" flow.user.archived is not true and ");
          whereClause.append(String.format(" flow.user_status_type.company_id = any(%s) and ", companySubquery));
          whereClause.append(String.format(" flow.position.company_id = any(%s) and ", companySubquery));
          whereClause.append(String.format(" flow.user_status_type.company_id = any(%s) and ", companySubquery));
          whereClause.append(String.format(" flow.org.company_id = any(%s) and ", companySubquery));

          if (smartlist.isPrimaryUserPosition()) {
            whereClause.append(" flow.user_position.primary_flag is true and ");
          }

          break;
        case 5:
          query.append(" from flow.org ");
          query.append(" inner join flow.org_type on flow.org_type.id = flow.org.org_type_id and flow.org_type.archived is not true ");
          query.append(" inner join flow.org_level on flow.org_level.id = flow.org_type.org_level_id ");

          whereClause.append(" flow.org.archived is not true and ");
          whereClause.append(String.format(" flow.org.company_id = any(%s) and ", companySubquery));

          final boolean anyUserField = fields.stream().anyMatch(f -> f.getObjectTypeId() == 3);
          final boolean anyUserRequirement = requirements.stream().anyMatch(r -> r.getObjectTypeId() == 3);

          if (anyUserField || anyUserRequirement) {
            query.append(" inner join flow.user_position on flow.user_position.org_id = flow.org.id and flow.user_position.archived is not true ");
            query.append(" inner join flow.user on flow.user.id = flow.user_position.user_id and flow.user.archived is not true ");
            query.append(" inner join flow.position on flow.position.id = flow.user_position.position_id and flow.position.archived is not true ");
            query.append(" inner join flow.company_user_status on flow.company_user_status.user_id = flow.user.id and flow.company_user_status.archived is not true ");
            query.append(" inner join flow.user_status_type on flow.user_status_type.id = flow.company_user_status.user_status_type_id and flow.user_status_type.archived is not true ");
            query.append(" inner join flow.user_position_hierarchy_vw on flow.user_position_hierarchy_vw.user_position_id = flow.user_position.id ");
            // TODO: Level = 5 for Region is BlueRaven specific, make generic at some point to support other companies
            query.append(" left join lateral jsonb_array_elements(user_position_hierarchy_vw.hierarchy) obj(val) ON obj.val->>'level' = '5' ");

            whereClause.append(String.format(" flow.user_status_type.company_id = any(%s) and ", companySubquery));
            whereClause.append(String.format(" flow.position.company_id = any(%s) and ", companySubquery));
            whereClause.append(String.format(" flow.user_status_type.company_id = any(%s) and ", companySubquery));

            if (smartlist.isPrimaryUserPosition()) {
              whereClause.append(" flow.user_position.primary_flag is true and ");
            }

          }

          break;
        case 6:
          query.append(" from flow.project_process_step_event");
          query.append(" left join flow.project_process_step on flow.project_process_step.id = flow.project_process_step_event.project_process_step_id ");
          query.append(" left join flow.project on flow.project.id = flow.project_process_step.project_id ");
          query.append(" left join flow.user_position \"project_user_position\" on \"project_user_position\".id = flow.project.user_position_id ");
          query.append(" left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id ");
          query.append(" inner join flow.company_project_status_type on flow.company_project_status_type.id = flow.project.company_project_status_type_id ");
          query.append(" inner join flow.project_status_type on flow.project_status_type.id = flow.company_project_status_type.project_status_type_id ");
          query.append(" left join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true ");
          query.append(" left join flow.user_position \"contact_user_position\" on \"contact_user_position\".id = flow.contact.owner_user_position_id ");
          query.append(" left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id ");
          query.append(" left join flow.org on flow.org.id = \"project_user_position\".org_id ");

          whereClause.append(" flow.project.archived is not true and ");
          whereClause.append(String.format(" flow.company_project_status_type.company_id = any(%s) and ", companySubquery));
          break;
      }
    } else {
      //this is all required for the work queue stuff
      query.append(
        "from flow.work_queue_cycle wqc\n" +
          "       inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst\n" +
          "                  on wqc.process_step_work_queue_type_process_step_status_type_id = pswqtpsst.id\n" +
          "       inner join flow.process_step_work_queue_type pswqt on pswqtpsst.process_step_work_queue_type_id = pswqt.id\n" +
          "       inner join flow.project_process_step on flow.project_process_step.id = wqc.project_process_step_id\n" +
          "       inner join flow.process_step on flow.process_step.id = flow.project_process_step.process_step_id\n" +
          "       inner join flow.project on flow.project.id = flow.project_process_step.project_id\n" +
          "       inner join flow.contact on flow.contact.id = flow.project.contact_id\n" +
          "       left join flow.user_position on flow.user_position.id = flow.contact.owner_user_position_id\n" +
          "       left join flow.user on flow.user.id = flow.user_position.user_id\n" +
          "       inner join flow.company_process cp on cp.id = flow.project.company_process_id\n" +
          "       inner join flow.company_project_status_type cpst on cpst.id = flow.project.company_project_status_type_id\n" +
          "       inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id\n" +
          "       inner join flow.company_process_step_status_type cpsst\n" +
          "                  on cpsst.id = flow.project_process_step.company_process_step_status_type_id\n" +
          "       left join flow.company_state cs on cs.id = flow.project.company_state_id\n" +
          "       left join flow.state st on st.id = cs.state_id\n" +
          "       left join flow.user_position up on up.id = flow.project_process_step.user_position_id\n" +
          "       left join flow.user u on u.id = up.user_id\n" +
          "       left join flow.user_position \"project_user_position\"\n" +
          "                 on \"project_user_position\".id = flow.project.user_position_id\n" +
          "       left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id\n" +
          "       left join flow.user_position \"contact_user_position\"\n" +
          "                 on \"contact_user_position\".id = flow.contact.owner_user_position_id\n" +
          "       left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id");
    }

    if (installationCrewIds != null && !installationCrewIds.isEmpty() && companyId == 3) {
      query.append("         inner join brs.project_details on brs.project_details.project_id = flow.project.id \n");
    }

    for (SmartlistFieldAssignment f : joinTables) {
      final String joinAlias = (f.getSystemListTypeId() != null || (f.getJoinTable() != null && f.getJoinColumn() != null) || Objects.equals(f.getAllowMultiple(), true)) ? f.getValueReferenceTable() : f.getReferenceTable();

      if (f.getSmartlistSystemListId() == null) {
        if (List.of(1, 2, 3, 5).contains(f.getObjectTypeId().intValue())) {

          String joinField = "";
          String joinedTable = "";

          if (f.getObjectTypeId() == 1 || f.getObjectTypeId() == 2) {
            joinField = (f.getObjectTypeId() == 1) ? "project_id" : "contact_id";
            joinedTable = (f.getObjectTypeId() == 1) ? "project" : "contact";
          } else if (f.getObjectTypeId() == 3) {
            joinField = "user_id";
            joinedTable = "user";
          } else if (f.getObjectTypeId() == 5) {
            joinField = "org_id";
            joinedTable = "org";
          }

          if ((f.getHasListValues() != null && f.getHasListValues()) || f.getCustomFieldSql() != null) {

            if (f.getValueReferenceTable() == null) {
              f.setValueReferenceTable(UUID.randomUUID().toString());
            }
            final String valueTable = f.getValueReferenceTable();

            query.append(String.format(" left join %s \"%s\" on \"%s\".%s = flow.%s.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), valueTable, valueTable, joinField, joinedTable, valueTable, f.getCustomFieldGroupAssignmentId()));

            if (f.getCustomFieldSql() != null) {
              //custom value sql
              query.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", f.getCustomFieldSqlKey(), joinAlias, joinAlias, valueTable));
            } else if (!f.getAllowMultiple()) {
              query.append(String.format(" left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", joinAlias, joinAlias, valueTable));
            }
          } else if (!Objects.equals(f.getReferenceTable(), "flow.project_user") && !Objects.equals(f.getReferenceTable(), "flow.contact_user")) {
            if (f.getJoinTable() != null && f.getJoinColumn() != null) {
              query.append(String.format(" left join %s \"%s\" on \"%s\".id = %s.%s", f.getReferenceTable(), joinAlias, joinAlias, f.getJoinTable(), f.getJoinColumn()));
            } else {
              query.append(String.format(" left join %s \"%s\" on \"%s\".%s = flow.%s.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), joinAlias, joinAlias, joinField, joinedTable, joinAlias, f.getCustomFieldGroupAssignmentId()));
            }
          }
        } else if (f.getObjectTypeId() == 4) {

          // If this is a system field
          if (f.getCustomFieldGroupAssignmentId() == null && f.getProcessStepId() != null) {
            if (f.getJoinTable() != null && f.getJoinColumn() != null) {

              // if this specific process step hasn't already been joined
              if (query.indexOf(String.format("left join %s \"%s\"", f.getJoinTable(), f.getPpsTable())) == -1) {
                query.append(String.format(" left join %s \"%s\" on \"%s\".process_step_id = %s and \"%s\".project_id = flow.project.id ", f.getJoinTable(), f.getPpsTable(), f.getPpsTable(), f.getProcessStepId(), f.getPpsTable()));
                if (smartlist.isMainProcessSteps()) {
                  query.append(String.format("and \"%s\".main is true ", f.getPpsTable()));
                }
              }

              if (f.getReferenceTable().equals("flow.user")) {
                // @TODO: This creates a duplicate join on project_process_step if the process step already being used in a previous field
                final String joinUserPosition = UUID.randomUUID().toString();
                query.append(String.format(" left join flow.user_position \"%s\" on \"%s\".id = \"%s\".%s ", joinUserPosition, joinUserPosition, f.getPpsTable(), f.getJoinColumn()));
                query.append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".user_id ", f.getReferenceTable(), joinAlias, joinAlias, joinUserPosition));
                f.setUserPositionTable(joinUserPosition);
              } else {
                query.append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".%s ", f.getReferenceTable(), joinAlias, joinAlias, f.getPpsTable(), f.getJoinColumn()));
              }
            } else if (query.indexOf(String.format("left join flow.project_process_step \"%s\"", f.getPpsTable())) == -1) { // if this specific process step hasn't already been joined
              query.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", f.getPpsTable(), f.getPpsTable(), f.getPpsTable(), f.getProcessStepId()));
              if (smartlist.isMainProcessSteps()) {
                query.append(String.format("and \"%s\".main is true ", f.getPpsTable()));
              }
            }
          } else {
            // if this specific process step hasn't already been joined
            if (query.indexOf(String.format("left join flow.project_process_step \"%s\"", f.getPpsTable())) == -1) {
              query.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", f.getPpsTable(), f.getPpsTable(), f.getPpsTable(), f.getProcessStepId()));
              if (smartlist.isMainProcessSteps()) {
                query.append(String.format("and \"%s\".main is true ", f.getPpsTable()));
              }
            }

            if (f.getHasListValues() != null && f.getHasListValues()) {
              if (f.getAllowMultiple()) {
                query.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), joinAlias, joinAlias, f.getPpsTable(), joinAlias, f.getCustomFieldGroupAssignmentId()));
              } else {
                final String ppscfvUUID = UUID.randomUUID().toString();
                f.setValueReferenceTable(ppscfvUUID);
                query.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), ppscfvUUID, ppscfvUUID, f.getPpsTable(), ppscfvUUID, f.getCustomFieldGroupAssignmentId()));
                query.append(String.format(" left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", joinAlias, joinAlias, ppscfvUUID));
              }
            } else {
              if (f.getCustomFieldSql() != null) {
                final String ppscfvUUID = UUID.randomUUID().toString();
                f.setValueReferenceTable(ppscfvUUID);
                query.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), ppscfvUUID, ppscfvUUID, f.getPpsTable(), ppscfvUUID, f.getCustomFieldGroupAssignmentId()));
                query.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", f.getCustomFieldSqlKey(), joinAlias, joinAlias, ppscfvUUID));
              } else {
                query.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), joinAlias, joinAlias, f.getPpsTable(), joinAlias, f.getCustomFieldGroupAssignmentId()));
              }
            }
          }
        }
      } else if (List.of(2L, 4L).contains(f.getSmartlistSystemListId())) {
        String joinTable;
        try {
          joinTable = joinTables.stream()
                                .filter(t -> t.getProcessStepId() != null && f.getProcessStepId() != null && t.getProcessStepId().equals(f.getProcessStepId()))
                                .map(t -> {
                                  if (t.getPpsTable() != null) {
                                    return t.getPpsTable();
                                  } else {
                                    return t.getValueReferenceTable();
                                  }
                                })
                                .findFirst()
                                .orElse(null);

          if (joinTable == null) {
            joinTable = UUID.randomUUID().toString();
          }
        } catch (NullPointerException e) {
          joinTable = UUID.randomUUID().toString();
        }

        if (query.indexOf("left join flow.project_process_step \"" + joinTable) == -1) {
          query.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", joinTable, joinTable, joinTable, f.getProcessStepId()));
          if (smartlist.isMainProcessSteps()) {
            query.append(String.format("and \"%s\".main is true ", joinTable));
          }
        }
      }
    }

    for (SmartlistRequirement r : requirements) {

      String referenceLocation = "";

      if (r.getSmartlistSystemListId() != null) {
        String referenceTable = "";
        final String smartlistSystemListTable = String.format("smartlist.systemlist.%s", r.getSmartlistSystemListId());

        if (List.of(1, 3, 5, 6, 7, 8, 9).contains(r.getSmartlistSystemListId().intValue())) {
          if (additionalJoins.indexOf(String.format("left join (select * from flow.get_smartlist_system_list_options(%s::bigint, %s", r.getSmartlistSystemListId(), r.getCompanyId())) == -1) {
            referenceTable = UUID.randomUUID().toString();
            final String subquery = String.format("select * from flow.get_smartlist_system_list_options(%s::bigint, %s::bigint)", r.getSmartlistSystemListId(), r.getCompanyId());
            additionalJoins.append(String.format(" left join (%s) \"%s\" on \"%s\".id = %s.%s ", subquery, referenceTable, referenceTable, r.getJoinTable(), r.getJoinColumn()));
          } else {
            referenceTable = requirements.stream()
                                         .filter(t -> Objects.equals(t.getSmartlistSystemListId(), r.getSmartlistSystemListId()))
                                         .map(SmartlistRequirement::getValueReferenceTable)
                                         .findFirst()
                                         .orElse(null);
          }
          r.setValueReferenceTable(referenceTable);
        } else if (r.getSmartlistSystemListId() == 2 || r.getSmartlistSystemListId() == 4) {
          String joinTable;
          try {
            joinTable = joinTables.stream()
                                  .filter(t -> t.getProcessStepId() != null && r.getProcessStepId() != null && t.getProcessStepId().equals(r.getProcessStepId()))
                                  .map(t -> {
                                    if (t.getPpsTable() != null) {
                                      return t.getPpsTable();
                                    } else {
                                      return t.getValueReferenceTable();
                                    }
                                  })
                                  .findFirst()
                                  .orElse(null);

            if (joinTable == null) {
              joinTable = UUID.randomUUID().toString();
            }
          } catch (NullPointerException e) {
            joinTable = UUID.randomUUID().toString();
          }

          if (additionalJoins.indexOf(joinTable) == -1 && query.indexOf(joinTable) == -1) {
            additionalJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", joinTable, joinTable, joinTable, r.getProcessStepId()));
            if (smartlist.isMainProcessSteps()) {
              additionalJoins.append(String.format("and \"%s\".main is true ", joinTable));
            }
          }

          referenceTable = UUID.randomUUID().toString();
          additionalJoins.append(String.format(" left join flow.company_process_step_status_type \"%s\" on \"%s\".id = \"%s\".company_process_step_status_type_id ", referenceTable, referenceTable, joinTable));

          if (r.getSmartlistSystemListId() == 4) {
            final String newReferenceTable = UUID.randomUUID().toString();
            additionalJoins.append(String.format(" left join flow.process_step_status_type \"%s\" on \"%s\".id = \"%s\".process_step_status_type_id ", newReferenceTable, newReferenceTable, referenceTable));
            referenceTable = newReferenceTable;
          }
        }
        referenceLocation = (r.getSmartlistFieldId() == 1) ? String.format("\"%s\".id", referenceTable) : String.format("array[\"%s\".id]::int[]", referenceTable);
      } else if (r.getCustomFieldGroupAssignmentId() != null) {

        String referenceColumn;
        if (r.getHasListValues() != null && r.getHasListValues() && !r.getAllowMultiple()) {
          referenceColumn = "int_value";
        } else if (r.getCustomFieldSql() != null) {
          referenceColumn = "id";
        } else {
          referenceColumn = getReferenceColumn(r.getDataTypeId());
        }

        // see if table we need is already been joined, if so use it
        final String referenceTable = joinTables.stream()
                                                .filter(t -> t.getCustomFieldGroupAssignmentId() != null && t.getCustomFieldGroupAssignmentId().equals(r.getCustomFieldGroupAssignmentId()))
                                                .map(t -> {
                                                  if (t.getValueReferenceTable() != null) {
                                                    return t.getValueReferenceTable();
                                                  } else {
                                                    return t.getReferenceTable();
                                                  }
                                                })
                                                .findFirst()
                                                .orElse(null);

        if (referenceTable != null) {
          referenceLocation = "\"" + referenceTable + "\"." + referenceColumn;
        } else {
          // Do a new join from custom field value table based on object type
          if (r.getObjectTypeId() == 4) {

            final String ppsUUID = UUID.randomUUID().toString();
            final String ppscfvUUID = UUID.randomUUID().toString();

            additionalJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, r.getProcessStepId()));
            if (smartlist.isMainProcessSteps()) {
              additionalJoins.append(String.format("and \"%s\".main is true ", ppsUUID));
            }

            if (r.getCustomFieldSql() != null) {
              final String customSqlUuid = UUID.randomUUID().toString();

              additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), customSqlUuid, customSqlUuid, ppsUUID, customSqlUuid, r.getCustomFieldGroupAssignmentId()));
              additionalJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", r.getCustomFieldSqlKey(), ppscfvUUID, ppscfvUUID, customSqlUuid));
            } else {
              additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, r.getCustomFieldGroupAssignmentId()));
            }

            referenceLocation = "\"" + ppscfvUUID + "\"." + referenceColumn;
          } else {
            final String valueUuid = UUID.randomUUID().toString();

            if (r.getCustomFieldSql() != null) {

              final String customSqlUuid = UUID.randomUUID().toString();

              if (r.getObjectTypeId() == 1) {
                additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, valueUuid, r.getCustomFieldGroupAssignmentId()));
              } else if (r.getObjectTypeId() == 2) {
                additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, valueUuid, r.getCustomFieldGroupAssignmentId()));
              } else if (r.getObjectTypeId() == 3) {
                additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".user_id = flow.user.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, valueUuid, r.getCustomFieldGroupAssignmentId()));
              } else if (r.getObjectTypeId() == 5) {
                additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".org_id = flow.org.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, valueUuid, r.getCustomFieldGroupAssignmentId()));
              }
              additionalJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", r.getCustomFieldSqlKey(), customSqlUuid, customSqlUuid, valueUuid));

              referenceLocation = "\"" + customSqlUuid + "\".id";
            } else {

              String joinField = "";
              String joinedTable = "";

              if (r.getObjectTypeId() == 1 || r.getObjectTypeId() == 2) {
                joinField = (r.getObjectTypeId() == 1) ? "project_id" : "contact_id";
                joinedTable = (r.getObjectTypeId() == 1) ? "project" : "contact";
              } else if (r.getObjectTypeId() == 3) {
                joinField = "user_id";
                joinedTable = "user";
              } else if (r.getObjectTypeId() == 5) {
                joinField = "org_id";
                joinedTable = "org";
              }

              query.append(String.format(" left join %s \"%s\" on \"%s\".%s = flow.%s.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, joinField, joinedTable, valueUuid, r.getCustomFieldGroupAssignmentId()));
              referenceLocation = "\"" + valueUuid + "\"." + referenceColumn;
            }
          }
        }
      } else {
        if (r.getJoinTable() != null && r.getJoinColumn() != null) {

          // see if table we need is already been joined, if so use it
          String referenceTable;
          try {
            referenceTable = joinTables.stream()
                                       .filter(t -> t.getProcessStepId() != null && t.getProcessStepId().equals(r.getProcessStepId()))
                                       .map(t -> {
                                         if (Objects.equals(t.getReferenceTable(), "flow.user")) {
                                           return (t.getObjectTypeId() == 4) ? t.getUserPositionTable() : "flow.user_position";
                                         } else {
                                           return t.getValueReferenceTable();
                                         }
                                       })
                                       .findFirst()
                                       .orElse(null);
          } catch (NullPointerException e) {
            referenceTable = null;
          }

          if (referenceTable != null) {
            referenceLocation = "\"" + referenceTable + "\".id";
          } else {
            if (r.getObjectTypeId() == 4 && r.getProcessStepId() != null) {
              final String joinUuid = UUID.randomUUID().toString();
              final String referenceUuid = UUID.randomUUID().toString();

              additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".process_step_id = %s and \"%s\".project_id = flow.project.id ", r.getJoinTable(), joinUuid, joinUuid, r.getProcessStepId(), joinUuid));

              if (Objects.equals(r.getReferenceTable(), "flow.user")) {
                additionalJoins.append(String.format(" left join flow.user_position \"%s\" on \"%s\".id = \"%s\".%s ", referenceUuid, referenceUuid, joinUuid, r.getJoinColumn()));
              } else {
                additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".%s ", r.getReferenceTable(), referenceUuid, referenceUuid, joinUuid, r.getJoinColumn()));
              }

              referenceLocation = String.format("\"%s\".id", referenceUuid);
            } else {
              if (Objects.equals(r.getReferenceTable(), "flow.user")) {
                referenceLocation = "flow.user_position.id";
              } else if (Objects.equals(r.getReferenceTable(), "flow.project_user")) {
                referenceLocation = "\"project_user_position\".id";
              } else if (Objects.equals(r.getReferenceTable(), "flow.contact_user")) {
                referenceLocation = "\"contact_user_position\".id";
              } else {
                // see if table we need is already been joined, if so use it
                final String table = joinTables.stream()
                                               .filter(t -> (t.getJoinTable() != null && t.getJoinColumn() != null) && t.getJoinTable().equals(r.getJoinTable()) && t.getJoinColumn().equals(r.getJoinColumn()))
                                               .map(SmartlistFieldAssignment::getValueReferenceTable)
                                               .findFirst()
                                               .orElse(null);

                if (table != null) {
                  referenceLocation = "\"" + table + "\".id";
                } else {
                  final String referenceUuid = UUID.randomUUID().toString();
                  additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".id = %s.%s", r.getReferenceTable(), referenceUuid, referenceUuid, r.getJoinTable(), r.getJoinColumn()));
                  referenceLocation = String.format("\"%s\".id", referenceUuid);
                }
              }
            }
          }
        } else {
          if (List.of(1, 2, 3, 5).contains(r.getObjectTypeId().intValue())) {
            referenceLocation = r.getReferenceTable() + "." + r.getReferenceColumn();
          } else if (r.getObjectTypeId() == 4) {
            String joinTable = null;
            try {
              joinTable = joinTables.stream()
                                    .filter(t -> t.getProcessStepId() != null && r.getProcessStepId() != null && t.getProcessStepId().equals(r.getProcessStepId()))
                                    .map(t -> {
                                      if (Objects.equals(r.getReferenceTable(), "flow.project_process_step")) {
                                        return t.getPpsTable();
                                      } else {
                                        return t.getReferenceTable();
                                      }
                                    })
                                    .findFirst()
                                    .orElse(null);

            } catch (NullPointerException e) {
              // noop
            }
            if (joinTable == null) {
              joinTable = UUID.randomUUID().toString();
              additionalJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", joinTable, joinTable, joinTable, r.getProcessStepId()));
              if (smartlist.isMainProcessSteps()) {
                additionalJoins.append(String.format("and \"%s\".main is true ", joinTable));
              }
            }

            referenceLocation = String.format("\"%s\".%s", joinTable, r.getReferenceColumn());
          }
        }
      }

      Object requirementValue = getRequirementValue(r);
      String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId(), r.getDataTypeRequirement());

      //Check for double negative with "nots" between operator and requirement
      if (r.getDataTypeRequirementId() != null) {
        if (requirementValue != null && requirementValue.toString().contains("not") && operator != null && operator.contains("not")) {
          operator = operator.replace("not", "");

          if (List.of(5L, 13L, 17L, 19L, 21L, 25L, 27L).contains(r.getDataTypeRequirementId())) {
            requirementValue = requirementValue.toString().replace("not", "");
          }
        }
      }

      if (r.getDataTypeId() == 7) {
        if (r.getDataTypeRequirementId() != null) {
          whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          whereClause.append(String.format(" sort(%s) %s sort(array%s::int[]) and ", referenceLocation, operator, requirementValue));
        }
      } else if (r.getDataTypeId() == 3 || r.getDataTypeId() == 4 || (r.getDataTypeRequirementId() != null && r.getSecondaryRequirementValue() == null && r.getDataTypeId() != 1 && r.getDataTypeId() != 2)) {
        //if this is a text requirement using null/not null requirement
        if ((r.getDataTypeId() == 5 || r.getDataTypeId() == 13) && r.getDataTypeRequirementId() != null  && requirementValue != null) {
          //treat empty strings as null
          whereClause.append(String.format(" nullif(trim(%s::text), '') %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        }
      } else {
        if (requirementValue instanceof String && requirementValue.toString().contains("null")) {
          whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          if (r.getDataTypeRequirementId() != null && List.of(1L, 2L, 3L, 6L, 7L, 8L).contains(r.getDataTypeRequirementId())) {
            whereClause.append(String.format(" date_trunc('day', %s) %s date_trunc('day', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
          } else if (r.getDataTypeRequirementId() != null && List.of(9L, 10L, 11L).contains(r.getDataTypeRequirementId())) {
            whereClause.append(String.format(" date_trunc('hour', %s) %s date_trunc('hour', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
          } else {
            if (r.getSmartlistSystemListId() != null) {
              whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
            } else {
              // If this field is process step owner,
              // OR if this field is project owner,
              // OR if this field is contact owner,
              // make sure we're getting past instances where this user had the same position and not just the current primary position
              if ((r.getObjectTypeId() == 4 && Objects.equals(r.getReferenceTable(), "flow.user")) || (r.getObjectTypeId() == 1 && Objects.equals(r.getReferenceTable(), "flow.project_user")) || (r.getObjectTypeId() == 2 && Objects.equals(r.getReferenceTable(), "flow.contact_user"))) {
                final String positionSubquery = String.format("select id from flow.user_position where user_id = (select user_id from flow.user_position where id = %s)", requirementValue);
                whereClause.append(String.format(" %s = any(%s) and ", referenceLocation, positionSubquery));
              } else {
                if (requirementValue == null) {
                  whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
                }
                else {
                  whereClause.append(String.format(" %s %s '%s' and ", referenceLocation, operator, requirementValue));
                }
              }
            }
          }
        }
      }
    }

    if (smartlist.isMainProcessSteps() && smartlist.getObjectTypeId() == 4) {
      whereClause.append(" flow.project_process_step.main is true and ");
    }

    if (installationCrewIds != null && !installationCrewIds.isEmpty() && companyId == 3) {
      whereClause.append(String.format(" brs.project_details.installation_resource in (%s) and ", installationCrewIds.toString().replace("[", "").replace("]", "")));
    }

    if (null != smartlist.getWorkQueueTypeId()) {
      //we no longer show only main pps in work queues...removed that line
      whereClause.append(" wqc.date_entered_queue is not null and wqc.date_exited_queue is null \n" +
        "  and pswqt.work_queue_type_id = " + smartlist.getWorkQueueTypeId() + "\n" +
        "  and pswqt.archived is not true\n" +
        "  and flow.project_process_step.archived is not true\n" +
        "  and flow.project.archived is not true\n" +
        "      and flow.process_step.company_id = any\n" +
        "                        (select id from flow.company_hierarchy_filter_down(" + companyId + ")) and ");
    }

    if (withClause.length() > 0) {
      // Remove comma and space from last with table
      withClause.deleteCharAt(withClause.length() - 1);
      withClause.deleteCharAt(withClause.length() - 1);

      query.insert(0, "with " + withClause.toString());
    }

    query.append(additionalJoins.toString());

    if (whereClause.length() > 0) {
      query.append("  where ").append(whereClause.toString());

      // remove the last "and "
      query = query.delete(query.length() - 5, query.length());
    }

    if (null != smartlist.getWorkQueueTypeId()) {
      query.append(" order by \"Days In Queue\" desc ");
    }

    if (limit != null) {
      query.append(String.format(" limit %s", limit));
    }

    query.append(";");

    return query.toString();
  }

  public String buildWorkQueueSql(Smartlist smartlist, List<SmartlistFieldAssignment> fields, Boolean useEventData, String timezone) {

    final Long companyId = securityService.getCurrentUser().getCompanyId();

    //start of overall query
    var query = new StringBuilder();

    //add "from" clause and initial joins
    query.append(addFromClause((useEventData) ? 6L : smartlist.getObjectTypeId(), null, smartlist.getWorkQueueTypeId()));

    final List<Long> pseRequirementIds = smartlist.getEventWorkQueueTypes().stream()
                                                  .map(ProcessStepEventWorkQueueType::getProcessStepEventId)
                                                  .toList();

    //join value tables for every field
    for (SmartlistFieldAssignment f : fields) {
      //set all table aliases up front
      f.setValueReferenceTable(UUID.randomUUID().toString());
      f.setPpsTable(UUID.randomUUID().toString());
      f.setPpsEventTable(UUID.randomUUID().toString());
      f.setUserPositionTable(UUID.randomUUID().toString());

      //join value tables for every custom field, so the latter logic is able to assume everything is joined
      //if the field is a custom field
      if (f.getCustomFieldGroupAssignmentId() != null) {
        if (f.getObjectTypeId() == 1) {
          query.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueReferenceTable(), "flow.project", true));
        } else if (f.getObjectTypeId() == 2) {
          query.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueReferenceTable(), "flow.contact", true));
        } else if (f.getObjectTypeId() == 4) {
          if (query.indexOf(".process_step_id = " + f.getProcessStepId()) != -1) {
            // if the PS is already joined, use it
            final String ppsTable = fields.stream()
                                          .filter(field -> Objects.equals(field.getProcessStepId(), f.getProcessStepId()))
                                          .map(SmartlistFieldAssignment::getPpsTable)
                                          .findFirst()
                                          .orElse(null);
            f.setPpsTable(ppsTable);
          } else {
            //join pps table
            query.append(joinPpsTable(f.getPpsTable(), f.getProcessStepId(), smartlist.isMainProcessSteps()));
          }

          //join pps value table
          query.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueReferenceTable(), f.getPpsTable(), true));
        } else if (f.getObjectTypeId() == 6) {
          //check if process step is already joined
          if (query.indexOf(".process_step_id = " + f.getProcessStepId()) != -1) {
            //if the PS is already joined, use it
            final String ppsTable = fields.stream()
                                          .filter(field -> Objects.equals(field.getProcessStepId(), f.getProcessStepId()))
                                          .map(SmartlistFieldAssignment::getPpsTable)
                                          .findFirst()
                                          .orElse(null);
            f.setPpsTable(ppsTable);

            //check if event is already joined
            if (query.indexOf(".process_step_event_id = " + f.getEventId()) != -1) {
              //grab event table
              final String ppsEventTable = fields.stream()
                                                 .filter(field -> Objects.equals(field.getEventId(), f.getEventId()))
                                                 .map(SmartlistFieldAssignment::getPpsEventTable)
                                                 .findFirst()
                                                 .orElse(null);
              f.setPpsEventTable(ppsEventTable);
            } else {
              query.append(joinPPsEventTable(f.getPpsEventTable(), f.getPpsTable(), f.getProcessStepEventId(), true));
            }
          } else {
            //join pps and ppse tables
            query.append(joinPpsTable(f.getPpsTable(), f.getProcessStepId(), smartlist.isMainProcessSteps()));
            query.append(joinPPsEventTable(f.getPpsEventTable(), f.getPpsTable(), f.getProcessStepEventId(), true));
          }

          //join pps event value table
          query.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueReferenceTable(), f.getPpsEventTable(), true));
        }
      }

      //if field is a smartlist system list field
      if (f.getSmartlistSystemListId() != null) {

        //if field is process step status or category
        if (f.getSmartlistSystemListId() == 2 || f.getSmartlistSystemListId() == 4) {

          //check if process step is already joined
          if (query.indexOf(".process_step_id = " + f.getProcessStepId()) != -1) {
            //if the PS is already joined, use it
            final String ppsTable = fields.stream()
                                          .filter(field -> Objects.equals(field.getProcessStepId(), f.getProcessStepId()))
                                          .map(SmartlistFieldAssignment::getPpsTable)
                                          .findFirst()
                                          .orElse(null);
            f.setPpsTable(ppsTable);
          } else {
            query.append(joinPpsTable(f.getPpsTable(), f.getProcessStepId(), smartlist.isMainProcessSteps()));
          }

          if (Objects.equals(f.getReferenceTable(), "flow.company_process_step_status_type")) { //else if field is process step status
            query.append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".%s ", f.getReferenceTable(), f.getValueReferenceTable(), f.getValueReferenceTable(), f.getPpsTable(), f.getJoinColumn()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.process_step_status_type")) { //else if field is process step category (root status)
            final String companyStatusTable = UUID.randomUUID().toString();
            //@TODO: The hardcoded "process_step_status_type_id" should come from the smartlist_field table, but isn't working here with the existing setup. Revisit
            query.append(String.format(" left join flow.company_process_step_status_type \"%s\" on \"%s\".id = \"%s\".company_process_step_status_type_id ", companyStatusTable, companyStatusTable, f.getPpsTable()))
                 .append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".%s ", f.getReferenceTable(), f.getValueReferenceTable(), f.getValueReferenceTable(), companyStatusTable, "process_step_status_type_id"));
          }
        }
      } else if (f.getSmartlistFieldId() != null) { //else if field is smartlist system field
        if (f.getObjectTypeId() == 4) {

          //check if process step is already joined
          if (query.indexOf(".process_step_id = " + f.getProcessStepId()) != -1) {
            //if the PS is already joined, use it
            final String ppsTable = fields.stream()
                                          .filter(field -> Objects.equals(field.getProcessStepId(), f.getProcessStepId()))
                                          .map(SmartlistFieldAssignment::getPpsTable)
                                          .findFirst()
                                          .orElse(null);
            f.setPpsTable(ppsTable);
          } else {
            query.append(joinPpsTable(f.getPpsTable(), f.getProcessStepId(), smartlist.isMainProcessSteps()));
          }

          //if field is the process step name
          if (Objects.equals(f.getReferenceTable(), "flow.process_step")) {
            query.append(String.format(" left join flow.process_step \"%s\" on \"%s\".id = \"%s\".process_step_id", f.getValueReferenceTable(), f.getValueReferenceTable(), f.getPpsTable()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.user")) { //else if field is PS owner

            final String newValueTable = UUID.randomUUID().toString();
            query.append(String.format(" left join \"systemList_1\" \"%s\" on \"%s\".id = \"%s\".%s", newValueTable, newValueTable, f.getPpsTable(), f.getJoinColumn()));
            f.setValueReferenceTable(newValueTable);
          }
        } else if (f.getObjectTypeId() == 6) {

          //if event is already a row in the queue
          if (pseRequirementIds.contains(f.getProcessStepEventId())) {
            //use the base tables
            f.setPpsEventTable("flow.project_process_step_event");
            f.setPpsTable("flow.project_process_step");
          } else {
            //check if process step is already joined
            if (query.indexOf(".process_step_id = " + f.getProcessStepId()) != -1) {
              //if the PS is already joined, use it
              final String ppsTable = fields.stream()
                                            .filter(field -> Objects.equals(field.getProcessStepId(), f.getProcessStepId()))
                                            .map(SmartlistFieldAssignment::getPpsTable)
                                            .findFirst()
                                            .orElse(null);
              f.setPpsTable(ppsTable);

              //check if event is already joined
              if (query.indexOf(".process_step_event_id = " + f.getEventId()) != -1) {
                // grab event table
                final String ppsEventTable = fields.stream()
                                                   .filter(field -> Objects.equals(field.getEventId(), f.getEventId()))
                                                   .map(SmartlistFieldAssignment::getPpsEventTable)
                                                   .findFirst()
                                                   .orElse(null);
                f.setPpsEventTable(ppsEventTable);
              } else {
                query.append(joinPPsEventTable(f.getPpsEventTable(), f.getPpsTable(), f.getProcessStepEventId(), true));
              }
            } else {
              //join pps and ppse tables
              query.append(joinPpsTable(f.getPpsTable(), f.getProcessStepId(), smartlist.isMainProcessSteps()));
              query.append(joinPPsEventTable(f.getPpsEventTable(), f.getPpsTable(), f.getProcessStepEventId(), true));
            }
          }

          //if field is event name system field
          if (Objects.equals(f.getReferenceTable(), "flow.event")) {
            final String pseTable = UUID.randomUUID().toString();

            //join on process step event and event table
            query.append(String.format(" left join flow.process_step_event \"%s\" on \"%s\".id = \"%s\".process_step_event_id ", pseTable, pseTable, f.getPpsEventTable()));
            query.append(String.format(" left join flow.event \"%s\" on \"%s\".id = \"%s\".event_id ", f.getValueReferenceTable(), f.getValueReferenceTable(), pseTable));
          } else if (Objects.equals(f.getReferenceTable(), "flow.company_event_status_type")) { //else if field is event status
            query.append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".%s ", f.getReferenceTable(), f.getValueReferenceTable(), f.getValueReferenceTable(), f.getPpsEventTable(), f.getJoinColumn()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.event_status_type")) { //else if field is event category (root status)
            final String companyStatusTable = UUID.randomUUID().toString();
            query.append(String.format(" left join flow.company_event_status_type \"%s\" on \"%s\".id = \"%s\".company_event_status_type_id ", companyStatusTable, companyStatusTable, f.getPpsEventTable()))
                 .append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".%s ", f.getReferenceTable(), f.getValueReferenceTable(), f.getValueReferenceTable(), companyStatusTable, f.getJoinColumn()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.org")) { //else if field is event resource

            final String newValueTable = UUID.randomUUID().toString();
            final long systemListNumber = (f.getEventResourceSystemListId() == 1 || f.getEventResourceSystemListId() == 2) ? 1 : f.getEventResourceSystemListId();
            final List<Long> processStepEventIds = smartlist.getEventWorkQueueTypes().stream()
                                                            .map(ProcessStepEventWorkQueueType::getProcessStepEventId)
                                                            .toList();
            if (processStepEventIds.contains(f.getProcessStepEventId())) {
              query.append(String.format(" left join \"systemList_%s\" \"%s\" on \"%s\".id = flow.project_process_step_event.%s", systemListNumber, newValueTable, newValueTable, f.getJoinColumn()));
            } else {
              query.append(String.format(" left join \"systemList_%s\" \"%s\" on \"%s\".id = \"%s\".%s", systemListNumber, newValueTable, newValueTable, f.getPpsEventTable(), f.getJoinColumn()));
            }
            f.setValueReferenceTable(newValueTable);
          }
        }
      } else {//else field is custom

        final String currentValueTable = f.getValueReferenceTable();
        final String newValueTable = UUID.randomUUID().toString();

        //if field is a custom field w/sql query
        if (f.getCustomFieldSql() != null) {

          query.append(String.format(" left join \"%s\" \"%s\" on \"%s\" .id = \"%s\".int_value", f.getCustomFieldSqlKey(), newValueTable, newValueTable, currentValueTable));
          f.setValueReferenceTable(newValueTable);
        } else if (f.getCompanySystemListId() != null) { //else if custom field is system list

          final long systemListNumber = (f.getSystemListId() == 1 || f.getSystemListId() == 2) ? 1 : f.getSystemListId();
          final String systemListTable = "systemList_" + systemListNumber;
          //@TODO: Currently, we don't check if the system list is already joined on this cfgaId. We could do that to eliminate potential duplicates between fields/columns and requirements
          query.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".%s", systemListTable, newValueTable, newValueTable, currentValueTable, getReferenceColumn(f.getDataTypeId())));
          f.setValueReferenceTable(newValueTable);
        }
      }
    }

    //build the "where" clause
    query.append(" where ")

         //omit archived items
         .append("flow.project.archived is not true and ")
         .append("flow.project_process_step.archived is not true and ")
         .append("flow.project_process_step_event.archived is not true");

    //do work queue cycle filters if a work queue smartlist
    if(null != smartlist.getWorkQueueTypeId()) {
      query.append(" and wqc.date_entered_queue is not null and ")
           .append("wqc.date_exited_queue is null ");
    }

    //apply statuses/categories for any attached work queue types
    if (!smartlist.getEventWorkQueueTypes().isEmpty()) {
      query.append(" and (");

      for (ProcessStepEventWorkQueueType wqt : smartlist.getEventWorkQueueTypes()) {
        query.append(String.format("(flow.process_step_event.id = %s and ", wqt.getProcessStepEventId()));

        //extract project categories/statuses
        List<Long> projectStatuses = wqt.getProjectStatuses().stream()
                                        .filter(s -> !s.getIsRoot())
                                        .map(WorkQueueTypeProjectStatus::getCompanyProjectStatusTypeId)
                                        .toList();

        List<Long> projectCategories = wqt.getProjectStatuses().stream()
                                          .filter(WorkQueueTypeProjectStatus::getIsRoot)
                                          .map(WorkQueueTypeProjectStatus::getProjectStatusTypeId)
                                          .toList();

        //extract process step categories/statuses
        List<Long> psStatuses = wqt.getProcessStepStatuses().stream()
                                   .filter(s -> !s.getIsRoot())
                                   .map(WorkQueueTypeProcessStepStatus::getCompanyProcessStepStatusTypeId)
                                   .toList();

        List<Long> psCategories = wqt.getProcessStepStatuses().stream()
                                     .filter(WorkQueueTypeProcessStepStatus::getIsRoot)
                                     .map(WorkQueueTypeProcessStepStatus::getProcessStepStatusTypeId)
                                     .toList();

        List<Long> eventStatuses = wqt.getEventStatuses().stream()
                                      .filter(s -> !s.getIsRoot())
                                      .map(WorkQueueTypeEventStatus::getCompanyEventStatusTypeId)
                                      .toList();

        List<Long> eventCategories = wqt.getEventStatuses().stream()
                                        .filter(WorkQueueTypeEventStatus::getIsRoot)
                                        .map(WorkQueueTypeEventStatus::getEventStatusTypeId)
                                        .toList();

        query.append("(")
             .append(String.format("flow.company_project_status_type.id = any(array%s::bigint[]) or ", projectStatuses))
             .append(String.format("flow.project_status_type.id = any(array%s::bigint[])", projectCategories))
             .append(")")

             .append(" and (")
             .append(String.format("flow.company_process_step_status_type.id = any(array%s::bigint[]) or ", psStatuses))
             .append(String.format("flow.process_step_status_type.id = any(array%s::bigint[])", psCategories))
             .append(")")

             .append(" and (")
             .append(String.format("flow.company_event_status_type.id = any(array%s::bigint[]) or ", eventStatuses))
             .append(String.format("flow.event_status_type.id = any(array%s::bigint[])", eventCategories))
             .append(")) or ");
      }

      //remove the last "or "
      query.delete(query.length() - 3, query.length());

      query.append(")");
    }

    //every table with a value we need is now joined
    //build the "select" clause from smartlist fields
    var selectQuery = new StringBuilder();

    for (SmartlistFieldAssignment f : fields) {
      //if field is smartlist system list
      if (f.getSmartlistSystemListId() != null) {
        final String smartlistSystemListTable = "smartlistSystemList_" + f.getSmartlistSystemListId();

        if (List.of(1L, 3L, 5L).contains(f.getSmartlistSystemListId())) {
          selectQuery.append(String.format("(select name from \"%s\" where \"%s\".id = %s.%s) as \"%s\", ", smartlistSystemListTable, smartlistSystemListTable, f.getJoinTable(), f.getJoinColumn(), f.getName()));
        } else if (List.of(2L, 4L).contains(f.getSmartlistSystemListId())) {
          selectQuery.append(String.format("\"%s\".%s as \"%s\", ", f.getValueReferenceTable(), f.getReferenceColumn(), f.getName()));
        }
      } else if (f.getProcessStepId() != null) { //if field is process step or event

        //if field is system list, PS owner, or event resource
        if (f.getSystemListId() != null || Objects.equals(f.getReferenceTable(), "flow.user") || Objects.equals(f.getReferenceTable(), "flow.org")) {
          selectQuery.append(String.format("\"%s\".name as \"%s\", ", f.getValueReferenceTable(), f.getName()));
        } else if (Objects.equals(f.getReferenceTable(), "flow.project_process_step") ||
          Objects.equals(f.getReferenceTable(), "flow.process_step") ||
          Objects.equals(f.getReferenceTable(), "flow.project_process_step_event") ||
          Objects.equals(f.getReferenceTable(), "flow.event") ||
          Objects.equals(f.getReferenceTable(), "flow.company_event_status_type") ||
          Objects.equals(f.getReferenceTable(), "flow.event_status_type")) {//else if field is process step or event system field
          if (f.getDataTypeId() == 1) {
            selectQuery.append(String.format(" to_char(%s.%s, 'YYYY-MM-DD') as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getName()));
          } else if (f.getDataTypeId() == 2) {
            if (timezone != null) {
              selectQuery.append(String.format(" to_char(%s.%s at time zone 'UTC' at time zone '%s', 'MM/DD/YYYY HH:MI am') as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), timezone, f.getName()));
            } else {
              selectQuery.append(String.format(" to_char(%s.%s, 'MM/DD/YYYY HH:MI am') as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getName()));
            }
          } else if (f.getDataTypeId() == 6 && Objects.equals(f.getHasListValues(), true)) {
            selectQuery.append(String.format(" (select name from flow.list_of_value where id = %s.%s) as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getName()));
          } else if (f.getDataTypeId() == 7) {
            selectQuery.append(String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(%s.%s)), ',')) as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getName()));
          } else {
            selectQuery.append(String.format(" %s.%s as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getName()));
          }
        } else {//else field is process step or event custom field
          selectQuery.append(addSelectCustomField(f.getDataTypeId(), f.getValueReferenceTable(), f.getName(), f.getHasListValues(), timezone));
        }
      } else if (f.getSystemListId() != null) {//else if field is system list
        selectQuery.append(String.format("\"%s\".name as \"%s\", ", f.getValueReferenceTable(), f.getName()));
      } else {
        //if field is custom sql
        if (f.getCustomFieldSql() != null) {
          selectQuery.append(String.format("\"%s\".name as \"%s\", ", f.getValueReferenceTable(), f.getName()));
        } else { //else field is project or contact

          //if field is system
          if (f.getCustomFieldGroupAssignmentId() != null) {
            if (f.getDataTypeId() == 1) {
              selectQuery.append(String.format(" to_char(\"%s\".%s, 'YYYY-MM-DD') as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getName()));
            } else if (f.getDataTypeId() == 2) {
              if (timezone != null) {
                selectQuery.append(String.format(" to_char(\"%s\".%s at time zone 'UTC' at time zone '%s', 'MM/DD/YYYY HH:MI am') as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), timezone, f.getName()));
              } else {
                selectQuery.append(String.format(" to_char(\"%s\".%s, 'MM/DD/YYYY HH:MI am') as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getName()));
              }
            } else if (f.getDataTypeId() == 6 && f.getHasListValues()) {
              selectQuery.append(String.format(" (select name from flow.list_of_value where id = \"%s\".%s) as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getName()));
            } else if (f.getDataTypeId() == 7) {
              selectQuery.append(String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(\"%s\".%s)), ',')) as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getName()));
            } else {
              selectQuery.append(String.format(" \"%s\".%s as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getName()));
            }
          } else {
            if (Objects.equals(f.getReferenceTable(), "flow.project_user") || Objects.equals(f.getReferenceTable(), "flow.contact_user")) {
              selectQuery.append(String.format("%s as \"%s\", ", f.getReferenceColumn(), f.getName()));
            } else {
              selectQuery.append(String.format("%s.%s as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getName()));
            }
          }
        }
      }
    }

    if (!fields.isEmpty()) {
      //remove the extra ", "
      selectQuery.delete(selectQuery.length() - 2, selectQuery.length());
    }

    //build the "with" and "select" clause from default fields
    var defaultFields = new StringBuilder().append("with ")

                                           // Get smartlist system lists
                                           .append(String.format("\"smartlistSystemList_1\" as (select * from flow.get_smartlist_system_list_options(1::bigint, %s::bigint)), ", companyId))
                                           .append(String.format("\"smartlistSystemList_2\" as (select * from flow.get_smartlist_system_list_options(2::bigint, %s::bigint)), ", companyId))
                                           .append(String.format("\"smartlistSystemList_3\" as (select * from flow.get_smartlist_system_list_options(3::bigint, %s::bigint)), ", companyId))
                                           .append(String.format("\"smartlistSystemList_4\" as (select * from flow.get_smartlist_system_list_options(4::bigint, %s::bigint)), ", companyId))
                                           .append(String.format("\"smartlistSystemList_5\" as (select * from flow.get_smartlist_system_list_options(5::bigint, %s::bigint)), ", companyId))

                                           // Get tables for system lists
                                           .append("\"systemList_1\" as (select up.id, concat(u.first_name, ' ', u.last_name::text) as name from flow.user_position up inner join flow.user u on u.id = up.user_id), ")
                                           .append("\"systemList_3\" as (select id, org_name::text as name from flow.org), ")
                                           .append("\"systemList_4\" as (select id, concat(first_name, ' ', last_name::text) as name from flow.user), ");


    //add custom sql value tables
    for (SmartlistFieldAssignment f : fields) {
      if (f.getCustomFieldSql() != null && selectQuery.indexOf(f.getCustomFieldSqlKey()) == -1) {
        defaultFields.append(String.format("\"%s\" as (%s), ", f.getCustomFieldSqlKey(), f.getCustomFieldSql()));
      }
    }

    //remove the extra ", "
    defaultFields.delete(defaultFields.length() - 2, defaultFields.length());

    //default fields
    if (useEventData) {
      //event fields
      defaultFields.append(" select ")
                   .append("flow.project.project_name as \"Project Name\", ")
                   .append("flow.event.event_name \"Event Name\", ")
                   .append("flow.project_process_step.id \"projectProcessStepId\", ")
                   .append("flow.project.id as \"projectId\", ")
                   .append("flow.project_process_step_event.id \"projectProcessStepEventId\", ")
                   .append("flow.company_event_status_type.event_status_type as \"Event Status\", ")
                   .append("flow.process_step.process_step_name as \"Process Step Name\", ")
                   .append("flow.company_process_step_status_type.process_step_status_type as \"Process Step Status\", ")
                   .append("coalesce(extract(days from now()::timestamp - wqc.date_entered_queue), DATE_PART('day', now() - flow.project_process_step_event.date_created)) as \"Days In Queue\", ")
                   .append("flow.process_step_event_work_queue_type.id as \"processStepEventWorkQueueTypeId\", ");

      if (timezone != null) {
        defaultFields.append(String.format("to_char(flow.project_process_step_event.start_time at time zone 'UTC' at time zone '%s', 'MM/DD/YYYY HH:MI am') as \"Event Start Time\", ", timezone));
      } else {
        defaultFields.append("to_char(flow.project_process_step_event.start_time, 'MM/DD/YYYY HH:MI am') as \"Event Start Time\", ");
      }

      //copied the PS query from buildSQL function and altered for events
      defaultFields.append("""
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
                                     WHERE pt.project_id = flow.project.id
                                       AND pt.archived is not true) tags), '[]') AS "tags",
        coalesce((
          select array_to_json(array_agg(row_to_json(notes)))
          from (
            select pn.id,
                   pn.note,
                   pn.archived,
                   pn.parent_id as "parentId",
                   pn.date_created as "dateCreated",
                   pn.date_modified as "dateModified",
                   pn.created_by_id as "createdById",
                   pn.follow_up_date as "followUpDate",
                   concat(creator.first_name, ' ', creator.last_name) as "createdBy",
                   pn.modified_by_id as "modifiedById",
                   pn.project_process_step_event_id as "projectProcessStepEventId",
                   pn.process_step_event_work_queue_type_id as "processStepEventWorkQueueTypeId",
                   coalesce((
                     select array_to_json(array_agg(row_to_json(childNotes)))
                     from (
                     select pn2.id,
                            pn2.note,
                            pn2.archived,
                            pn2.date_created as "dateCreated",
                            pn2.date_modified as "dateModified",
                            pn2.created_by_id as "createdById",
                            pn2.follow_up_date as "followUpDate",
                            concat(creator2.first_name, ' ', creator2.last_name) as "createdBy",
                            pn2.modified_by_id as "modifiedById",
                            pn2.project_process_step_event_id as "projectProcessStepEventId",
                            pn2.process_step_event_work_queue_type_id as "processStepEventWorkQueueTypeId"
                     from flow.pps_event_process_step_event_work_queue_type_note pn2
                     inner join flow.user creator2 on creator2.id = pn2.created_by_id
                     where pn2.archived is not true and
                           pn2.parent_id = pn.id
                     order by pn2.date_created
                   ) childNotes), '[]') as "childNotes"
            from flow.pps_event_process_step_event_work_queue_type_note pn
            inner join flow.user creator on creator.id = pn.created_by_id
            inner join flow.process_step_event_work_queue_type psewqt on psewqt.id = pn.process_step_event_work_queue_type_id
            where pn.archived is not true and
                  pn.parent_id is null and
                  pn.project_process_step_event_id = flow.project_process_step_event.id and
                  psewqt.process_step_event_id = flow.process_step_event.id and
                  psewqt.work_queue_type_id = %s
            order by pn.date_created desc
          ) notes), '[]') as "Notes",\040""".formatted(smartlist.getWorkQueueTypeId()));
    } else {
      //process step fields
      defaultFields.append(" select ");
    }

    if (fields.isEmpty()) {
      //remove the extra ", "
      defaultFields.delete(defaultFields.length() - 2, defaultFields.length());
    }

    //combine the query clauses and add the finishing semicolon
    return defaultFields.append(selectQuery).append(query).append(";").toString();
  }

  public String buildProcessStepSql(Smartlist smartlist, List<SmartlistFieldAssignment> fields, List<SmartlistRequirement> requirements, Integer limit) {
    return buildProcessStepSql(smartlist, fields, requirements, null, false, limit);
  }

  public String buildProcessStepSql(Smartlist smartlist, List<SmartlistFieldAssignment> fields, List<SmartlistRequirement> requirements, String timezone, Boolean useEventData, Integer limit) {

    final Long companyId = securityService.getCurrentUser().getCompanyId();

    StringBuilder query = new StringBuilder();

    List<Long> usedProcessStepIds = new ArrayList<>();

    StringBuilder customSqlQueries = new StringBuilder();

    //start of overall query
    query.append("with ");

    // Get smartlist system lists
    query.append(String.format("\"smartlistSystemList_1\" as (select * from flow.get_smartlist_system_list_options(1::bigint, %s::bigint)), ", companyId));
    query.append(String.format("\"smartlistSystemList_2\" as (select * from flow.get_smartlist_system_list_options(2::bigint, %s::bigint)), ", companyId));
    query.append(String.format("\"smartlistSystemList_3\" as (select * from flow.get_smartlist_system_list_options(3::bigint, %s::bigint)), ", companyId));
    query.append(String.format("\"smartlistSystemList_4\" as (select * from flow.get_smartlist_system_list_options(4::bigint, %s::bigint)), ", companyId));
    query.append(String.format("\"smartlistSystemList_5\" as (select * from flow.get_smartlist_system_list_options(5::bigint, %s::bigint)), ", companyId));

    // Get tables for system lists
    query.append("\"systemList_1\" as (select up.id, concat(u.first_name, ' ', u.last_name::text) as name from flow.user_position up inner join flow.user u on u.id = up.user_id), ");
    query.append("\"systemList_3\" as (select id, org_name::text as name from flow.org), ");
    query.append("\"systemList_4\" as (select id, concat(first_name, ' ', last_name::text) as name from flow.user), ");

    //build project IDs CTE
    StringBuilder projectsClause = new StringBuilder();
    StringBuilder projectsValueJoins = new StringBuilder();
    StringBuilder projectsWhereClause = new StringBuilder();

    projectsClause.append("select distinct flow.project.id ");
    projectsClause.append("from flow.project ");
    projectsClause.append(" left join flow.user_position \"project_user_position\" on \"project_user_position\".id = flow.project.user_position_id");
    projectsClause.append(" left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id");
    projectsClause.append(" inner join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true");
    projectsClause.append(" left join flow.user_position \"contact_user_position\" on \"contact_user_position\".id = flow.contact.owner_user_position_id");
    projectsClause.append(" left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id");
    projectsClause.append(" inner join flow.company_project_status_type on flow.company_project_status_type.id = flow.project.company_project_status_type_id");

    requirements.forEach(r -> {

      String referenceLocation = null;

      //join value tables for custom fields
      if (r.getCustomFieldSql() == null && r.getCustomFieldGroupAssignmentId() != null) {
        r.setValueReferenceTable(UUID.randomUUID().toString());
        r.setValueEventReferenceTable(UUID.randomUUID().toString());

        //join the value table for the respective field object type
        if (r.getObjectTypeId() == 1) {
          projectsValueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), "flow.project", false));
        } else if (r.getObjectTypeId() == 2) {
          projectsValueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), "flow.contact", false));
        } else if (r.getObjectTypeId() == 4) {
          r.setPpsTable(UUID.randomUUID().toString());
          projectsValueJoins.append(joinPpsTable(r.getPpsTable(), r.getProcessStepId(), smartlist.isMainProcessSteps()));
          projectsValueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), r.getPpsTable(), false));
        } else if (r.getObjectTypeId() == 6) {
          // check if process step is already joined
          if (projectsValueJoins.indexOf(".process_step_id = " + r.getProcessStepId()) != -1) {
            // if the PS is already joined, use it
            final String ppsTable = requirements.stream()
                                                .filter(req -> Objects.equals(req.getProcessStepId(), r.getProcessStepId()))
                                                .map(SmartlistRequirement::getPpsTable)
                                                .findFirst()
                                                .orElse(null);
            r.setPpsTable(ppsTable);

            // check if event is already joined
            if (projectsValueJoins.indexOf(".process_step_event_id = " + r.getEventId()) != -1) {
              // grab event table
              final String ppsEventTable = requirements.stream()
                                                       .filter(req -> Objects.equals(req.getEventId(), r.getEventId()))
                                                       .map(SmartlistRequirement::getPpsEventTable)
                                                       .findFirst()
                                                       .orElse(null);
              r.setPpsEventTable(ppsEventTable);
            } else {
              r.setPpsEventTable(UUID.randomUUID().toString());
              projectsValueJoins.append(joinPPsEventTable(r.getPpsEventTable(), r.getPpsTable(), r.getProcessStepEventId(), false));
            }
          } else {
            //join pps and ppse tables
            r.setPpsTable(UUID.randomUUID().toString());
            r.setPpsEventTable(UUID.randomUUID().toString());
            projectsValueJoins.append(joinPpsTable(r.getPpsTable(), r.getProcessStepId(), smartlist.isMainProcessSteps()));
            projectsValueJoins.append(joinPPsEventTable(r.getPpsEventTable(), r.getPpsTable(), r.getProcessStepEventId(), false));
          }

          // join pps event value table
          projectsValueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueEventReferenceTable(), r.getPpsEventTable(), false));
        }
      }

      if (r.getSmartlistSystemListId() != null) {
        //smartlist system lists
        if (List.of(1L, 3L, 5L).contains(r.getSmartlistSystemListId())) {
          referenceLocation = String.format("array[%s.%s]::int[]", r.getJoinTable(), r.getJoinColumn());
        } else if (r.getSmartlistSystemListId() == 2 || r.getSmartlistSystemListId() == 4) {
          final String processStepStatusTable = UUID.randomUUID().toString();

          if (r.getPpsTable() == null) {
            r.setPpsTable(UUID.randomUUID().toString());
            projectsValueJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s and \"%s\".archived is not true", r.getPpsTable(), r.getPpsTable(), r.getPpsTable(), r.getProcessStepId(), r.getPpsTable()));
            if (smartlist.isMainProcessSteps()) {
              projectsValueJoins.append(String.format(" and \"%s\".main is true ", r.getPpsTable()));
            }
          }

          projectsValueJoins.append(String.format(" left join flow.company_process_step_status_type \"%s\" on \"%s\".id = \"%s\".company_process_step_status_type_id", processStepStatusTable, processStepStatusTable, r.getPpsTable()));
          final String column = (r.getSmartlistSystemListId() == 2) ? "id" : "process_step_status_type_id";
          referenceLocation = String.format("array[\"%s\".%s]::int[]", processStepStatusTable, column);
        }
      } else if (r.getSmartlistFieldId() != null) {
        //smartlist (system) fields
        if (r.getObjectTypeId() == 1 || r.getObjectTypeId() == 2) {
          referenceLocation = r.getReferenceTable() + "." + r.getReferenceColumn();
        } else if (r.getObjectTypeId() == 4) {

          // check if process step is already joined
          if (projectsValueJoins.indexOf(".process_step_id = " + r.getProcessStepId()) != -1) {
            // if the PS is already joined, use it
            final String ppsTable = requirements.stream()
                                                .filter(req -> req.getProcessStepId().equals(r.getProcessStepId()))
                                                .map(SmartlistRequirement::getPpsTable)
                                                .findFirst()
                                                .orElse(null);
            //@TODO: I believe a join happening here is a bug. Test when able
            //            projectsValueJoins.append(joinPpsTable(ppsTable, r.getProcessStepId(), smartlist.isMainProcessSteps()));
            r.setPpsTable(ppsTable);
          } else {
            r.setPpsTable(UUID.randomUUID().toString());
          }

          String joinTable = r.getPpsTable();
          String joinColumn = r.getReferenceColumn();
          projectsValueJoins.append(joinPpsTable(r.getPpsTable(), r.getProcessStepId(), smartlist.isMainProcessSteps()));

          if (Objects.equals(r.getReferenceTable(), "flow.process_step")) {
            // process step name system field
            r.setValueReferenceTable(UUID.randomUUID().toString());
            projectsValueJoins.append(String.format(" left join flow.process_step \"%s\" on \"%s\".id = \"%s\".process_step_id", r.getValueReferenceTable(), r.getValueReferenceTable(), r.getPpsTable()));
            joinTable = r.getValueReferenceTable();
          } else if (r.getReferenceTable().equals("flow.user")) {
            // process step owner system field
            // Since this is a process step smartlist field, if it's looking at the user table, it's the process step owner field
            joinColumn = "user_position_id";
          }

          referenceLocation = String.format("\"%s\".%s", joinTable, joinColumn);
        } else if (r.getObjectTypeId() == 6) {
          // check if process step is already joined
          if (projectsValueJoins.indexOf(".process_step_id = " + r.getProcessStepId()) != -1) {
            // if the PS is already joined, use it
            final String ppsTable = requirements.stream()
                                                .filter(req -> req.getProcessStepId().equals(r.getProcessStepId()))
                                                .map(SmartlistRequirement::getPpsTable)
                                                .findFirst()
                                                .orElse(null);
            r.setPpsTable(ppsTable);

            // check if event is already joined
            if (projectsValueJoins.indexOf(".process_step_event_id = " + r.getEventId()) != -1) {
              // grab event table
              final String ppsEventTable = requirements.stream()
                                                       .filter(req -> req.getEventId().equals(r.getEventId()))
                                                       .map(SmartlistRequirement::getPpsEventTable)
                                                       .findFirst()
                                                       .orElse(null);
              r.setPpsEventTable(ppsEventTable);
            } else {
              r.setPpsEventTable(UUID.randomUUID().toString());
              projectsValueJoins.append(joinPPsEventTable(r.getPpsEventTable(), r.getPpsTable(), r.getProcessStepEventId(), false));
            }
          } else {
            r.setPpsTable(UUID.randomUUID().toString());
            r.setPpsEventTable(UUID.randomUUID().toString());
            //join pps and ppse tables
            projectsValueJoins.append(joinPpsTable(r.getPpsTable(), r.getProcessStepId(), smartlist.isMainProcessSteps()));
            projectsValueJoins.append(joinPPsEventTable(r.getPpsEventTable(), r.getPpsTable(), r.getProcessStepEventId(), false));
          }

          //next determine referenceLocation
          String joinTable = r.getPpsEventTable();
          String joinColumn = r.getReferenceColumn();

          if (Objects.equals(r.getReferenceTable(), "flow.event")) {
            //event name system field
            r.setValueReferenceTable(UUID.randomUUID().toString());

            final String pseTable = UUID.randomUUID().toString();

            //join on process step event and event table
            projectsValueJoins.append(String.format(" inner join flow.process_step_event \"%s\" on \"%s\".id = \"%s\".process_step_event_id ", pseTable, pseTable, r.getPpsEventTable()));
            projectsValueJoins.append(String.format(" inner join flow.event \"%s\" on \"%s\".id = \"%s\".event_id ", r.getValueReferenceTable(), r.getValueReferenceTable(), pseTable));

            joinTable = r.getValueReferenceTable();
          } else if (r.getReferenceTable().equals("flow.company_event_status_type")) {
            final String companyStatusTable = UUID.randomUUID().toString();
            projectsValueJoins.append(String.format(" inner join %s \"%s\" on \"%s\".id = \"%s\".%s ", r.getReferenceTable(), companyStatusTable, companyStatusTable, r.getPpsEventTable(), r.getJoinColumn()));
            joinTable = companyStatusTable;
            joinColumn = "id";
          } else if (r.getReferenceTable().equals("flow.event_status_type")) {
            final String companyStatusTable = UUID.randomUUID().toString();
            final String statusTable = UUID.randomUUID().toString();
            projectsValueJoins.append(String.format(" inner join flow.company_event_status_type \"%s\" on \"%s\".id = \"%s\".company_event_status_type_id ", companyStatusTable, companyStatusTable, r.getPpsEventTable()));
            projectsValueJoins.append(String.format(" inner join %s \"%s\" on \"%s\".id = \"%s\".%s ", r.getReferenceTable(), statusTable, statusTable, companyStatusTable, r.getJoinColumn()));
            joinTable = statusTable;
            joinColumn = "id";
          } else if (r.getReferenceTable().equals("flow.org")) {
            joinColumn = r.getJoinColumn();
          }

          referenceLocation = String.format("\"%s\".%s", joinTable, joinColumn);
        }
      } else {
        if (r.getCustomFieldSql() != null) {
          //custom fields w/sql queries
          r.setValueReferenceTable(UUID.randomUUID().toString());
          final String referenceTable = UUID.randomUUID().toString();

          if (r.getObjectTypeId() == 1) {
            projectsValueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId(), referenceTable));
          } else if (r.getObjectTypeId() == 2) {
            projectsValueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId(), referenceTable));
          } else if (r.getObjectTypeId() == 4) {

            r.setPpsTable(UUID.randomUUID().toString());
            projectsValueJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s and \"%s\".archived is not true", r.getPpsTable(), r.getPpsTable(), r.getPpsTable(), r.getProcessStepId(), r.getPpsTable()));
            if (smartlist.isMainProcessSteps()) {
              projectsValueJoins.append(String.format(" and \"%s\".main is true ", r.getPpsTable()));
            }
            projectsValueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = flow.project_process_step.id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId(), referenceTable));
          }

          projectsValueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value", r.getCustomFieldSqlKey(), r.getValueReferenceTable(), r.getValueReferenceTable(), referenceTable));

          referenceLocation = String.format("\"%s\".id", r.getValueReferenceTable());
        } else if (r.getCompanySystemListId() != null) {
          //custom fields w/system lists
          final long systemListNumber = (r.getSystemListId() == 1 || r.getSystemListId() == 2) ? 1 : r.getSystemListId();
          final String systemListTable = "systemList_" + systemListNumber;

          //@TODO: Currently, we don't check if the system list is already joined on this cfgaId. We could do that to eliminate potential duplicates between fields/columns and requirements
          final String newValueTable = UUID.randomUUID().toString();
          projectsValueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".%s", systemListTable, newValueTable, newValueTable, r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId())));
          r.setValueReferenceTable(newValueTable);

          referenceLocation = String.format("\"%s\".id", newValueTable);
        } else {
          referenceLocation = String.format("\"%s\".%s", (r.getObjectTypeId() == 6) ? r.getValueEventReferenceTable() : r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId()));
        }
      }

      Object requirementValue = getRequirementValue(r);
      String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId(), r.getDataTypeRequirement());

      //Check for double negative with "nots" between operator and requirement
      if (r.getDataTypeRequirementId() != null) {
        if (requirementValue != null && requirementValue.toString().contains("not") && operator != null && operator.contains("not")) {
          operator = operator.replace("not", "");

          if (List.of(5L, 13L, 17L, 19L, 21L, 25L, 27L).contains(r.getDataTypeRequirementId())) {
            requirementValue = requirementValue.toString().replace("not", "");
          }
        }
      }

      if (r.getDataTypeId() == 7) {
        if (r.getDataTypeRequirementId() != null) {
          projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          projectsWhereClause.append(String.format(" sort(%s) %s sort(array%s::int[]) and ", referenceLocation, operator, requirementValue));
        }
      } else if (r.getDataTypeId() == 3 || r.getDataTypeId() == 4 || (r.getDataTypeRequirementId() != null && r.getSecondaryRequirementValue() == null && r.getDataTypeId() != 1 && r.getDataTypeId() != 2)) {
        //if this is a text requirement using null/not null requirement
        if ((r.getDataTypeId() == 5 || r.getDataTypeId() == 13) && r.getDataTypeRequirementId() != null) {
          //treat empty strings as null
          projectsWhereClause.append(String.format(" nullif(trim(%s), '') %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        }
      } else if (Objects.equals(r.getReferenceTable(), "flow.project_user")) {
        projectsWhereClause.append(String.format("\"project_user_position\".id = %s and ", requirementValue));
      } else if (Objects.equals(r.getReferenceTable(), "flow.contact_user")) {
        projectsWhereClause.append(String.format("\"contact_user_position\".id = %s and ", requirementValue));
      } else {
        if (requirementValue instanceof String && requirementValue.toString().contains("null")) {
          projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          if (r.getDataTypeRequirementId() != null && List.of(1L, 2L, 3L, 6L, 7L, 8L).contains(r.getDataTypeRequirementId())) {
            projectsWhereClause.append(String.format(" date_trunc('day', %s) %s date_trunc('day', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
          } else if (r.getDataTypeRequirementId() != null && List.of(9L, 10L, 11L).contains(r.getDataTypeRequirementId())) {
            projectsWhereClause.append(String.format(" date_trunc('hour', %s) %s date_trunc('hour', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
          } else {
            if (r.getSmartlistSystemListId() != null) {
              projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
            } else {
              // If this field is process step owner, make sure we're getting past instances where this user had the same position and not just the current primary position
              if (r.getObjectTypeId() == 4 && Objects.equals(r.getReferenceTable(), "flow.user")) {
                final String positionSubquery = String.format("select id from flow.user_position where user_id = (select user_id from flow.user_position where id = %s)", requirementValue);
                projectsWhereClause.append(String.format(" %s = any(%s) and ", referenceLocation, positionSubquery));
              } else {
                projectsWhereClause.append(String.format(" %s %s '%s' and ", referenceLocation, operator, requirementValue));
              }
            }
          }
        }
      }
    });

    projectsClause.append(projectsValueJoins);
    projectsClause.append(" where" + projectsWhereClause);

    projectsClause.append(" flow.project.archived is not true");

    query.append(String.format("\"projects\" as (%s), ", projectsClause));

    for (SmartlistFieldAssignment f : fields) {
      if (f.getProcessStepId() != null && !usedProcessStepIds.contains(f.getProcessStepId())) {
        usedProcessStepIds.add(f.getProcessStepId());
      }

      //prepend custom field sql queries
      if (f.getCustomFieldSql() != null && customSqlQueries.indexOf(f.getCustomFieldSqlKey()) == -1) {
        final String customSql = (f.getCustomFieldSqlSmartlist() != null) ? f.getCustomFieldSqlSmartlist() : f.getCustomFieldSql();
        customSqlQueries.append(String.format("\"%s\" as (%s), ", f.getCustomFieldSqlKey(), customSql));
      }
    }

    if (customSqlQueries.length() > 0) {
      query.append(customSqlQueries);
    }

    if (usedProcessStepIds.isEmpty()) {
      //at this point, the only fields are project/contact, so this is essentially a project/contact smartlist
      if (smartlist.getObjectTypeId() == 6) {
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "An event smartlist must have at least 1 event type column");
      } else if (!useEventData) {
        //set smartlist object type to "project" and build sql like usual
        smartlist.setObjectTypeId(1L);
        return buildSql(smartlist, fields, requirements);
      }
    }

    //a with clause will be generated for each distinct process step
    for (Long processStepId : usedProcessStepIds) {

      SmartlistFieldAssignment psField = fields.stream()
                                               .filter(f -> Objects.equals(processStepId, f.getProcessStepId()))
                                               .findFirst()
                                               .orElse(null);

      //we know this case won't happen, but defensive programming
      if (psField == null) {
        break;
      }

      //grab all fields using this process step (PS and event fields)
      List<SmartlistFieldAssignment> psFields = fields.stream()
                                                      .filter(f -> f.getProcessStepId() == null || f.getProcessStepId().equals(processStepId))
                                                      .sorted(Comparator.comparing(SmartlistFieldAssignment::getDisplayOrder))
                                                      .toList();

      StringBuilder withClause = new StringBuilder("\"" + psField.getProcessStepName() + processStepId + "\" as (");

      StringBuilder selectFields = new StringBuilder();

      //build the select clause
      psFields.forEach(f -> {
        f.setValueReferenceTable(UUID.randomUUID().toString());
        f.setValueEventReferenceTable(UUID.randomUUID().toString());

        if (f.getSmartlistSystemListId() != null) {
          //smartlist system list fields
          final String smartlistSystemListTable = "smartlistSystemList_" + f.getSmartlistSystemListId();

          if (List.of(1L, 3L, 5L).contains(f.getSmartlistSystemListId())) {
            selectFields.append(String.format("(select name from \"%s\" where \"%s\".id = %s.%s) as \"%s\", ", smartlistSystemListTable, smartlistSystemListTable, f.getJoinTable(), f.getJoinColumn(), f.getId()));
          } else if (f.getSmartlistSystemListId() == 2 || f.getSmartlistSystemListId() == 4) {
            if (f.getSmartlistSystemListId() == 2) {
              selectFields.append(String.format("(" +
                "select name " +
                "from \"%s\" " +
                "inner join flow.company_process_step_status_type cpsst on cpsst.id = flow.project_process_step.%s " +
                "where \"%s\".id = cpsst.id) as \"%s\", ", smartlistSystemListTable, f.getJoinColumn(), smartlistSystemListTable, f.getId()));
            } else {
              selectFields.append(String.format("(" +
                "select name " +
                "from \"%s\" " +
                "inner join flow.company_process_step_status_type cpsst on cpsst.id = flow.project_process_step.%s " +
                "where \"%s\".id = cpsst.process_step_status_type_id) as \"%s\", ", smartlistSystemListTable, f.getJoinColumn(), smartlistSystemListTable, f.getId()));
            }
          }
        } else if (f.getProcessStepId() != null) {
          //PS and event fields
          if (f.getSystemListId() != null) {
            //PS system lists
            final long systemListNumber = (f.getSystemListId() == 1 || f.getSystemListId() == 2) ? 1 : f.getSystemListId();

            var valueTable = "";
            if (f.getObjectTypeId() == 4) {
              valueTable = f.getValueReferenceTable();
            } else if (f.getObjectTypeId() == 6) {
              valueTable = f.getValueEventReferenceTable();
            }

            selectFields.append(String.format("(select name from \"systemList_%s\" where \"systemList_%s\".id = \"%s\".int_value) as \"%s\", ", systemListNumber, systemListNumber, valueTable, f.getId()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.user")) {
            selectFields.append(String.format("concat(\"%s\".first_name, ' ', \"%s\".last_name) as \"%s\", ", f.getValueReferenceTable(), f.getValueReferenceTable(), f.getId()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.org")) { //else if field is event resource
            final long systemListNumber = (f.getEventResourceSystemListId() == 1 || f.getEventResourceSystemListId() == 2) ? 1 : f.getEventResourceSystemListId();
            selectFields.append(String.format("(select name from \"systemList_%s\" where id = flow.project_process_step_event.resource_id) as \"%s\", ", systemListNumber, f.getId()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.project_process_step") ||
            Objects.equals(f.getReferenceTable(), "flow.process_step") ||
            Objects.equals(f.getReferenceTable(), "flow.project_process_step_event") ||
            Objects.equals(f.getReferenceTable(), "flow.event") ||
            Objects.equals(f.getReferenceTable(), "flow.company_event_status_type") ||
            Objects.equals(f.getReferenceTable(), "flow.event_status_type")) {
            if (f.getDataTypeId() == 1) {
              selectFields.append(String.format(" to_char(%s.%s, 'YYYY-MM-DD') as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else if (f.getDataTypeId() == 2) {
              if (null != timezone) {
                selectFields.append(String.format(" to_char(%s.%s at time zone \'UTC\' at time zone \'%s\', 'YYYY-MM-DD HH:MI am') as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), timezone, f.getId()));
              }
              else {
                selectFields.append(String.format(" to_char(%s.%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
              }
            } else if (f.getDataTypeId() == 6 && Objects.equals(f.getHasListValues(), true)) {
              selectFields.append(String.format(" (select name from flow.list_of_value where id = %s.%s) as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else if (f.getDataTypeId() == 7) {
              selectFields.append(String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(%s.%s)), ',')) as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else {
              selectFields.append(String.format(" %s.%s as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            }
          } else {
            //PS and event custom fields
            var valueTable = "";
            if (f.getObjectTypeId() == 4) {
              valueTable = f.getValueReferenceTable();
            } else if (f.getObjectTypeId() == 6) {
              valueTable = f.getValueEventReferenceTable();
            }
            selectFields.append(addSelectCustomField(f.getDataTypeId(), valueTable, f.getId().toString(), f.getHasListValues(), timezone));
          }
        } else if (f.getSystemListId() != null) {
          //system list fields
          final long systemListNumber = (f.getSystemListId() == 1 || f.getSystemListId() == 2) ? 1 : f.getSystemListId();

          selectFields.append(String.format("(select name from \"systemList_%s\" where \"systemList_%s\".id = \"%s\".int_value) as \"%s\", ", systemListNumber, systemListNumber, f.getValueReferenceTable(), f.getId()));
        } else {
          if (f.getCustomFieldSql() != null) {
            //custom sql fields
            selectFields.append(String.format("\"%s\".name as \"%s\", ", f.getValueReferenceTable(), f.getId()));
          } else {
            //project and contact fields
            if (f.getCustomFieldGroupAssignmentId() != null) {
              //system fields
              if (f.getDataTypeId() == 1) {
                selectFields.append(String.format(" to_char(\"%s\".%s, 'YYYY-MM-DD') as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else if (f.getDataTypeId() == 2) {
                selectFields.append(String.format(" to_char(\"%s\".%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else if (f.getDataTypeId() == 6 && f.getHasListValues()) {
                selectFields.append(String.format(" (select name from flow.list_of_value where id = \"%s\".%s) as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else if (f.getDataTypeId() == 7) {
                selectFields.append(String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(\"%s\".%s)), ',')) as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else {
                selectFields.append(String.format(" \"%s\".%s as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              }
            } else {
              if (Objects.equals(f.getReferenceTable(), "flow.project_user") || Objects.equals(f.getReferenceTable(), "flow.contact_user")) {
                selectFields.append(String.format("%s as \"%s\", ", f.getReferenceColumn(), f.getId()));
              } else {
                selectFields.append(String.format("%s.%s as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
              }
            }
          }
        }
      });

      // remove comma and space from last field
      selectFields.deleteCharAt(selectFields.length() - 2);

      withClause.append("select ").append(selectFields);

      withClause.append(addFromClause(smartlist.getObjectTypeId(), processStepId, null));

      StringBuilder valueJoins = new StringBuilder();
      psFields.forEach(f -> {
        if (f.getSmartlistSystemListId() != null) {
          //smartlist system fields
        } else if (f.getSmartlistFieldId() != null) {
          //smartlist system fields
          if (f.getReferenceTable().equals("flow.user")) {
            final String joinUserPosition = UUID.randomUUID().toString();
            valueJoins.append(String.format(" left join flow.user_position \"%s\" on \"%s\".id = %s.%s ", joinUserPosition, joinUserPosition, f.getJoinTable(), f.getJoinColumn()));
            valueJoins.append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".user_id ", f.getReferenceTable(), f.getValueReferenceTable(), f.getValueReferenceTable(), joinUserPosition));
            f.setUserPositionTable(joinUserPosition);
          }
        } else {
          if (f.getCustomFieldSql() != null) {
            //custom sql fields
            final String referenceTable = UUID.randomUUID().toString();

            if (f.getObjectTypeId() == 1) {
              valueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, f.getCustomFieldGroupAssignmentId()));
            } else if (f.getObjectTypeId() == 2) {
              valueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, f.getCustomFieldGroupAssignmentId()));
            } else if (f.getObjectTypeId() == 4) {
              valueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = flow.project_process_step.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, f.getCustomFieldGroupAssignmentId()));
            }

            valueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value", f.getCustomFieldSqlKey(), f.getValueReferenceTable(), f.getValueReferenceTable(), referenceTable));

          } else {
            //join the value table for the respective field object type
            if (f.getObjectTypeId() == 1) {
              valueJoins.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueReferenceTable(), "flow.project", false));
            } else if (f.getObjectTypeId() == 2) {
              valueJoins.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueReferenceTable(), "flow.contact", false));
            } else if (f.getObjectTypeId() == 4) {
              f.setPpsTable("flow.project_process_step");
              valueJoins.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueReferenceTable(), f.getPpsTable(), false));
            } else if (f.getObjectTypeId() == 6) {
              f.setPpsEventTable("flow.project_process_step_event");
              valueJoins.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueEventReferenceTable(), f.getPpsEventTable(), false));
            }
          }
        }
      });

      StringBuilder whereClause = new StringBuilder();

      requirements.stream()
                  .filter(r -> r.getProcessStepId() != null && r.getProcessStepId().equals(processStepId))
                  .forEach(r -> {

                    String referenceLocation = null;

                    SmartlistFieldAssignment alreadyJoinedValueTable = psFields.stream()
                                                                               .filter(f -> r.getCustomFieldSql() == null && r.getCustomFieldGroupAssignmentId() != null && r.getCustomFieldGroupAssignmentId().equals(f.getCustomFieldGroupAssignmentId()))
                                                                               .findFirst()
                                                                               .orElse(null);

                    //join any value tables the requirements need which aren't already joined
                    if (r.getCustomFieldSql() == null) {
                      if (alreadyJoinedValueTable == null) {
                        if (r.getCustomFieldGroupAssignmentId() != null) {
                          //join the value table for the respective field object type
                          if (r.getObjectTypeId() == 1) {
                            valueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), "flow.project", false));
                          } else if (r.getObjectTypeId() == 2) {
                            valueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), "flow.contact", false));
                          } else if (r.getObjectTypeId() == 4) {
                            r.setPpsTable("flow.project_process_step");
                            valueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), r.getPpsTable(), false));
                          } else if (r.getObjectTypeId() == 6) {
                            r.setPpsEventTable("flow.project_process_step_event");
                            valueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueEventReferenceTable(), r.getPpsEventTable(), false));
                          }
                        }
                      } else if (r.getCustomFieldGroupAssignmentId() != null) {
                        r.setValueReferenceTable(alreadyJoinedValueTable.getValueReferenceTable());
                        r.setValueEventReferenceTable(alreadyJoinedValueTable.getValueEventReferenceTable());
                      }
                    }

                    if (r.getSmartlistSystemListId() != null) {
                      //smartlist system list
                      if (List.of(1L, 3L, 5L).contains(r.getSmartlistSystemListId())) {
                        referenceLocation = String.format("%s.%s", r.getJoinTable(), r.getJoinColumn());
                      } else if (r.getSmartlistSystemListId() == 2) {
                        referenceLocation = "flow.company_process_step_status_type.id";
                      } else if (r.getSmartlistSystemListId() == 4) {
                        referenceLocation = "flow.company_process_step_status_type.process_step_status_type_id";
                      }
                      if (r.getSmartlistSystemListId() != 1) {
                        referenceLocation = String.format("array[%s]::int[]", referenceLocation);
                      }
                    } else if (r.getSmartlistFieldId() != null) {
                      //smartlist system fields
                      if (r.getObjectTypeId() == 1 || r.getObjectTypeId() == 2) {
                        if (Objects.equals(r.getReferenceTable(), "flow.project_user")) {
                          referenceLocation = "\"project_user_position\".id";
                        } else if (Objects.equals(r.getReferenceTable(), "flow.contact_user")) {
                          referenceLocation = "\"contact_user_position\".id";
                        } else {
                          referenceLocation = r.getReferenceTable() + "." + r.getReferenceColumn();
                        }
                      } else if (r.getObjectTypeId() == 4) {
                        String joinTable;
                        try {
                          joinTable = fields.stream()
                                            .filter(f -> Objects.equals(f.getCustomFieldGroupAssignmentId(), r.getCustomFieldGroupAssignmentId()))
                                            .map(SmartlistFieldAssignment::getValueReferenceTable)
                                            .findFirst()
                                            .orElse(null);

                          if (joinTable == null) {
                            joinTable = UUID.randomUUID().toString();
                          }
                        } catch (NullPointerException e) {
                          joinTable = UUID.randomUUID().toString();
                        }

                        if (r.getReferenceTable() != null && r.getReferenceTable().equals("flow.user")) {
                          // Since this is a process step smartlist field, if it's looking at the user table, it's the process step owner field
                          referenceLocation = "flow.project_process_step.user_position_id";
                        } else if (r.getReferenceTable().contains(".")) {
                          referenceLocation = String.format("%s.%s", r.getReferenceTable(), r.getReferenceColumn());
                        } else {
                          referenceLocation = String.format("\"%s\".%s", joinTable, r.getReferenceColumn());
                        }
                      } else if (r.getObjectTypeId() == 6) {
                        if (Objects.equals(r.getReferenceTable(), "flow.org")) {// if field is event resource
                          referenceLocation = r.getJoinTable() + "." + r.getJoinColumn();
                        } else if (r.getReferenceTable().equals("flow.company_event_status_type")) {
                          referenceLocation = r.getReferenceTable() + ".id";
                        } else if (r.getReferenceTable().equals("flow.event_status_type")) {
                          referenceLocation = r.getReferenceTable() + ".id";
                        } else if (r.getReferenceTable().contains(".")) {
                          referenceLocation = String.format("%s.%s", r.getReferenceTable(), r.getReferenceColumn());
                        }
                      }
                    } else {
                      //custom fields
                      if (r.getCustomFieldSql() != null) {
                        //custom sql fields
                        if (valueJoins.indexOf(r.getCustomFieldSqlKey()) == -1) {
                          r.setValueReferenceTable(UUID.randomUUID().toString());
                          final String referenceTable = UUID.randomUUID().toString();

                          if (r.getObjectTypeId() == 1) {
                            valueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId()));
                          } else if (r.getObjectTypeId() == 2) {
                            valueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId()));
                          } else if (r.getObjectTypeId() == 4) {
                            valueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = flow.project_process_step.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId()));
                          }

                          valueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value", r.getCustomFieldSqlKey(), r.getValueReferenceTable(), r.getValueReferenceTable(), referenceTable));
                        } else {
                          SmartlistFieldAssignment joinedField = fields.stream()
                                                                       .filter(f -> Objects.equals(r.getCustomFieldGroupAssignmentId(), f.getCustomFieldGroupAssignmentId()))
                                                                       .findFirst()
                                                                       .orElse(null);

                          //joinedField **shouldn't** ever be null here. If it is, there are bigger issues
                          if (joinedField != null) {
                            r.setValueReferenceTable(joinedField.getValueReferenceTable());
                          }
                        }

                        referenceLocation = String.format("\"%s\".id", r.getValueReferenceTable());
                      } else if (r.getCompanySystemListId() != null) {
                        //system list fields
                        final long systemListNumber = (r.getSystemListId() == 1 || r.getSystemListId() == 2) ? 1 : r.getSystemListId();
                        final String systemListTable = "systemList_" + systemListNumber;

                        //Currently, we don't check if the system list is already joined on this cfgaId. We could do that to eliminate potential duplicates
                        final String newValueTable = UUID.randomUUID().toString();
                        valueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".%s", systemListTable, newValueTable, newValueTable, r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId())));
                        r.setValueReferenceTable(newValueTable);

                        referenceLocation = String.format("\"%s\".id", newValueTable);
                      } else {
                        referenceLocation = String.format("\"%s\".%s", (r.getObjectTypeId() == 6) ? r.getValueEventReferenceTable() : r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId()));
                      }
                    }

                    Object requirementValue = getRequirementValue(r);
                    String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId(), r.getDataTypeRequirement());

                    //Check for double negative with "nots" between operator and requirement
                    if (r.getDataTypeRequirementId() != null) {
                      if (requirementValue != null && requirementValue.toString().contains("not") && operator != null && operator.contains("not")) {
                        operator = operator.replace("not", "");

                        if (List.of(5L, 13L, 17L, 19L, 21L, 25L, 27L).contains(r.getDataTypeRequirementId())) {
                          requirementValue = requirementValue.toString().replace("not", "");
                        }
                      }
                    }

                    if (r.getDataTypeId() == 7) {
                      if (r.getDataTypeRequirementId() != null) {
                        whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
                      } else {
                        whereClause.append(String.format(" sort(%s) %s sort(array%s::int[]) and ", referenceLocation, operator, requirementValue));
                      }
                    } else if (r.getDataTypeId() == 3 || r.getDataTypeId() == 4 || (r.getDataTypeRequirementId() != null && r.getSecondaryRequirementValue() == null && r.getDataTypeId() != 1 && r.getDataTypeId() != 2)) {
                      //if this is a text requirement using null/not null requirement
                      if ((r.getDataTypeId() == 5 || r.getDataTypeId() == 13) && r.getDataTypeRequirementId() != null) {
                        //treat empty strings as null
                        whereClause.append(String.format(" nullif(trim(%s), '') %s %s and ", referenceLocation, operator, requirementValue));
                      } else {
                        whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
                      }
                    } else {
                      if (requirementValue instanceof String && requirementValue.toString().contains("null")) {
                        whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
                      } else {
                        if (r.getDataTypeRequirementId() != null && List.of(1L, 2L, 3L, 6L, 7L, 8L).contains(r.getDataTypeRequirementId())) {
                          whereClause.append(String.format(" date_trunc('day', %s) %s date_trunc('day', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
                        } else if (r.getDataTypeRequirementId() != null && List.of(9L, 10L, 11L).contains(r.getDataTypeRequirementId())) {
                          whereClause.append(String.format(" date_trunc('hour', %s) %s date_trunc('hour', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
                        } else {
                          if (r.getSmartlistSystemListId() != null) {
                            whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
                          } else {
                            // If this field is process step owner, make sure we're getting past instances where this user had the same position and not just the current primary position
                            if (r.getObjectTypeId() == 4 && Objects.equals(r.getReferenceTable(), "flow.user")) {
                              final String positionSubquery = String.format("select id from flow.user_position where user_id = (select user_id from flow.user_position where id = %s)", requirementValue);
                              whereClause.append(String.format(" %s = any(%s) and ", referenceLocation, positionSubquery));
                            } else {
                              whereClause.append(String.format(" %s %s '%s' and ", referenceLocation, operator, requirementValue));
                            }
                          }
                        }
                      }
                    }
                  });

      withClause.append(valueJoins);

      final String companySubquery = String.format("select id from flow.company where id = %s or parent_company_id = %s", companyId, companyId);

      if (whereClause.length() > 0) {
        whereClause.append(String.format("flow.process_step.company_id = any(%s)", companySubquery));
        whereClause.append(" and flow.project_process_step.project_id = any(array[\"projects\".id]) and flow.project_process_step.archived is not true");

        withClause.append(String.format(" where %s", whereClause));
      } else {
        withClause.append(" where flow.project_process_step.project_id = any(array[\"projects\".id]) and flow.project_process_step.archived is not true");
        withClause.append(String.format(" and flow.process_step.company_id = any(%s)", companySubquery));
      }

      if (smartlist.isMainProcessSteps()) {
        withClause.append(" and flow.project_process_step.main is true");
      }

      query.append(String.format("%s), ", withClause));
    }

    // remove comma and space from with clause
    query.delete(query.length() - 2, query.length());

    List<SmartlistFieldAssignment> sortedFields = fields.stream()
                                                        .sorted(Comparator.comparing(SmartlistFieldAssignment::getDisplayOrder))
                                                        .toList();

    usedProcessStepIds.forEach(id -> {

      Optional<SmartlistFieldAssignment> psField = fields.stream().filter(f -> Objects.equals(f.getProcessStepId(), id)).findFirst();

      StringBuilder selectClause = new StringBuilder(" select ");

      sortedFields.forEach(f -> {
        if (f.getProcessStepId() != null) {
          f.setName(f.getName() + " - " + f.getProcessStepName());

          if (f.getProcessStepId().equals(id)) {
            selectClause.append(String.format("\"%s\".\"%s\" as \"%s\", ", f.getProcessStepName() + f.getProcessStepId(), f.getId(), f.getName()));
          } else {
            selectClause.append(String.format("null as \"%s\", ", f.getName()));
          }
        } else {
          //project and contact fields
          psField.ifPresent(field -> selectClause.append(String.format("\"%s\".\"%s\" as \"%s\", ", field.getProcessStepName() + field.getProcessStepId(), f.getId(), f.getName())));
        }
      });

      // remove comma and space from select clause
      selectClause.deleteCharAt(selectClause.length() - 2);

      query.append(selectClause);

      StringBuilder fromClause = new StringBuilder(" from ");


      psField.ifPresent(f -> fromClause.append(String.format("\"%s%s\"", f.getProcessStepName(), f.getProcessStepId())));

      query.append(fromClause).append(" union ");
    });

    // remove comma and space from with clause
    query.delete(query.length() - 7, query.length());

    if (limit != null) {
      query.append(String.format(" limit %s", limit));
    }

    query.append(";");

    return query.toString();
  }

  public String buildEventSql(Smartlist smartlist, List<SmartlistFieldAssignment> fields, List<SmartlistRequirement> requirements, String timezone, Boolean useEventData) {

    final Long companyId = securityService.getCurrentUser().getCompanyId();

    StringBuilder query = new StringBuilder();

    List<SmartlistFieldAssignment> usedProcessSteps = new ArrayList<>();
    List<SmartlistFieldAssignment> usedProcessStepEvents = new ArrayList<>();

    StringBuilder customSqlQueries = new StringBuilder();

    //start of overall query
    query.append("with ");

    // Get smartlist system lists
    query.append(String.format("\"smartlistSystemList_1\" as (select * from flow.get_smartlist_system_list_options(1::bigint, %s::bigint)), ", companyId));
    query.append(String.format("\"smartlistSystemList_2\" as (select * from flow.get_smartlist_system_list_options(2::bigint, %s::bigint)), ", companyId));
    query.append(String.format("\"smartlistSystemList_3\" as (select * from flow.get_smartlist_system_list_options(3::bigint, %s::bigint)), ", companyId));
    query.append(String.format("\"smartlistSystemList_4\" as (select * from flow.get_smartlist_system_list_options(4::bigint, %s::bigint)), ", companyId));
    query.append(String.format("\"smartlistSystemList_5\" as (select * from flow.get_smartlist_system_list_options(5::bigint, %s::bigint)), ", companyId));

    // Get tables for system lists
    query.append("\"systemList_1\" as (select up.id, concat(u.first_name, ' ', u.last_name::text) as name from flow.user_position up inner join flow.user u on u.id = up.user_id), ");
    query.append("\"systemList_3\" as (select id, org_name::text as name from flow.org), ");
    query.append("\"systemList_4\" as (select id, concat(first_name, ' ', last_name::text) as name from flow.user), ");

    //build project IDs CTE
    StringBuilder projectsClause = new StringBuilder();
    StringBuilder projectsValueJoins = new StringBuilder();
    StringBuilder projectsWhereClause = new StringBuilder();

    projectsClause.append("select distinct flow.project.id ");
    projectsClause.append("from flow.project ");
    projectsClause.append(" left join flow.user_position \"project_user_position\" on \"project_user_position\".id = flow.project.user_position_id");
    projectsClause.append(" left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id");
    projectsClause.append(" inner join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true");
    projectsClause.append(" left join flow.user_position \"contact_user_position\" on \"contact_user_position\".id = flow.contact.owner_user_position_id");
    projectsClause.append(" left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id");
    projectsClause.append(" inner join flow.company_project_status_type on flow.company_project_status_type.id = flow.project.company_project_status_type_id");

    for (var r : requirements) {

      String referenceLocation = null;

      //join value tables for custom fields
      if (r.getCustomFieldSql() == null && r.getCustomFieldGroupAssignmentId() != null) {
        r.setValueReferenceTable(UUID.randomUUID().toString());
        r.setValueEventReferenceTable(UUID.randomUUID().toString());

        //join the value table for the respective field object type
        if (r.getObjectTypeId() == 1) {
          projectsValueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), "flow.project", false));
        } else if (r.getObjectTypeId() == 2) {
          projectsValueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), "flow.contact", false));
        } else if (r.getObjectTypeId() == 4) {
          r.setPpsTable(UUID.randomUUID().toString());
          projectsValueJoins.append(joinPpsTable(r.getPpsTable(), r.getProcessStepId(), smartlist.isMainProcessSteps()));
          projectsValueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), r.getPpsTable(), false));
        } else if (r.getObjectTypeId() == 6) {
          // check if process step is already joined
          if (projectsValueJoins.indexOf(".process_step_id = " + r.getProcessStepId()) != -1) {
            // if the PS is already joined, use it
            final String ppsTable = requirements.stream()
                                                .filter(req -> Objects.equals(req.getProcessStepId(), r.getProcessStepId()))
                                                .map(SmartlistRequirement::getPpsTable)
                                                .findFirst()
                                                .orElse(null);
            r.setPpsTable(ppsTable);

            // check if event is already joined
            if (projectsValueJoins.indexOf(".process_step_event_id = " + r.getEventId()) != -1) {
              // grab event table
              final String ppsEventTable = requirements.stream()
                                                       .filter(req -> Objects.equals(req.getEventId(), r.getEventId()))
                                                       .map(SmartlistRequirement::getPpsEventTable)
                                                       .findFirst()
                                                       .orElse(null);
              r.setPpsEventTable(ppsEventTable);
            } else {
              r.setPpsEventTable(UUID.randomUUID().toString());
              projectsValueJoins.append(joinPPsEventTable(r.getPpsEventTable(), r.getPpsTable(), r.getProcessStepEventId(), false));
            }
          } else {
            //join pps and ppse tables
            r.setPpsTable(UUID.randomUUID().toString());
            r.setPpsEventTable(UUID.randomUUID().toString());
            projectsValueJoins.append(joinPpsTable(r.getPpsTable(), r.getProcessStepId(), smartlist.isMainProcessSteps()));
            projectsValueJoins.append(joinPPsEventTable(r.getPpsEventTable(), r.getPpsTable(), r.getProcessStepEventId(), false));
          }

          // join pps event value table
          projectsValueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueEventReferenceTable(), r.getPpsEventTable(), false));
        }
      }

      if (r.getSmartlistSystemListId() != null) {
        //smartlist system lists
        if (List.of(1L, 3L, 5L).contains(r.getSmartlistSystemListId())) {
          referenceLocation = String.format("array[%s.%s]::int[]", r.getJoinTable(), r.getJoinColumn());
        } else if (r.getSmartlistSystemListId() == 2 || r.getSmartlistSystemListId() == 4) {
          final String processStepStatusTable = UUID.randomUUID().toString();

          if (r.getPpsTable() == null) {
            r.setPpsTable(UUID.randomUUID().toString());
            projectsValueJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s and \"%s\".archived is not true", r.getPpsTable(), r.getPpsTable(), r.getPpsTable(), r.getProcessStepId(), r.getPpsTable()));
            if (smartlist.isMainProcessSteps()) {
              projectsValueJoins.append(String.format(" and \"%s\".main is true ", r.getPpsTable()));
            }
          }

          projectsValueJoins.append(String.format(" left join flow.company_process_step_status_type \"%s\" on \"%s\".id = \"%s\".company_process_step_status_type_id", processStepStatusTable, processStepStatusTable, r.getPpsTable()));
          final String column = (r.getSmartlistSystemListId() == 2) ? "id" : "process_step_status_type_id";
          referenceLocation = String.format("array[\"%s\".%s]::int[]", processStepStatusTable, column);
        }
      } else if (r.getSmartlistFieldId() != null) {
        //smartlist (system) fields
        if (r.getObjectTypeId() == 1 || r.getObjectTypeId() == 2) {
          referenceLocation = r.getReferenceTable() + "." + r.getReferenceColumn();
        } else if (r.getObjectTypeId() == 4) {

          // check if process step is already joined
          if (isPsAlreadyJoined(projectsValueJoins.toString(), r.getProcessStepId())) {
            // if the PS is already joined, use it
            //@TODO: I believe a join happening here is a bug. Test when able
            //            projectsValueJoins.append(joinPpsTable(ppsTable, r.getProcessStepId(), smartlist.isMainProcessSteps()));
            r.setPpsTable(getPpsTable(r, requirements, null));
          } else {
            r.setPpsTable(UUID.randomUUID().toString());
            projectsValueJoins.append(joinPpsTable(r.getPpsTable(), r.getProcessStepId(), smartlist.isMainProcessSteps()));
          }

          String joinTable = r.getPpsTable();
          String joinColumn = r.getReferenceColumn();

          if (Objects.equals(r.getReferenceTable(), "flow.process_step")) {
            // process step name system field
            r.setValueReferenceTable(UUID.randomUUID().toString());
            projectsValueJoins.append(String.format(" left join flow.process_step \"%s\" on \"%s\".id = \"%s\".process_step_id", r.getValueReferenceTable(), r.getValueReferenceTable(), r.getPpsTable()));
            joinTable = r.getValueReferenceTable();
          } else if (r.getReferenceTable().equals("flow.user")) {
            // process step owner system field
            // Since this is a process step smartlist field, if it's looking at the user table, it's the process step owner field
            joinColumn = "user_position_id";
          }

          referenceLocation = String.format("\"%s\".%s", joinTable, joinColumn);
        } else if (r.getObjectTypeId() == 6) {
          // check if process step is already joined
          if (projectsValueJoins.indexOf(".process_step_id = " + r.getProcessStepId()) != -1) {
            // if the PS is already joined, use it
            final String ppsTable = requirements.stream()
                                                .filter(req -> req.getProcessStepId().equals(r.getProcessStepId()))
                                                .map(SmartlistRequirement::getPpsTable)
                                                .findFirst()
                                                .orElse(null);
            r.setPpsTable(ppsTable);

            // check if event is already joined
            if (projectsValueJoins.indexOf(".process_step_event_id = " + r.getEventId()) != -1) {
              // grab event table
              final String ppsEventTable = requirements.stream()
                                                       .filter(req -> req.getEventId().equals(r.getEventId()))
                                                       .map(SmartlistRequirement::getPpsEventTable)
                                                       .findFirst()
                                                       .orElse(null);
              r.setPpsEventTable(ppsEventTable);
            } else {
              r.setPpsEventTable(UUID.randomUUID().toString());
              projectsValueJoins.append(joinPPsEventTable(r.getPpsEventTable(), r.getPpsTable(), r.getProcessStepEventId(), false));
            }
          } else {
            r.setPpsTable(UUID.randomUUID().toString());
            r.setPpsEventTable(UUID.randomUUID().toString());
            //join pps and ppse tables
            projectsValueJoins.append(joinPpsTable(r.getPpsTable(), r.getProcessStepId(), smartlist.isMainProcessSteps()));
            projectsValueJoins.append(joinPPsEventTable(r.getPpsEventTable(), r.getPpsTable(), r.getProcessStepEventId(), false));
          }

          //next determine referenceLocation
          String joinTable = r.getPpsEventTable();
          String joinColumn = r.getReferenceColumn();

          if (Objects.equals(r.getReferenceTable(), "flow.event")) {
            //event name system field
            r.setValueReferenceTable(UUID.randomUUID().toString());

            final String pseTable = UUID.randomUUID().toString();

            //join on process step event and event table
            projectsValueJoins.append(String.format(" inner join flow.process_step_event \"%s\" on \"%s\".id = \"%s\".process_step_event_id ", pseTable, pseTable, r.getPpsEventTable()));
            projectsValueJoins.append(String.format(" inner join flow.event \"%s\" on \"%s\".id = \"%s\".event_id ", r.getValueReferenceTable(), r.getValueReferenceTable(), pseTable));

            joinTable = r.getValueReferenceTable();
          } else if (r.getReferenceTable().equals("flow.company_event_status_type")) {
            final String companyStatusTable = UUID.randomUUID().toString();
            projectsValueJoins.append(String.format(" inner join %s \"%s\" on \"%s\".id = \"%s\".%s ", r.getReferenceTable(), companyStatusTable, companyStatusTable, r.getPpsEventTable(), r.getJoinColumn()));
            joinTable = companyStatusTable;
            joinColumn = "id";
          } else if (r.getReferenceTable().equals("flow.event_status_type")) {
            final String companyStatusTable = UUID.randomUUID().toString();
            final String statusTable = UUID.randomUUID().toString();
            projectsValueJoins.append(String.format(" inner join flow.company_event_status_type \"%s\" on \"%s\".id = \"%s\".company_event_status_type_id ", companyStatusTable, companyStatusTable, r.getPpsEventTable()));
            projectsValueJoins.append(String.format(" inner join %s \"%s\" on \"%s\".id = \"%s\".%s ", r.getReferenceTable(), statusTable, statusTable, companyStatusTable, r.getJoinColumn()));
            joinTable = statusTable;
            joinColumn = "id";
          } else if (r.getReferenceTable().equals("flow.org")) {
            joinColumn = r.getJoinColumn();
          }

          referenceLocation = String.format("\"%s\".%s", joinTable, joinColumn);
        }
      } else {
        if (r.getCustomFieldSql() != null) {
          //custom fields w/sql queries
          r.setValueReferenceTable(UUID.randomUUID().toString());
          final String referenceTable = UUID.randomUUID().toString();

          if (r.getObjectTypeId() == 1) {
            projectsValueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId(), referenceTable));
          } else if (r.getObjectTypeId() == 2) {
            projectsValueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId(), referenceTable));
          } else if (r.getObjectTypeId() == 4) {

            r.setPpsTable(UUID.randomUUID().toString());
            projectsValueJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s and \"%s\".archived is not true", r.getPpsTable(), r.getPpsTable(), r.getPpsTable(), r.getProcessStepId(), r.getPpsTable()));
            if (smartlist.isMainProcessSteps()) {
              projectsValueJoins.append(String.format(" and \"%s\".main is true ", r.getPpsTable()));
            }
            projectsValueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = flow.project_process_step.id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId(), referenceTable));
          }

          projectsValueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value", r.getCustomFieldSqlKey(), r.getValueReferenceTable(), r.getValueReferenceTable(), referenceTable));

          referenceLocation = String.format("\"%s\".id", r.getValueReferenceTable());
        } else if (r.getCompanySystemListId() != null) {
          //custom fields w/system lists
          final long systemListNumber = (r.getSystemListId() == 1 || r.getSystemListId() == 2) ? 1 : r.getSystemListId();
          final String systemListTable = "systemList_" + systemListNumber;

          //@TODO: Currently, we don't check if the system list is already joined on this cfgaId. We could do that to eliminate potential duplicates between fields/columns and requirements
          final String newValueTable = UUID.randomUUID().toString();
          projectsValueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".%s", systemListTable, newValueTable, newValueTable, r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId())));
          r.setValueReferenceTable(newValueTable);

          referenceLocation = String.format("\"%s\".id", newValueTable);
        } else {
          referenceLocation = String.format("\"%s\".%s", (r.getObjectTypeId() == 6) ? r.getValueEventReferenceTable() : r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId()));
        }
      }

      Object requirementValue = getRequirementValue(r);
      String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId(), r.getDataTypeRequirement());

      //Check for double negative with "nots" between operator and requirement
      if (r.getDataTypeRequirementId() != null) {
        if (requirementValue != null && requirementValue.toString().contains("not") && operator != null && operator.contains("not")) {
          operator = operator.replace("not", "");

          if (List.of(5L, 13L, 17L, 19L, 21L, 25L, 27L).contains(r.getDataTypeRequirementId())) {
            requirementValue = requirementValue.toString().replace("not", "");
          }
        }
      }

      if (r.getDataTypeId() == 7) {
        if (r.getDataTypeRequirementId() != null) {
          projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          projectsWhereClause.append(String.format(" sort(%s) %s sort(array%s::int[]) and ", referenceLocation, operator, requirementValue));
        }
      } else if (r.getDataTypeId() == 3 || r.getDataTypeId() == 4 || (r.getDataTypeRequirementId() != null && r.getSecondaryRequirementValue() == null && r.getDataTypeId() != 1 && r.getDataTypeId() != 2)) {
        //if this is a text requirement using null/not null requirement
        if ((r.getDataTypeId() == 5 || r.getDataTypeId() == 13) && r.getDataTypeRequirementId() != null) {
          //treat empty strings as null
          projectsWhereClause.append(String.format(" nullif(trim(%s), '') %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        }
      } else if (Objects.equals(r.getReferenceTable(), "flow.project_user")) {
        projectsWhereClause.append(String.format("\"project_user_position\".id = %s and ", requirementValue));
      } else if (Objects.equals(r.getReferenceTable(), "flow.contact_user")) {
        projectsWhereClause.append(String.format("\"contact_user_position\".id = %s and ", requirementValue));
      } else {
        if (requirementValue instanceof String && requirementValue.toString().contains("null")) {
          projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          if (r.getDataTypeRequirementId() != null && List.of(1L, 2L, 3L, 6L, 7L, 8L).contains(r.getDataTypeRequirementId())) {
            projectsWhereClause.append(String.format(" date_trunc('day', %s) %s date_trunc('day', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
          } else if (r.getDataTypeRequirementId() != null && List.of(9L, 10L, 11L).contains(r.getDataTypeRequirementId())) {
            projectsWhereClause.append(String.format(" date_trunc('hour', %s) %s date_trunc('hour', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
          } else {
            if (r.getSmartlistSystemListId() != null) {
              projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
            } else {
              // If this field is process step owner, make sure we're getting past instances where this user had the same position and not just the current primary position
              if (r.getObjectTypeId() == 4 && Objects.equals(r.getReferenceTable(), "flow.user")) {
                final String positionSubquery = String.format("select id from flow.user_position where user_id = (select user_id from flow.user_position where id = %s)", requirementValue);
                projectsWhereClause.append(String.format(" %s = any(%s) and ", referenceLocation, positionSubquery));
              } else {
                projectsWhereClause.append(String.format(" %s %s '%s' and ", referenceLocation, operator, requirementValue));
              }
            }
          }
        }
      }
    }

    projectsClause.append(projectsValueJoins);
    projectsClause.append(" where").append(projectsWhereClause);

    projectsClause.append(" flow.project.archived is not true");

    query.append(String.format("\"projects\" as (%s), ", projectsClause));

    List<SmartlistFieldAssignment> additionalPsFields = new ArrayList<>();

    for (var f : fields) {
      if (f.getObjectTypeId() == 6) {
        var usedField = usedProcessStepEvents.stream()
                                             .filter(field -> Objects.equals(field.getProcessStepEventId(), f.getProcessStepEventId()))
                                             .findFirst()
                                             .orElse(null);

        if (usedField == null) {
          usedProcessStepEvents.add(f);
        }
      } else if (f.getObjectTypeId() == 4) {
        var usedField = usedProcessSteps.stream()
                                        .filter(field -> Objects.equals(field.getProcessStepId(), f.getProcessStepId()))
                                        .findFirst()
                                        .orElse(null);

        if (usedField == null) {
          usedProcessSteps.add(f);
        }
      }

      //prepend custom field sql queries
      if (f.getCustomFieldSql() != null && customSqlQueries.indexOf(f.getCustomFieldSqlKey()) == -1) {
        final String customSql = (f.getCustomFieldSqlSmartlist() != null) ? f.getCustomFieldSqlSmartlist() : f.getCustomFieldSql();
        customSqlQueries.append(String.format("\"%s\" as (%s), ", f.getCustomFieldSqlKey(), customSql));
      }
    }
    // get PS fields which don't belong an event field
    for (var f : fields) {
      if (f.getObjectTypeId() == 4) {
        var usedEventPs = usedProcessStepEvents.stream()
                                               .filter(field -> Objects.equals(field.getProcessStepId(), f.getProcessStepId()))
                                               .findFirst()
                                               .orElse(null);

        if (usedEventPs == null) {
          additionalPsFields.add(f);
        }
      }
    }

    if (usedProcessStepEvents.isEmpty()) {
      //at this point, the only fields are project/contact, so this is essentially a project/contact smartlist
      if (smartlist.getObjectTypeId() == 6) {
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "An event smartlist must have at least 1 event type column");
      } else if (!useEventData) {
        //set smartlist object type to "project" and build sql like usual
        smartlist.setObjectTypeId(1L);
        return buildSql(smartlist, fields, requirements);
      }
    }

    if (customSqlQueries.length() > 0) {
      query.append(customSqlQueries);
    }

    //a with clause will be generated for each distinct process step event
    for (var eventField : usedProcessStepEvents) {

      //we know this case won't happen, but defensive programming
      if (eventField == null) {
        break;
      }

      //grab all fields using this process step (PS and event fields)
      List<SmartlistFieldAssignment> eventFields = fields.stream()
                                                         .filter(f -> {
                                                           if (f.getObjectTypeId() == 6) {
                                                             return Objects.equals(f.getProcessStepEventId(), eventField.getProcessStepEventId());
                                                           } else if (f.getObjectTypeId() == 4) {
                                                             return Objects.equals(f.getProcessStepId(), eventField.getProcessStepId()) ||
                                                               additionalPsFields.contains(f);
                                                           } else {
                                                             return true;
                                                           }
                                                         })
                                                         .sorted(Comparator.comparing(SmartlistFieldAssignment::getDisplayOrder))
                                                         .toList();

      StringBuilder withClause = new StringBuilder("\"" + eventField.getEventName() + eventField.getProcessStepEventId() + "\" as (");

      StringBuilder valueJoins = new StringBuilder();
      for (var f : eventFields) {
        final var isAdditionalPs = additionalPsFields.contains(f);

        f.setValueReferenceTable(UUID.randomUUID().toString());
        f.setValueEventReferenceTable(UUID.randomUUID().toString());
        f.setPpsTable(UUID.randomUUID().toString());
        f.setPpsEventTable(UUID.randomUUID().toString());

        if (f.getSmartlistSystemListId() != null) {
          //smartlist system fields
        } else if (f.getSmartlistFieldId() != null) {
          //smartlist system fields
          if (f.getReferenceTable().equals("flow.user")) {

            var joinTable = f.getJoinTable();
            if (isAdditionalPs) {
              //see if this PPS table has already been joined
              // if so reuse the table, if not join it
              if (isPsAlreadyJoined(valueJoins.toString(), f.getProcessStepId())) {
                f.setPpsTable(getPpsTable(f, eventFields, null));
              } else {
                valueJoins.append(joinPpsTable(f.getPpsTable(), f.getProcessStepId(), true));
              }
              joinTable = String.format("\"%s\"", f.getPpsTable());
            }

            final String joinUserPosition = UUID.randomUUID().toString();
            valueJoins.append(String.format(" left join flow.user_position \"%s\" on \"%s\".id = %s.%s ", joinUserPosition, joinUserPosition, joinTable, f.getJoinColumn()));
            valueJoins.append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".user_id ", f.getReferenceTable(), f.getValueReferenceTable(), f.getValueReferenceTable(), joinUserPosition));
            f.setUserPositionTable(joinUserPosition);
          } else if (f.getReferenceTable().equals("flow.project_process_step") || Objects.equals(f.getReferenceTable(), "flow.process_step")) {
            if (isAdditionalPs) {
              //see if this PPS table has already been joined
              // if so reuse the table, if not join it
              if (isPsAlreadyJoined(valueJoins.toString(), f.getProcessStepId())) {
                f.setPpsTable(getPpsTable(f, eventFields, null));
              } else {
                valueJoins.append(joinPpsTable(f.getPpsTable(), f.getProcessStepId(), true));
              }
            }
          }
        } else {
          if (f.getCustomFieldSql() != null) {
            //custom sql fields
            final String referenceTable = UUID.randomUUID().toString();

            if (f.getObjectTypeId() == 1) {
              valueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, f.getCustomFieldGroupAssignmentId()));
            } else if (f.getObjectTypeId() == 2) {
              valueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, f.getCustomFieldGroupAssignmentId()));
            } else if (f.getObjectTypeId() == 4) {
              valueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = flow.project_process_step.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, f.getCustomFieldGroupAssignmentId()));
            }

            valueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value", f.getCustomFieldSqlKey(), f.getValueReferenceTable(), f.getValueReferenceTable(), referenceTable));

          } else {
            //join the value table for the respective field object type
            if (f.getObjectTypeId() == 1) {
              valueJoins.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueReferenceTable(), "flow.project", false));
            } else if (f.getObjectTypeId() == 2) {
              valueJoins.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueReferenceTable(), "flow.contact", false));
            } else if (f.getObjectTypeId() == 4) {
              if (isAdditionalPs) {
                //see if this PPS table has already been joined
                // if so reuse the table, if not join it
                if (isPsAlreadyJoined(valueJoins.toString(), f.getProcessStepId())) {
                  f.setPpsTable(getPpsTable(f, eventFields, null));
                } else {
                  valueJoins.append(joinPpsTable(f.getPpsTable(), f.getProcessStepId(), true));
                }
              } else {
                f.setPpsTable("flow.project_process_step");
              }
              valueJoins.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueReferenceTable(), f.getPpsTable(), false));
            } else if (f.getObjectTypeId() == 6) {
              f.setPpsEventTable("flow.project_process_step_event");
              valueJoins.append(joinValueTable(f.getObjectTypeId(), f.getCustomFieldGroupAssignmentId(), f.getValueEventReferenceTable(), f.getPpsEventTable(), false));
            }
          }
        }
      }

      StringBuilder selectFields = new StringBuilder();

      //build the select clause
      for (var f : eventFields) {
        final var isAdditionalPs = additionalPsFields.contains(f);

        if (f.getSmartlistSystemListId() != null) {
          //smartlist system list fields
          final String smartlistSystemListTable = "smartlistSystemList_" + f.getSmartlistSystemListId();

          if (List.of(1L, 3L, 5L).contains(f.getSmartlistSystemListId())) {
            selectFields.append(String.format("(select name from \"%s\" where \"%s\".id = %s.%s) as \"%s\", ", smartlistSystemListTable, smartlistSystemListTable, f.getJoinTable(), f.getJoinColumn(), f.getId()));
          } else if (f.getSmartlistSystemListId() == 2 || f.getSmartlistSystemListId() == 4) {

            if (isAdditionalPs) {
              //see if this PPS table has already been joined
              // if so reuse the table, if not join it
              if (isPsAlreadyJoined(valueJoins.toString(), f.getProcessStepId())) {
                f.setPpsTable(getPpsTable(f, eventFields, null));
              } else {
                valueJoins.append(joinPpsTable(f.getPpsTable(), f.getProcessStepId(), true));
              }
            } else {
              f.setPpsTable("flow.project_process_step");
            }

            String joinTable = f.getPpsTable();

            if (isUUID(f.getPpsTable())) {
              joinTable = String.format("\"%s\"", f.getPpsTable());
            }

            if (f.getSmartlistSystemListId() == 2) {
              selectFields.append(String.format("(" +
                "select name " +
                "from \"%s\" " +
                "inner join flow.company_process_step_status_type cpsst on cpsst.id = %s.%s " +
                "where \"%s\".id = cpsst.id) as \"%s\", ", smartlistSystemListTable, joinTable, f.getJoinColumn(), smartlistSystemListTable, f.getId()));
            } else {
              selectFields.append(String.format("(" +
                "select name " +
                "from \"%s\" " +
                "inner join flow.company_process_step_status_type cpsst on cpsst.id = %s.%s " +
                "where \"%s\".id = cpsst.process_step_status_type_id) as \"%s\", ", smartlistSystemListTable, joinTable, f.getJoinColumn(), smartlistSystemListTable, f.getId()));
            }
          }
        } else if (f.getProcessStepId() != null) {
          //PS and event fields
          if (f.getSystemListId() != null) {
            //PS system lists
            final long systemListNumber = (f.getSystemListId() == 1 || f.getSystemListId() == 2) ? 1 : f.getSystemListId();

            var valueTable = "";
            if (f.getObjectTypeId() == 4) {
              valueTable = f.getValueReferenceTable();
            } else if (f.getObjectTypeId() == 6) {
              valueTable = f.getValueEventReferenceTable();
            }

            selectFields.append(String.format("(select name from \"systemList_%s\" where \"systemList_%s\".id = \"%s\".int_value) as \"%s\", ", systemListNumber, systemListNumber, valueTable, f.getId()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.user")) {
            selectFields.append(String.format("concat(\"%s\".first_name, ' ', \"%s\".last_name) as \"%s\", ", f.getValueReferenceTable(), f.getValueReferenceTable(), f.getId()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.org")) { //else if field is event resource
            final long systemListNumber = (f.getEventResourceSystemListId() == 1 || f.getEventResourceSystemListId() == 2) ? 1 : f.getEventResourceSystemListId();
            selectFields.append(String.format("(select name from \"systemList_%s\" where id = flow.project_process_step_event.resource_id) as \"%s\", ", systemListNumber, f.getId()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.project_process_step") || Objects.equals(f.getReferenceTable(), "flow.process_step")) {

            var joinTable = f.getReferenceTable();
            if (isAdditionalPs) {
              //see if this PPS table has already been joined
              // if so reuse the table, if not join it
              if (isPsAlreadyJoined(valueJoins.toString(), f.getProcessStepId())) {
                //if ref table if process step, join here and that becomes join table
                if (Objects.equals(f.getReferenceTable(), "flow.process_step")) {
                  joinTable = UUID.randomUUID().toString();
                  valueJoins.append(String.format(" left join flow.process_step \"%s\" on \"%s\".id = \"%s\".process_step_id ", joinTable, joinTable, f.getPpsTable()));
                  joinTable = String.format("\"%s\"", joinTable);
                } else {
                  joinTable = String.format("\"%s\"", f.getPpsTable());
                }

              } else {
                valueJoins.append(joinPpsTable(f.getPpsTable(), f.getProcessStepId(), true));
                joinTable = String.format("\"%s\"", f.getPpsTable());
              }

            } else {
              f.setPpsTable("flow.project_process_step");
            }

            if (f.getDataTypeId() == 1) {
              selectFields.append(String.format(" to_char(%s.%s, 'YYYY-MM-DD') as \"%s\", ", joinTable, f.getReferenceColumn(), f.getId()));
            } else if (f.getDataTypeId() == 2) {
              if (null != timezone) {
                selectFields.append(String.format(" to_char(%s.%s at time zone \'UTC\' at time zone \'%s\', 'YYYY-MM-DD HH:MI am') as \"%s\", ", joinTable, f.getReferenceColumn(), timezone, f.getId()));
              }
              else {
                selectFields.append(String.format(" to_char(%s.%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", joinTable, f.getReferenceColumn(), f.getId()));
              }
            } else if (f.getDataTypeId() == 6 && Objects.equals(f.getHasListValues(), true)) {
              selectFields.append(String.format(" (select name from flow.list_of_value where id = %s.%s) as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else if (f.getDataTypeId() == 7) {
              selectFields.append(String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(%s.%s)), ',')) as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else {
              selectFields.append(String.format(" %s.%s as \"%s\", ", joinTable, f.getReferenceColumn(), f.getId()));
            }

          } else if (Objects.equals(f.getReferenceTable(), "flow.project_process_step_event") ||
            Objects.equals(f.getReferenceTable(), "flow.event") ||
            Objects.equals(f.getReferenceTable(), "flow.company_event_status_type") ||
            Objects.equals(f.getReferenceTable(), "flow.event_status_type")) {
            if (f.getDataTypeId() == 1) {
              selectFields.append(String.format(" to_char(%s.%s, 'YYYY-MM-DD') as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else if (f.getDataTypeId() == 2) {
              if (null != timezone) {
                selectFields.append(String.format(" to_char(%s.%s at time zone \'UTC\' at time zone \'%s\', 'YYYY-MM-DD HH:MI am') as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), timezone, f.getId()));
              }
              else {
                selectFields.append(String.format(" to_char(%s.%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
              }
            } else if (f.getDataTypeId() == 6 && Objects.equals(f.getHasListValues(), true)) {
              selectFields.append(String.format(" (select name from flow.list_of_value where id = %s.%s) as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else if (f.getDataTypeId() == 7) {
              selectFields.append(String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(%s.%s)), ',')) as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else {
              selectFields.append(String.format(" %s.%s as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            }
          } else {
            //PS and event custom fields
            var valueTable = "";
            if (f.getObjectTypeId() == 4) {
              valueTable = f.getValueReferenceTable();
            } else if (f.getObjectTypeId() == 6) {
              valueTable = f.getValueEventReferenceTable();
            }
            selectFields.append(addSelectCustomField(f.getDataTypeId(), valueTable, f.getId().toString(), f.getHasListValues(), timezone));
          }
        } else if (f.getSystemListId() != null) {
          //system list fields
          final long systemListNumber = (f.getSystemListId() == 1 || f.getSystemListId() == 2) ? 1 : f.getSystemListId();

          selectFields.append(String.format("(select name from \"systemList_%s\" where \"systemList_%s\".id = \"%s\".int_value) as \"%s\", ", systemListNumber, systemListNumber, f.getValueReferenceTable(), f.getId()));
        } else {
          if (f.getCustomFieldSql() != null) {
            //custom sql fields
            selectFields.append(String.format("\"%s\".name as \"%s\", ", f.getValueReferenceTable(), f.getId()));
          } else {
            //project and contact fields
            if (f.getCustomFieldGroupAssignmentId() != null) {
              //system fields
              if (f.getDataTypeId() == 1) {
                selectFields.append(String.format(" to_char(\"%s\".%s, 'YYYY-MM-DD') as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else if (f.getDataTypeId() == 2) {
                selectFields.append(String.format(" to_char(\"%s\".%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else if (f.getDataTypeId() == 6 && f.getHasListValues()) {
                selectFields.append(String.format(" (select name from flow.list_of_value where id = \"%s\".%s) as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else if (f.getDataTypeId() == 7) {
                selectFields.append(String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(\"%s\".%s)), ',')) as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else {
                selectFields.append(String.format(" \"%s\".%s as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              }
            } else {
              if (Objects.equals(f.getReferenceTable(), "flow.project_user") || Objects.equals(f.getReferenceTable(), "flow.contact_user")) {
                selectFields.append(String.format("%s as \"%s\", ", f.getReferenceColumn(), f.getId()));
              } else {
                selectFields.append(String.format("%s.%s as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
              }
            }
          }
        }
      }

      // remove comma and space from last field
      selectFields.deleteCharAt(selectFields.length() - 2);

      withClause.append("select ").append(selectFields);

      withClause.append(addFromClause(smartlist.getObjectTypeId(), eventField.getProcessStepEventId(), null));

      StringBuilder whereClause = new StringBuilder();

      requirements.stream()
                  .filter(r -> {
                    final boolean isSameEvent = r.getProcessStepEventId() != null && r.getProcessStepEventId().equals(eventField.getProcessStepEventId());
                    final boolean isSamePs = r.getProcessStepId() != null && r.getProcessStepId().equals(eventField.getProcessStepId());
                    return isSameEvent || isSamePs;
                  })
                  .forEach(r -> {

                    String referenceLocation = null;

                    SmartlistFieldAssignment alreadyJoinedValueTable = eventFields.stream()
                                                                                  .filter(f -> r.getCustomFieldSql() == null && r.getCustomFieldGroupAssignmentId() != null && r.getCustomFieldGroupAssignmentId().equals(f.getCustomFieldGroupAssignmentId()))
                                                                                  .findFirst()
                                                                                  .orElse(null);

                    //join any value tables the requirements need which aren't already joined
                    if (r.getCustomFieldSql() == null) {
                      if (alreadyJoinedValueTable == null) {
                        if (r.getCustomFieldGroupAssignmentId() != null) {
                          //join the value table for the respective field object type
                          if (r.getObjectTypeId() == 1) {
                            valueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), "flow.project", false));
                          } else if (r.getObjectTypeId() == 2) {
                            valueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), "flow.contact", false));
                          } else if (r.getObjectTypeId() == 4) {
                            r.setPpsTable("flow.project_process_step");
                            valueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable(), r.getPpsTable(), false));
                          } else if (r.getObjectTypeId() == 6) {
                            r.setPpsEventTable("flow.project_process_step_event");
                            valueJoins.append(joinValueTable(r.getObjectTypeId(), r.getCustomFieldGroupAssignmentId(), r.getValueEventReferenceTable(), r.getPpsEventTable(), false));
                          }
                        }
                      } else if (r.getCustomFieldGroupAssignmentId() != null) {
                        r.setValueReferenceTable(alreadyJoinedValueTable.getValueReferenceTable());
                        r.setValueEventReferenceTable(alreadyJoinedValueTable.getValueEventReferenceTable());
                      }
                    }

                    if (r.getSmartlistSystemListId() != null) {
                      //smartlist system list
                      if (List.of(1L, 3L, 5L).contains(r.getSmartlistSystemListId())) {
                        referenceLocation = String.format("%s.%s", r.getJoinTable(), r.getJoinColumn());
                      } else if (r.getSmartlistSystemListId() == 2) {
                        referenceLocation = "flow.company_process_step_status_type.id";
                      } else if (r.getSmartlistSystemListId() == 4) {
                        referenceLocation = "flow.company_process_step_status_type.process_step_status_type_id";
                      }
                      if (r.getSmartlistSystemListId() != 1) {
                        referenceLocation = String.format("array[%s]::int[]", referenceLocation);
                      }
                    } else if (r.getSmartlistFieldId() != null) {
                      //smartlist system fields
                      if (r.getObjectTypeId() == 1 || r.getObjectTypeId() == 2) {
                        if (Objects.equals(r.getReferenceTable(), "flow.project_user")) {
                          referenceLocation = "\"project_user_position\".id";
                        } else if (Objects.equals(r.getReferenceTable(), "flow.contact_user")) {
                          referenceLocation = "\"contact_user_position\".id";
                        } else {
                          referenceLocation = r.getReferenceTable() + "." + r.getReferenceColumn();
                        }
                      } else if (r.getObjectTypeId() == 4) {
                        String joinTable;
                        try {
                          joinTable = fields.stream()
                                            .filter(f -> Objects.equals(f.getCustomFieldGroupAssignmentId(), r.getCustomFieldGroupAssignmentId()))
                                            .map(SmartlistFieldAssignment::getValueReferenceTable)
                                            .findFirst()
                                            .orElse(null);

                          if (joinTable == null) {
                            joinTable = UUID.randomUUID().toString();
                          }
                        } catch (NullPointerException e) {
                          joinTable = UUID.randomUUID().toString();
                        }

                        if (r.getReferenceTable() != null && r.getReferenceTable().equals("flow.user")) {
                          // Since this is a process step smartlist field, if it's looking at the user table, it's the process step owner field
                          referenceLocation = "flow.project_process_step.user_position_id";
                        } else if (r.getReferenceTable().contains(".")) {
                          referenceLocation = String.format("%s.%s", r.getReferenceTable(), r.getReferenceColumn());
                        } else {
                          referenceLocation = String.format("\"%s\".%s", joinTable, r.getReferenceColumn());
                        }
                      } else if (r.getObjectTypeId() == 6) {
                        if (Objects.equals(r.getReferenceTable(), "flow.org")) {// if field is event resource
                          referenceLocation = r.getJoinTable() + "." + r.getJoinColumn();
                        } else if (r.getReferenceTable().equals("flow.company_event_status_type")) {
                          referenceLocation = r.getReferenceTable() + ".id";
                        } else if (r.getReferenceTable().equals("flow.event_status_type")) {
                          referenceLocation = r.getReferenceTable() + ".id";
                        } else if (r.getReferenceTable().contains(".")) {
                          referenceLocation = String.format("%s.%s", r.getReferenceTable(), r.getReferenceColumn());
                        }
                      }
                    } else {
                      //custom fields
                      if (r.getCustomFieldSql() != null) {
                        //custom sql fields
                        if (valueJoins.indexOf(r.getCustomFieldSqlKey()) == -1) {
                          r.setValueReferenceTable(UUID.randomUUID().toString());
                          final String referenceTable = UUID.randomUUID().toString();

                          if (r.getObjectTypeId() == 1) {
                            valueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId()));
                          } else if (r.getObjectTypeId() == 2) {
                            valueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId()));
                          } else if (r.getObjectTypeId() == 4) {
                            valueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = flow.project_process_step.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId()));
                          }

                          valueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value", r.getCustomFieldSqlKey(), r.getValueReferenceTable(), r.getValueReferenceTable(), referenceTable));
                        } else {
                          SmartlistFieldAssignment joinedField = fields.stream()
                                                                       .filter(f -> Objects.equals(r.getCustomFieldGroupAssignmentId(), f.getCustomFieldGroupAssignmentId()))
                                                                       .findFirst()
                                                                       .orElse(null);

                          //joinedField **shouldn't** ever be null here. If it is, there are bigger issues
                          if (joinedField != null) {
                            r.setValueReferenceTable(joinedField.getValueReferenceTable());
                          }
                        }

                        referenceLocation = String.format("\"%s\".id", r.getValueReferenceTable());
                      } else if (r.getCompanySystemListId() != null) {
                        //system list fields
                        final long systemListNumber = (r.getSystemListId() == 1 || r.getSystemListId() == 2) ? 1 : r.getSystemListId();
                        final String systemListTable = "systemList_" + systemListNumber;

                        //Currently, we don't check if the system list is already joined on this cfgaId. We could do that to eliminate potential duplicates
                        final String newValueTable = UUID.randomUUID().toString();
                        valueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".%s", systemListTable, newValueTable, newValueTable, r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId())));
                        r.setValueReferenceTable(newValueTable);

                        referenceLocation = String.format("\"%s\".id", newValueTable);
                      } else {
                        referenceLocation = String.format("\"%s\".%s", (r.getObjectTypeId() == 6) ? r.getValueEventReferenceTable() : r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId()));
                      }
                    }

                    Object requirementValue = getRequirementValue(r);
                    String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId(), r.getDataTypeRequirement());

                    //Check for double negative with "nots" between operator and requirement
                    if (r.getDataTypeRequirementId() != null) {
                      if (requirementValue != null && requirementValue.toString().contains("not") && operator != null && operator.contains("not")) {
                        operator = operator.replace("not", "");

                        if (List.of(5L, 13L, 17L, 19L, 21L, 25L, 27L).contains(r.getDataTypeRequirementId())) {
                          requirementValue = requirementValue.toString().replace("not", "");
                        }
                      }
                    }

                    if (r.getDataTypeId() == 7) {
                      if (r.getDataTypeRequirementId() != null) {
                        whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
                      } else {
                        whereClause.append(String.format(" sort(%s) %s sort(array%s::int[]) and ", referenceLocation, operator, requirementValue));
                      }
                    } else if (r.getDataTypeId() == 3 || r.getDataTypeId() == 4 || (r.getDataTypeRequirementId() != null && r.getSecondaryRequirementValue() == null && r.getDataTypeId() != 1 && r.getDataTypeId() != 2)) {
                      //if this is a text requirement using null/not null requirement
                      if ((r.getDataTypeId() == 5 || r.getDataTypeId() == 13) && r.getDataTypeRequirementId() != null) {
                        //treat empty strings as null
                        whereClause.append(String.format(" nullif(trim(%s), '') %s %s and ", referenceLocation, operator, requirementValue));
                      } else {
                        whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
                      }
                    } else {
                      if (requirementValue instanceof String && requirementValue.toString().contains("null")) {
                        whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
                      } else {
                        if (r.getDataTypeRequirementId() != null && List.of(1L, 2L, 3L, 6L, 7L, 8L).contains(r.getDataTypeRequirementId())) {
                          whereClause.append(String.format(" date_trunc('day', %s) %s date_trunc('day', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
                        } else if (r.getDataTypeRequirementId() != null && List.of(9L, 10L, 11L).contains(r.getDataTypeRequirementId())) {
                          whereClause.append(String.format(" date_trunc('hour', %s) %s date_trunc('hour', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
                        } else {
                          if (r.getSmartlistSystemListId() != null) {
                            whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
                          } else {
                            // If this field is process step owner, make sure we're getting past instances where this user had the same position and not just the current primary position
                            if (r.getObjectTypeId() == 4 && Objects.equals(r.getReferenceTable(), "flow.user")) {
                              final String positionSubquery = String.format("select id from flow.user_position where user_id = (select user_id from flow.user_position where id = %s)", requirementValue);
                              whereClause.append(String.format(" %s = any(%s) and ", referenceLocation, positionSubquery));
                            } else {
                              whereClause.append(String.format(" %s %s '%s' and ", referenceLocation, operator, requirementValue));
                            }
                          }
                        }
                      }
                    }
                  });

      withClause.append(valueJoins);

      final String companySubquery = String.format("select id from flow.company where id = %s or parent_company_id = %s", companyId, companyId);

      if (whereClause.length() > 0) {
        whereClause.append(String.format("flow.process_step.company_id = any(%s)", companySubquery));
        whereClause.append(" and flow.project_process_step.project_id = any(array[\"projects\".id])");

        withClause.append(String.format(" where %s", whereClause));
      } else {
        withClause.append(" where flow.project_process_step.project_id = any(array[\"projects\".id])");
        withClause.append(String.format(" and flow.process_step.company_id = any(%s)", companySubquery));
      }

      if (smartlist.isMainProcessSteps()) {
        withClause.append(" and flow.project_process_step.main is true");
      }

      query.append(String.format("%s), ", withClause));
    }

    // remove comma and space from with clause
    query.delete(query.length() - 2, query.length());

    List<SmartlistFieldAssignment> sortedFields = fields.stream()
                                                        .sorted(Comparator.comparing(SmartlistFieldAssignment::getDisplayOrder))
                                                        .toList();

    usedProcessStepEvents.forEach(usedField -> {

      Optional<SmartlistFieldAssignment> eventField = fields.stream().filter(f -> Objects.equals(f.getProcessStepEventId(), usedField.getProcessStepEventId())).findFirst();

      StringBuilder selectClause = new StringBuilder(" select ");

      sortedFields.forEach(f -> {
        if (f.getProcessStepEventId() != null) {
          f.setName(f.getName() + " - " + f.getEventName());

          if (f.getProcessStepEventId().equals(usedField.getProcessStepEventId())) {
            selectClause.append(String.format("\"%s\".\"%s\" as \"%s\", ", f.getEventName() + f.getProcessStepEventId(), f.getId(), f.getName()));
          } else {
            selectClause.append(String.format("null as \"%s\", ", f.getName()));
          }
        } else if (f.getProcessStepId() != null) {
          if (f.getProcessStepId().equals(usedField.getProcessStepId())) {
            selectClause.append(String.format("\"%s\".\"%s\" as \"%s\", ", eventField.get().getEventName() + eventField.get().getProcessStepEventId(), f.getId(), f.getName()));
          } else if (additionalPsFields.contains(f)) {
            selectClause.append(String.format("\"%s\".\"%s\" as \"%s\", ", eventField.get().getEventName() + eventField.get().getProcessStepEventId(), f.getId(), f.getName()));
          } else {
            selectClause.append(String.format("null as \"%s\", ", f.getName()));
          }
        } else {
          //project and contact fields
          eventField.ifPresent(field -> selectClause.append(String.format("\"%s\".\"%s\" as \"%s\", ", field.getEventName() + field.getProcessStepEventId(), f.getId(), f.getName())));
        }
      });

      // remove comma and space from select clause
      selectClause.deleteCharAt(selectClause.length() - 2);

      query.append(selectClause);

      StringBuilder fromClause = new StringBuilder(" from ");


      eventField.ifPresent(f -> fromClause.append(String.format("\"%s%s\"", f.getEventName(), f.getProcessStepEventId())));

      query.append(fromClause).append(" union ");
    });

    // remove comma and space from with clause
    query.delete(query.length() - 7, query.length());

    query.append(";");

    return query.toString();
  }

  public String buildProjectDetailsSql(Smartlist smartlist, List<SmartlistFieldAssignment> fields, List<SmartlistRequirement> requirements, Integer limit) {

    StringBuilder query = new StringBuilder();

    String sqlQuery = sqlCacheRO.queryForObjectBySql(CustomFieldQuery.getCustomFieldSql, Collections.emptyMap(), String.class);
    query.append(String.format(" with \"customFieldSql.brs.ahjList\" as (%s), ", sqlQuery));
    query.append("\"customFieldSql.brs.utilityCompanyList\" as (select a.id, a.name::text from brs.feat_db_utility a where archived is not true) ");



    query.append(" select");

    for (SmartlistFieldAssignment f : fields) {
      if (f.getDataTypeId() == 1) {
        query.append(String.format(" to_char(brs.project_details.%s, 'YYYY-MM-DD') as \"%s\", ", f.getProjectDetailsColumn(), f.getName()));
      } else if (f.getDataTypeId() == 2) {
        query.append(String.format(" to_char(brs.project_details.%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", f.getProjectDetailsColumn(), f.getName()));
      } else if (f.getCustomFieldSql() != null) {
        query.append(String.format(" \"%s\".name as \"%s\", ", f.getCustomFieldSqlKey(), f.getName()));
      } else {
        query.append(String.format(" brs.project_details.%s as \"%s\", ", f.getProjectDetailsColumn(), f.getName()));
      }
    }

    // Remove comma and space from last select field
    query.deleteCharAt(query.length() - 2);

    // @TODO: Eventually de-hardcode brs schema
    query.append(" from brs.project_details");
    query.append(" inner join flow.project on flow.project.id = brs.project_details.project_id");

    query.append(" left join \"customFieldSql.brs.ahjList\" on \"customFieldSql.brs.ahjList\".id = brs.project_details.ahj");
    query.append(" left join \"customFieldSql.brs.utilityCompanyList\" on \"customFieldSql.brs.utilityCompanyList\".id = brs.project_details.utility_company");

    query.append(" where");

    // If user is in a parent company, get all rows. else if user is the child, limit rows to that company
    User user = securityService.getCurrentUser();
    boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());

    if (inParentCompany) {
      query.append(String.format(" brs.project_details.company_id = any(select id from flow.company c where (c.id = %s or c.parent_company_id = %s) and c.archived is not true) and ", user.getCompanyId(), user.getCompanyId()));
    } else {
      query.append(String.format(" brs.project_details.company_id = %s and ", user.getCompanyId()));
    }

    for (SmartlistRequirement r : requirements) {
      String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId(), r.getDataTypeRequirement());
      Object requirementValue = getRequirementValue(r);

      //Check for double negative with "nots" between operator and requirement
      if (r.getDataTypeRequirementId() != null) {
        if (requirementValue != null && requirementValue.toString().contains("not") && operator != null && operator.contains("not")) {
          operator = operator.replace("not", "");

          if (List.of(5L, 13L, 17L, 19L, 21L, 25L, 27L).contains(r.getDataTypeRequirementId())) {
            requirementValue = requirementValue.toString().replace("not", "");
          }
        }
      }

      if (Objects.equals(r.getHasListValues(), true)) {
        var matchedListItem = r.getAvailableListOfValues().stream()
                               .filter(req -> Objects.equals(req.getId(), r.getListOfValueId()))
                               .findFirst()
                               .orElse(null);

        if (matchedListItem != null) {
          requirementValue = matchedListItem.getName();
        }
      }

      if (r.getDataTypeId() == 7) {
        if (r.getDataTypeRequirementId() != null) {
          query.append(String.format(" brs.project_details.%s %s %s and ", r.getProjectDetailsColumn(), operator, requirementValue));
        } else {
          query.append(String.format(" sort(brs.project_details.%s) %s sort(array%s::int[]) and ", r.getProjectDetailsColumn(), operator, requirementValue));
        }
      } else if (r.getDataTypeId() == 3 || r.getDataTypeId() == 4 || (r.getDataTypeRequirementId() != null && r.getSecondaryRequirementValue() == null && r.getDataTypeId() != 1 && r.getDataTypeId() != 2)) {
        query.append(String.format(" brs.project_details.%s %s %s and ", r.getProjectDetailsColumn(), operator, requirementValue));
      } else {
        if (requirementValue instanceof String && requirementValue.toString().contains("null")) {
          query.append(String.format(" brs.project_details.%s %s %s and ", r.getProjectDetailsColumn(), operator, requirementValue));
        } else {
          query.append(String.format(" brs.project_details.%s %s '%s' and ", r.getProjectDetailsColumn(), operator, requirementValue));
        }
      }
    }

    // remove the last "and "
    query = query.delete(query.length() - 5, query.length());

    if (limit != null) {
      query.append(String.format(" limit %s", limit));
    }

    query.append(";");

    return query.toString();
  }

  private String getReferenceTable(Long objectTypeId) {
    switch (objectTypeId.intValue()) {
      case 1:
        return "flow.project_custom_field_value";
      case 2:
        return "flow.contact_custom_field_value";
      case 3:
        return "flow.user_custom_field_value";
      case 4:
        return "flow.project_process_step_custom_field_value";
      case 5:
        return "flow.organization_custom_field_value";
      default:
        return "";
    }
  }


  private String getReferenceColumn(Long dataTypeId) {
    //case 8 (system, customSqlKey) and 9 (system list) are handled elsewhere
    switch (dataTypeId.intValue()) {
      case 1:
        return "date_value";
      case 2:
        return "timestamp_value";
      case 3:
        return "boolean_value";
      case 4:
        return "numeric_value";
      case 5:
      case 13:
        return "text_value";
      case 6:
      case 9:
        return "int_value";
      case 7:
        return "int_array_value";
      default:
        return "";
    }
  }

  //@TODO humes: similar enough to project process step requirement stuff that could possibly be merged at some point
  private Object getRequirementValue(SmartlistRequirement r) {

    String requirementValue = r.getRequirementValue();

    switch (r.getDataTypeId().intValue()) {
      case 1:
        if (r.getIsCustomValue() && r.getSecondaryRequirementValue() == null) {
          LocalDate dateValue = (requirementValue != null) ? LocalDate.parse(requirementValue) : null;
          return dateValue;
        }

        LocalDate nowDate = LocalDate.now();
        String secondaryDateValue = r.getSecondaryRequirementValue();

        switch (r.getDataTypeRequirementId().intValue()) {
          case 1:
            return nowDate.minusDays(Long.parseLong(secondaryDateValue));
          case 2:
            return nowDate.plusDays(Long.parseLong(secondaryDateValue));
          case 3:
            return nowDate;
          case 4:
          case 5:
            return r.getDataTypeRequirement().getDataTypeValue();
        }
        break;
      case 2:
        if (r.getIsCustomValue()) {
          LocalDateTime dateTimeValue = (requirementValue != null) ? LocalDateTime.parse(requirementValue).withSecond(0).withNano(0) : null;
          return dateTimeValue;
        }

        LocalDateTime nowDateTime = LocalDateTime.now().withMinute(0).withSecond(0).withNano(0);
        String secondaryDateTimeValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;

        switch (r.getDataTypeRequirementId().intValue()) {
          case 6:
            return nowDateTime.minusDays(Long.parseLong(secondaryDateTimeValue));
          case 7:
            return nowDateTime.plusDays(Long.parseLong(secondaryDateTimeValue));
          case 8:
            return nowDateTime.withHour(0);
          case 9:
            return nowDateTime.minusHours(Long.parseLong(secondaryDateTimeValue));
          case 10:
            return nowDateTime.plusHours(Long.parseLong(secondaryDateTimeValue));
          case 11:
            return nowDateTime;
          case 12:
          case 13:
            return r.getDataTypeRequirement().getDataTypeValue();
        }
        break;

      case 3:
        return r.getDataTypeRequirement().getDataTypeValue();
      case 4:
        if (r.getIsCustomValue()) {
          BigDecimal tempNumericVal = (requirementValue == null) ? null : new BigDecimal(requirementValue);
          Double numericReqValue = (tempNumericVal == null) ? null : tempNumericVal.setScale(2, RoundingMode.DOWN).doubleValue();
          return numericReqValue;
        }

        return r.getDataTypeRequirement().getDataTypeValue();
      case 5:
      case 13:
        if (r.getSmartlistSystemListId() != null && r.getListOfValueId() != null) {
          return String.format("sort(array[%s]::int[])", r.getListOfValueId());
        }
        if (r.getIsCustomValue() && requirementValue != null) {
          return requirementValue;
        }
        return r.getDataTypeRequirement().getDataTypeValue();
      case 6:
        if (r.getIsCustomValue()) {
          if (r.getHasListValues() != null && r.getHasListValues() && r.getListOfValueId() != null) {
            return r.getListOfValueId();
          }
          else {
            return (requirementValue != null) ? Long.parseLong(requirementValue) : r.getDataTypeRequirement().getDataTypeValue();
          }
        }
        return r.getDataTypeRequirement().getDataTypeValue();
      case 7:
        if (r.getIsCustomValue()) {
          return r.getListOfValueIds();
        }
        return r.getDataTypeRequirement().getDataTypeValue();
      case 8:
      case 9:
        if (r.getIsCustomValue()) {
          return r.getListOfValueId();
        }

        return r.getDataTypeRequirement().getDataTypeValue();
      default:
        return null;
    }
    return null;
  }

  private String getSqlOperator(Long operatorTypeId, Long dataTypeId, DataTypeRequirement r) {

    // List of whether the dataTypeRequirementId is being compared to `null` or `not null`
    List<Long> nullableIds = List.of(4L, 5L, 12L, 13L, 16L, 17L, 18L, 19L, 20L, 21L, 22L, 23L, 24L, 25L, 26L, 27L, 30L, 31L);

    switch (operatorTypeId.intValue()) {
      case 1:
        //If field is boolean, this is the only option
        if (dataTypeId == 3) {
          return "is";
        }

        // If field is a dataTypeRequirement
        if (r != null) {
          if (nullableIds.contains(r.getId())) {
            return "is";
          } else {
            return "=";
          }
        } else {
          return "=";
        }
      case 2:
        //If field is boolean, this is the only option
        if (dataTypeId == 3) {
          return "is not";
        }

        // If field is a dataTypeRequirement
        if (r != null) {
          if (nullableIds.contains(r.getId())) {
            return "is not";
          } else {
            return "!=";
          }
        } else {
          return "!=";
        }
      case 3:
        return ">";
      case 4:
        return "<";
      case 5:
        return "<@";
      default:
        //@TODO: blow up?
        return null;
    }
  }

  private String addFromClause(Long smartlistObjectTypeId, Long limitingId, Long workQueueTypeId) {
    var join = " from";

    if (smartlistObjectTypeId == 4) {
      join += " flow.project_process_step";
    } else if (smartlistObjectTypeId == 6) {
      if(null == workQueueTypeId) {
        join += " flow.project_process_step_event ";
      } else {
        join += " flow.work_queue_cycle wqc ";
        join += " inner join flow.project_process_step_event on flow.project_process_step_event.id = wqc.project_process_step_event_id ";
      }
      join += " inner join flow.process_step_event on flow.process_step_event.id = flow.project_process_step_event.process_step_event_id ";
      if (smartlistObjectTypeId == 6 && limitingId != null) {
        join += " and process_step_event.id = " + limitingId;
      }
      join += " inner join flow.event on flow.event.id = flow.process_step_event.event_id ";
      join += " inner join flow.project_process_step on flow.project_process_step.id = flow.project_process_step_event.project_process_step_id ";
      join += " inner join flow.company_event_status_type on company_event_status_type.id = flow.project_process_step_event.company_event_status_type_id ";
      join += " inner join flow.event_status_type on flow.event_status_type.id = flow.company_event_status_type.event_status_type_id ";

      if (workQueueTypeId != null) {
        join += " left join flow.process_step_event_work_queue_type on flow.process_step_event_work_queue_type.process_step_event_id = flow.process_step_event.id and flow.process_step_event_work_queue_type.work_queue_type_id = " + workQueueTypeId + " ";
      }
    }

    join += " inner join flow.company_process_step_status_type on flow.company_process_step_status_type.id = flow.project_process_step.company_process_step_status_type_id";
    join += " inner join flow.process_step_status_type on flow.process_step_status_type.id = flow.company_process_step_status_type.process_step_status_type_id";
    join += " inner join flow.process_step on process_step.id = project_process_step.process_step_id";

    if (limitingId != null) {
      // PS smartlists
      if (smartlistObjectTypeId == 4) {
        join += " and process_step.id = " + limitingId;
      }

      join += " inner join \"projects\" on \"projects\".id = flow.project_process_step.project_id";
      join += " inner join flow.project on flow.project.id = \"projects\".id";
    } else {
      // workqueue smartlists
      join += " inner join flow.project on flow.project.id = flow.project_process_step.project_id";
    }

    join += " left join flow.user_position \"project_user_position\" on \"project_user_position\".id = flow.project.user_position_id";
    join += " left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id";
    join += " inner join flow.company_project_status_type on flow.company_project_status_type.id = flow.project.company_project_status_type_id";
    join += " inner join flow.project_status_type on flow.project_status_type.id = flow.company_project_status_type.project_status_type_id";
    join += " inner join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true";
    join += " left join flow.user_position \"contact_user_position\" on \"contact_user_position\".id = flow.contact.owner_user_position_id";
    join += " left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id";

    return join;
  }

  /**
   * Creates a left join string to a custom_field_value table based off `objectTypeId`. Assumes `objectTable` is already joined
   *
   * @param objectTypeId Object type ID of the field the joining value table points to
   * @param cfgaId       Custom field group assignment ID of the field the joining value table points to
   * @param valueTable   UUID string of the custom_field_value table being joined
   * @param objectTable  String (UUID string for process step and event fields when smartlist is NOT event/process step) to the object type specific joining table
   * @return a sql snippet
   */
  private String joinValueTable(Long objectTypeId, Long cfgaId, String valueTable, String objectTable, Boolean isWorkQueue) {

    var join = "";
    var baseObjectTable = "";
    var baseJoinColumn = "";

    boolean isUUID;

    try {
      UUID.fromString(objectTable);
      isUUID = true;
    } catch (Exception e) {
      isUUID = false;
    }

    if (objectTypeId == 6) {
      baseObjectTable = "project_process_step_event";
      baseJoinColumn = "project_process_step_event_id";

      //not sure we actually need to check for objectTable being a uuid here. I think on an event field, we will always pass in a uuid
      if (isUUID) {
        if (isWorkQueue) {
          var casePart = String.format("case when \"%s\".process_step_event_id != flow.process_step_event.id then \"%s\".id else flow.project_process_step_event.id end", objectTable, objectTable);
          join = String.format(" left join flow.%s_custom_field_value \"%s\" on \"%s\".custom_field_group_assignment_id = %s and \"%s\".%s = %s ", baseObjectTable, valueTable, valueTable, cfgaId, valueTable, baseJoinColumn, casePart);
        } else {
          join = String.format(" left join flow.%s_custom_field_value \"%s\" on \"%s\".custom_field_group_assignment_id = %s and \"%s\".%s = \"%s\".id ", baseObjectTable, valueTable, valueTable, cfgaId, valueTable, baseJoinColumn, objectTable);
        }

      } else {
        join = String.format(" left join flow.%s_custom_field_value \"%s\" on \"%s\".%s = %s.id and \"%s\".custom_field_group_assignment_id = %s ", baseObjectTable, valueTable, valueTable, baseJoinColumn, objectTable, valueTable, cfgaId);
      }

    } else {
      var joinWithObjectTableQuotes = " left join flow.%s_custom_field_value \"%s\" on \"%s\".%s = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ";
      var joinWithoutObjectTableQuotes = " left join flow.%s_custom_field_value \"%s\" on \"%s\".%s = %s.id and \"%s\".custom_field_group_assignment_id = %s ";

      if (objectTypeId == 1) {
        baseObjectTable = "project";
        baseJoinColumn = "project_id";
      } else if (objectTypeId == 2) {
        baseObjectTable = "contact";
        baseJoinColumn = "contact_id";
      } else if (objectTypeId == 4) {
        baseObjectTable = "project_process_step";
        baseJoinColumn = "project_process_step_id";
      }

      if (isUUID) {
        join = String.format(joinWithObjectTableQuotes, baseObjectTable, valueTable, valueTable, baseJoinColumn, objectTable, valueTable, cfgaId);
      } else {
        join = String.format(joinWithoutObjectTableQuotes, baseObjectTable, valueTable, valueTable, baseJoinColumn, objectTable, valueTable, cfgaId);
      }
    }
    return join;
  }

  /**
   * Creates a left join string to a project_process_step table. Assumes `flow.project` is already joined
   *
   * @param ppsTable           UUID String of the project_process_step table
   * @param processStepId      Process Step ID of the project_process_step table
   * @param isMainProcessSteps If we want to select only the main project process step, or all
   * @return a sql string snippet
   */
  private String joinPpsTable(String ppsTable, Long processStepId, Boolean isMainProcessSteps) {
    var join = String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s and \"%s\".archived is not true ", ppsTable, ppsTable, ppsTable, processStepId, ppsTable);
    if (isMainProcessSteps == null || isMainProcessSteps) {
      join += String.format(" and \"%s\".main is true ", ppsTable);
    }
    return join;
  }

  /**
   * Creates a left join string to a project_process_step_event table. Assumes `ppsTable` is already joined
   *
   * @param ppsEventTable      UUID string of the project_process_step_event table
   * @param ppsTable           UUID string of the project_process_step table to join to
   * @param processStepEventId Process step event ID of the project_process_step_event table
   * @return a sql string snippet
   */
  private String joinPPsEventTable(String ppsEventTable, String ppsTable, Long processStepEventId, Boolean isWorkQueue) {
    var join = String.format(" left join flow.project_process_step_event \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".process_step_event_id = %s and \"%s\".archived is not true ", ppsEventTable, ppsEventTable, ppsTable, ppsEventTable, processStepEventId, ppsEventTable);

    if (isWorkQueue) {
      join += String.format("and \"%s\".process_step_event_id != flow.process_step_event.id ", ppsEventTable);
    }

    return join;
  }

  /**
   * Creates a select sql snippet based on an object type ID
   *
   * @param dataTypeId    Data type ID of the field being selected
   * @param valueTable    UUID String of the underlying value table
   * @param fieldLabel    Alias to name the field/column. Must be guaranteed unique within the overall generated query to avoid collisions.
   * @param hasListValues Is the field value being joined a list?
   * @return a sql snippet
   */
  //@TODO: This function name is no bueno. Needs some love
  private String addSelectCustomField(Long dataTypeId, String valueTable, String fieldLabel, Boolean hasListValues, String customTimezone) {
    var select = "";
    if (dataTypeId == 1) {
      select = String.format(" to_char(\"%s\".%s, 'YYYY-MM-DD') as \"%s\", ", valueTable, getReferenceColumn(dataTypeId), fieldLabel);
    } else if (dataTypeId == 2) {
      if (customTimezone != null) {
        select = String.format(" to_char(\"%s\".%s at time zone 'UTC' at time zone '%s', 'MM/DD/YYYY HH:MI am') as \"%s\", ", valueTable, getReferenceColumn(dataTypeId), customTimezone, fieldLabel);
      } else {
        select = String.format(" to_char(\"%s\".%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", valueTable, getReferenceColumn(dataTypeId), fieldLabel);
      }
    } else if (dataTypeId == 6 && hasListValues) {
      select = String.format(" (select name from flow.list_of_value where id = \"%s\".%s) as \"%s\", ", valueTable, getReferenceColumn(dataTypeId), fieldLabel);
    } else if (dataTypeId == 7) {
      select = String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(\"%s\".%s)), ',')) as \"%s\", ", valueTable, getReferenceColumn(dataTypeId), fieldLabel);
    } else if (dataTypeId == 8) {
      select = String.format(" \"%s\".name as \"%s\", ", valueTable, fieldLabel);
    } else {
      select = String.format(" \"%s\".%s as \"%s\", ", valueTable, getReferenceColumn(dataTypeId), fieldLabel);
    }
    return select;
  }

  //@TODO: finish header

  /**
   * @param query
   * @param processStepId
   * @return
   */
  private boolean isPsAlreadyJoined(String query, Long processStepId) {
    return query.contains(".process_step_id = " + processStepId);
  }

  //@TODO: finish header

  /**
   * @param query
   * @param psEventId
   * @return
   */
  private boolean isPsEventAlreadyJoined(String query, Long psEventId) {
    return query.contains(".process_step_event_id = " + psEventId);
  }

  //@TODO: still need to fill this in

  /**
   * @param item
   * @param searchItems
   * @param additionalSearchItems
   * @return
   */
  private String getPpsTable(SmartlistSuperField item, List<? extends SmartlistSuperField> searchItems, List<? extends SmartlistSuperField> additionalSearchItems) {
    final String ppsTable = searchItems.stream()
                                       .filter(i -> Objects.equals(i.getProcessStepId(), item.getProcessStepId()) && !i.getId().equals(item.getId()))
                                       .map(SmartlistSuperField::getPpsTable)
                                       .findFirst()
                                       .orElse(null);

    if (ppsTable == null && additionalSearchItems != null) {
      return additionalSearchItems.stream()
                                  .filter(i -> Objects.equals(i.getProcessStepId(), item.getProcessStepId()) && !i.getId().equals(item.getId()))
                                  .map(SmartlistSuperField::getPpsTable)
                                  .findFirst()
                                  .orElse(null);
    } else {
      return ppsTable;
    }
  }

  //@TODO: still need to fill this in

  /**
   * @param item
   * @param searchItems
   * @param additionalSearchItems
   * @return
   */
  private String getPpsEventTable(SmartlistSuperField item, List<? extends SmartlistSuperField> searchItems, List<? extends SmartlistSuperField> additionalSearchItems) {
    try {
      final String ppsEventTable = searchItems.stream()
                                              .filter(i -> Objects.equals(i.getProcessStepEventId(), item.getProcessStepEventId()) && !i.getId().equals(item.getId()))
                                              .map(SmartlistSuperField::getPpsEventTable)
                                              .findFirst()
                                              .orElse(null);

      if (ppsEventTable == null && additionalSearchItems != null) {
        return additionalSearchItems.stream()
                                    .filter(i -> Objects.equals(i.getProcessStepEventId(), item.getProcessStepEventId()) && !i.getId().equals(item.getId()))
                                    .map(SmartlistSuperField::getPpsEventTable)
                                    .findFirst()
                                    .orElse(null);
      } else {
        return ppsEventTable;
      }
    } catch (Exception e) {
      return null;
    }
  }
}
