package com.albatross.api.v1.company.blueraven.controllers.proposal.query;

public class ProposalToolQuery {

  //language=PostgreSQL
  public static final String findAllByCompanyCount = """
    select count(1)
    from brs.proposal_version v
             inner join flow.user cu on v.created_by_id = cu.id
             inner join flow.user mu on v.modified_by_id = mu.id
    where v.company_id = :companyId
    """;

  //language=PostgreSQL
  public static final String findAllByCompany = """
    select v.*,
           concat(cu.first_name, ' ', cu.last_name)                                  as created_by,
           concat(mu.first_name, ' ', mu.last_name)                                  as modified_by,
           case when pcpv.proposal_version_id is not null then true else false end as primary_version
    from brs.proposal_version v
             inner join flow.user cu on v.created_by_id = cu.id
             inner join flow.user mu on v.modified_by_id = mu.id
             left join brs.primary_company_proposal_version pcpv
                       on v.id = pcpv.proposal_version_id and v.company_id = pcpv.company_id
    where v.company_id = :companyId
    order by v.id desc
    limit :limit
    offset :offset
    """;

  //language=PostgreSQL
  public static final String findById = """
    select v.*,
           concat(cu.first_name, ' ', cu.last_name)                                  as created_by,
           concat(mu.first_name, ' ', mu.last_name)                                  as modified_by,
           case when pcpv.proposal_version_id is not null then true else false end as primary_version
    from brs.proposal_version v
             inner join flow.user cu on v.created_by_id = cu.id
             inner join flow.user mu on v.modified_by_id = mu.id
             left join brs.primary_company_proposal_version pcpv
                       on v.id = pcpv.proposal_version_id and v.company_id = pcpv.company_id
    where v.id = :id
    """;

  //language=PostgreSQL
  public static final String findObjectTypes = """
    select ot.id, ot.object_type as name, ot.object_code as code
    from brs.object_type ot
    where ot.parent_id = (select id from brs.object_type where object_code = 'PROPOSAL')
      and ot.archived is false
    """;

  //language=PostgreSQL
  public static final String findProposalFieldsByObjectCode = """
    select cf.id,
           cf.field_name,
           cf.field_code,
           cfga.field_order
    from brs.custom_field cf
             inner join brs.custom_field_group_assignment cfga
                        on cf.id = cfga.custom_field_id
             inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
             inner join brs.object_type ot on cfg.object_type_id = ot.id
    where ot.object_code = :objectCode
      and ot.archived is false
      and cf.archived is false
      and cfga.archived is false
    order by cfg.group_order, cfga.field_order
    """;

  //language=PostgreSQL
  public static final String proposalVersionCustomFieldValues = """
    with version_values as (
        select distinct on ( proposal_group_uuid, custom_field_group_assignment_id ) id,
                                                                             custom_field_group_assignment_id,
                                                                             proposal_group_uuid,
                                                                             proposal_version_id,
                                                                             value,
                                                                             field_id,
                                                                             field_code,
                                                                             modified_by_id,
                                                                             modified_by,
                                                                             date_modified
        from brs.proposal_version_custom_field_value_vw
        where proposal_version_id <= :versionId
          and object_code = :objectCode
          and proposal_group_uuid not in (
            select distinct proposal_group_uuid
            from brs.proposal_version_custom_field_group
            where archived is not null
              and proposal_version_id <= :versionId)
        order by proposal_group_uuid, custom_field_group_assignment_id, id desc)
    select json_build_object('pk',  proposal_group_uuid, 'versionId', max(proposal_version_id))::jsonb || json_object_agg(field_id, value)::jsonb as row
    from version_values
    group by proposal_group_uuid
     """;

  //language=PostgreSQL
  public static final String proposalVersionCustomFieldValuesByUUID = """
    with version_values as (
        select distinct on ( proposal_group_uuid, custom_field_group_assignment_id ) id,
                                                                             custom_field_group_assignment_id,
                                                                             proposal_group_uuid,
                                                                             proposal_version_id,
                                                                             value,
                                                                             field_id,
                                                                             field_code,
                                                                             modified_by_id,
                                                                             modified_by,
                                                                             date_modified
        from brs.proposal_version_custom_field_value_vw
        where proposal_version_id <= :versionId
          and object_code = :objectCode
        order by proposal_group_uuid, custom_field_group_assignment_id, id desc)
    select json_build_object('pk',  proposal_group_uuid, 'versionId', max(proposal_version_id))::jsonb || json_object_agg(field_id, value)::jsonb as row
    from version_values
    where proposal_group_uuid = :groupUUID
    group by proposal_group_uuid
     """;

  //language=PostgreSQL
  public static final String createCompanyProposalVersion = """
    insert into brs.primary_company_proposal_version (company_id, date_created, date_modified, created_by_id, modified_by_id)
      values (:companyId, now(), now(), :currentUserId, :currentUserId)
      on conflict(company_id)
      do update
      set
        version_number = brs.primary_company_proposal_version.version_number + 1,
        date_modified = now(),
        modified_by_id = excluded.modified_by_id
    """;

