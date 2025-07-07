package com.albatross.api.v1.flow.queries;

public class ProjectStatusQuery {

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
select cpst.id,
       cpst.project_status_type,
       cpst.display_order,
       cpst.description,
       cpst.icon_tag,
       cpst.is_default,
       cpst.is_milestone,
       pst.id                                                  as "projectStatusTypeId",
       cpst.archived,
       pst.project_status_type                                 as "rootProjectStatusType",
       (select coalesce(array_to_json(array_agg(occpst.object_category_id)), '[]')
        from flow.object_category_company_project_status_type occpst
        where occpst.company_project_status_type_id = cpst.id and occpst.archived is false) as "objectCategoryIds"
from flow.company_project_status_type cpst
         inner join flow.project_status_type pst on pst.id = cpst.project_status_type_id
where cpst.company_id = :companyId
  and cpst.archived is not true
order by cpst.display_order
    """;

  //language=PostgreSQL
  public final static String getCompanyStatusesForObjectCategory = """
select cpst.id,
       cpst.project_status_type,
       occpst.display_order,
       cpst.description,
       cpst.icon_tag,
       cpst.is_default,
       cpst.is_milestone,
       pst.id                                                  as "projectStatusTypeId",
       cpst.archived,
       pst.project_status_type                                 as "rootProjectStatusType",
       (select coalesce(array_to_json(array_agg(occpst.object_category_id)), '[]')
        from flow.object_category_company_project_status_type occpst
        where occpst.company_project_status_type_id = cpst.id and occpst.archived is false) as "objectCategoryIds"
from flow.company_project_status_type cpst
         inner join flow.project_status_type pst on pst.id = cpst.project_status_type_id
         inner join flow.object_category_company_project_status_type occpst on occpst.company_project_status_type_id = cpst.id
where cpst.company_id = :companyId
  and cpst.archived is not true
  and occpst.object_category_id = :objectCategoryId
  and occpst.archived = false
order by occpst.display_order;
    """;


  public final static String getCompanyStatusesForProjectId = """
select cpst.id,
       cpst.project_status_type,
       cpst.display_order,
       cpst.description,
       cpst.icon_tag,
       cpst.is_default,
       cpst.is_milestone,
       pst.id                           as "projectStatusTypeId",
       cpst.archived,
       pst.project_status_type          as "rootProjectStatusType",
       (select coalesce(array_to_json(array_agg(occpst.object_category_id)), '[]')
        from flow.object_category_company_project_status_type occpst
        where occpst.company_project_status_type_id = cpst.id
          and occpst.archived is false) as "objectCategoryIds"
from flow.company_project_status_type cpst
         inner join flow.project_status_type pst on pst.id = cpst.project_status_type_id
         inner join flow.object_category_company_project_status_type occpst
                    on cpst.id = occpst.company_project_status_type_id
                        and
                       occpst.object_category_id = (select object_category_id from flow.project where id = :projectId)
                        and occpst.archived is false
where cpst.company_id = :companyId
  and cpst.archived is false
order by cpst.display_order
    """;

  //language=PostgreSQL
  public final static String getOneCompanyStatus = """
    select
        cpst.id,
        cpst.project_status_type,
        cpst.description,
        cpst.display_order,
        cpst.icon_tag,
        cpst.is_default,
        cpst.is_milestone,
        pst.id as "projectStatusTypeId",
        cpst.archived,
        pst.project_status_type as "rootProjectStatusType",
    (select coalesce(array_to_json(array_agg(occpst.object_category_id)), '[]')
            from flow.object_category_company_project_status_type occpst
            where occpst.company_project_status_type_id = cpst.id and occpst.archived is false) as "objectCategoryIds"
    from flow.company_project_status_type cpst
    inner join flow.project_status_type pst on pst.id = cpst.project_status_type_id
    where cpst.id = :id
    """;

  //language=PostgreSQL
  public final static String getOneCompanyStatusOfObjectCategory = """
    select
        cpst.id,
        cpst.project_status_type,
        cpst.description,
        occpst.display_order,
        cpst.icon_tag,
        cpst.is_default,
        cpst.is_milestone,
        pst.id as "projectStatusTypeId",
        cpst.archived,
        pst.project_status_type as "rootProjectStatusType",
    (select coalesce(array_to_json(array_agg(occpst.object_category_id)), '[]')
            from flow.object_category_company_project_status_type occpst
            where occpst.company_project_status_type_id = cpst.id and occpst.archived is false) as "objectCategoryIds"
    from flow.company_project_status_type cpst
    inner join flow.project_status_type pst on pst.id = cpst.project_status_type_id
    inner join flow.object_category_company_project_status_type occpst on occpst.company_project_status_type_id = cpst.id
    where occpst.company_project_status_type_id = :cpstId and occpst.object_category_id = :objectCategoryId;
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
with project_status as (
    update flow.company_project_status_type
        set project_status_type = :projectStatusType,
            modified_by_id = :currentUserId,
            display_order = :displayOrder,
            icon_tag = trim(:iconTag),
            description = :description,
            is_milestone = :isMilestone,
            date_modified = now()
        where id = :id
        returning *),
     object_categories as (
         insert
             into flow.object_category_company_project_status_type (object_category_id, company_project_status_type_id,
                                                                    created_by_id, modified_by_id)
                 select c.id, att.id, att.created_by_id, att.modified_by_id
                 from project_status att
                          cross join (select unnest(:objectCategoryIds::int[]) as id) c
                 on conflict (object_category_id, company_project_status_type_id)
                     do update
                         set archived = false,
                             modified_by_id = excluded.modified_by_id,
                             date_modified = now()
                 returning *)
update flow.object_category_company_project_status_type ocat
set archived = true
from object_categories oc
where oc.company_project_status_type_id = ocat.company_project_status_type_id
  and ocat.object_category_id not in (select unnest(:objectCategoryIds::int[]))
    """;

  //language=PostgreSQL
  public final static String updateCompanyStatusOnDragAndDrop = """
    update flow.object_category_company_project_status_type
      set   display_order = :displayOrder , date_modified = now() , modified_by_id = :currentUserId
      where object_category_id=:objectCategoryId and company_project_status_type_id = :companyProjectStatusTypeId;
    """;


  //language=PostgreSQL
  public final static String getStatusInUseByProjects = """
    select count(1) > 0
    from flow.project p
    where company_project_status_type_id = :companyProjectStatusTypeId
    and p.archived is false
    limit 1
    """;

  //language=PostgreSQL
  public final static String getStatusInUseByActions = """
    select count(1) > 0
    from flow.process_step_action psa
           inner join flow.process_step ps on ps.id = psa.process_step_id
    where psa.archived is not true and ps.archived is not true
      and psa.company_project_status_type_id = :companyProjectStatusTypeId
    limit 1
    """;

  //language=PostgreSQL
  public final static String getStatusInUseByPseRequirements = """
    select count(1) > 0
    from flow.process_step_event_requirement pser
           inner join flow.process_step_event pse on pser.process_step_event_id = pse.id
           inner join flow.process_step ps on pse.process_step_id = ps.id
           inner join flow.event e on pse.event_id = e.id
    where pser.archived is false and pse.archived is false and pser.process_step_requirement_type_id = 9 and :companyProjectStatusTypeId = any (pser.list_of_value_ids)
    limit 1
    """;

  //language=PostgreSQL
  public final static String getStatusInUseByPsRequirements = """
    select count(1) > 0
    from flow.process_step_requirement psr
           inner join flow.process_step ps on psr.process_step_id = ps.id
    where psr.archived is false and psr.process_step_requirement_type_id = 9 and :companyProjectStatusTypeId = any (psr.list_of_value_ids)
    limit 1
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
with project_status as (
    insert into flow.company_project_status_type (project_status_type_id, project_status_type, company_id,
                                                  display_order, created_by_id, date_created,
                                                  modified_by_id, date_modified)
        values (:rootProjectStatusTypeId, :projectStatusType, :companyId,
                (select coalesce(max(display_order) + 1, 0)
                 from flow.company_project_status_type
                 where company_id = :companyId
                   and archived is not true), :currentUserId, now(), :currentUserId, now())
        returning *),
     object_categories as (
         insert
             into flow.object_category_company_project_status_type (object_category_id, company_project_status_type_id,
                                                                    created_by_id, modified_by_id,display_order)
                 select c.id, att.id, att.created_by_id, att.modified_by_id, coalesce(max_oc.display_order, 0)
                 from project_status att
                          cross join lateral unnest(:objectCategoryIds) as c(id)
                  left join lateral (
                              select max(display_order) + 1 as display_order
                              from flow.object_category_company_project_status_type
                              where object_category_id = c.id
                          ) max_oc on true
                 returning company_project_status_type_id)
select distinct company_project_status_type_id
from object_categories
limit 1;
    """;

  //language=PostgreSQL
  public final static String updateStatus = """
    update flow.project
    set company_project_status_type_id = :companyProjectStatusTypeId,
        date_modified = now(),
        modified_by_id = :userId
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

//  data view field stuff for milestones

  //language=PostgreSQL
  public final static String getStatusFieldAssignment = """
     select cpsfa.id,
            cpsfa.company_project_status_type_id,
            cpsfa.data_view_field_config_id,
            cpsfa.data_view_child_field_config_id,
            cpsfa.display_order,
            coalesce(dvcfc.display_name, dvfc.display_name) as field_name,
            cpsfa.archived
     from flow.company_project_status_field_assignment cpsfa
      left join flow.data_view_field_config dvfc on cpsfa.data_view_field_config_id = dvfc.id
      left join flow.data_view_child_field_config dvcfc on cpsfa.data_view_child_field_config_id = dvcfc.id
     where cpsfa.id = :id
     and cpsfa.archived is false
    """;

  //language=PostgreSQL
  public final static String getAssignedStatusFields = """
     select cpsfa.id,
            cpsfa.company_project_status_type_id,
            cpsfa.data_view_field_config_id,
            cpsfa.data_view_child_field_config_id,
            cpsfa.display_order,
            coalesce(dvcfc.display_name, dvfc.display_name) as field_name,
            cpsfa.archived
     from flow.company_project_status_field_assignment cpsfa
      left join flow.data_view_field_config dvfc on cpsfa.data_view_field_config_id = dvfc.id
      left join flow.data_view_child_field_config dvcfc on cpsfa.data_view_child_field_config_id = dvcfc.id
     where cpsfa.company_project_status_type_id = :companyProjectStatusTypeId
       and cpsfa.archived is false
     order by cpsfa.display_order
    """;

  //language=PostgreSQL
  public final static String insertStatusFieldAssignment = """
     insert into flow.company_project_status_field_assignment(company_project_status_type_id, data_view_field_config_id, data_view_child_field_config_id, display_order, created_by_id, modified_by_id)
     values(:companyProjectStatusTypeId, :dataViewFieldConfigId, :dataViewChildFieldConfigId, COALESCE((SELECT MAX(display_order) + 1 FROM flow.company_project_status_field_assignment), 1), :userId, :userId);
    """;

  //language=PostgreSQL
  public final static String saveStatusFieldAssignmentOrder = """
     update flow.company_project_status_field_assignment
      set display_order = :displayOrder,
          modified_by_id = :userId,
          date_modified = now()
      where id = :id
    """;

  //language=PostgreSQL
  public final static String archiveField = """
     update flow.company_project_status_field_assignment
      set archived = true,
          modified_by_id = :userId,
          date_modified = now()
      where id = :id
    """;
}