  //language=PostgreSQL
  public static final String createProposalVersion = """
    insert into brs.proposal_version (company_id, version, proposal_version_status_id, date_created, date_modified, created_by_id, modified_by_id)
    values (:companyId, :version, :statusId, now(), now(), :currentUserId, :currentUserId)
     """;

  //language=PostgreSQL
  public static final String publishProposalVersion = """
    update brs.proposal_version
      set
        proposal_version_status_id = :statusId ,
        notes = :notes,
        date_modified = now(),
        modified_by_id = :currentUserId
    where id = :id
    """;

  //language=PostgreSQL
  public static final String setAsCompanyPrimary = """
      update brs.primary_company_proposal_version
      set
        proposal_version_id = :versionId,
        date_modified = now(),
        modified_by_id = :currentUserId
       where company_id = :companyId
    """;

  //language=PostgreSQL
  public static final String insertCustomValue = """
    with proposal_group as (
      select upsert_proposal_custom_field_group as id
      from brs.upsert_proposal_custom_field_group(:proposalVersionId, :groupUUID, :currentUserId)
    )
    insert
    into brs.proposal_version_custom_field_value (proposal_version_custom_field_group_id, custom_field_group_assignment_id,
                                                  value, date_created, date_modified, created_by_id, modified_by_id)
    select (select id from proposal_group),
           cfga.id as custom_field_group_assignment_id,
           :value::jsonb,
           now(),
           now(),
           :currentUserId,
           :currentUserId
    from brs.custom_field cf
             inner join brs.custom_field_group_assignment cfga
                        on cf.id = cfga.custom_field_id
             inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
             inner join brs.object_type ot on cfg.object_type_id = ot.id
    where ot.object_code = :objectCode
      and cf.id = :fieldId
      and ot.archived is false
      and cf.archived is false
      and cfga.archived is false
    on conflict (proposal_version_custom_field_group_id, custom_field_group_assignment_id)
        do update
        set value     = excluded.value,
            date_modified  = now(),
            modified_by_id = excluded.modified_by_id
     """;

  //language=PostgreSQL
  public final static String archiveCustomFieldGroup = """
    insert into brs.proposal_version_custom_field_group
    (proposal_version_id, proposal_group_uuid, archived, created_by_id, date_created, modified_by_id, date_modified)
    values (:versionId, :groupUUID, now(), :currentUserId, now(), :currentUserId, now())
     """;

  //language=PostgreSQL
  public final static String deleteCustomFieldGroup = """
    delete from brs.proposal_version_custom_field_group g
        using brs.proposal_version v
    where g.proposal_version_id = v.id
      and v.proposal_version_status_id <> 2 -- only in draft mode
      and g.proposal_group_uuid = :groupUUID
      and g.proposal_version_id = :versionId
     """;

  //language=PostgreSQL
  public final static String resetCustomFieldGroup = """

    delete
    from brs.proposal_version_custom_field_group pvcfg
        using
            brs.proposal_version_custom_field_value pvcfv
                , brs.custom_field_group_assignment cfga
                , brs.custom_field_group cfg
                , brs.object_type ot
                , brs.proposal_version pv
    where pvcfg.id = pvcfv.proposal_version_custom_field_group_id
      and pvcfv.custom_field_group_assignment_id = cfga.id
      and cfga.custom_field_group_id = cfg.id
      and cfg.object_type_id = ot.id
      and pvcfg.proposal_version_id = pv.id
      and pv.proposal_version_status_id <> 2 -- only in draft mode
      and pv.id = :versionId
      and ot.object_code = :objectCode
     """;

  //language=PostgreSQL
  public final static String findFilterableValues = """
      with version_values as (select distinct on ( proposal_group_uuid, custom_field_group_assignment_id ) id,
                                                                                                         proposal_group_uuid,
                                                                                                         value,
                                                                                                         field_id
                            from brs.proposal_version_custom_field_value_vw
                            where proposal_version_id <= :versionId
                              and proposal_group_uuid not in (select distinct proposal_group_uuid
                                                              from brs.proposal_version_custom_field_group
                                                              where archived is not null
                                                                and proposal_version_id <= :versionId)
                            order by proposal_group_uuid, custom_field_group_assignment_id, id desc),
         grouped_rows as (select jsonb_build_object('pk', proposal_group_uuid,
                                                    'fields',
                                                    array_to_json(array_agg(jsonb_strip_nulls(
                                                                jsonb_build_object('fieldId', vv.field_id,
                                                                                   'flowCustomFieldId', cf.flow_custom_field_id) || vv.value)))
                                     ) as row
                          from version_values vv
                                   inner join brs.custom_field cf on cf.id = vv.field_id
                          group by proposal_group_uuid)
    select jsonb_array_elements(jsonb_path_query(row,
                                                 '$.fields[*] ? (@.fieldId == $targetFieldId || @.flowCustomFieldId == $targetFlowCustomFieldId)',
                                                 :vars) -> 'intArrayValue')::bigint as ids
    from grouped_rows
    where jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $parentFieldId && @.intValue == $parentFieldValue)', :vars)
    """;
}
