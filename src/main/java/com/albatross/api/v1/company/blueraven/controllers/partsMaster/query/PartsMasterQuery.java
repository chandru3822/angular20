package com.albatross.api.v1.company.blueraven.controllers.partsMaster.query;

public class PartsMasterQuery {

  //language=PostgreSQL
  public static final String findAllByCompanyCount = """
    select count(1)
    from brs.parts_master_version v
             inner join flow.user cu on v.created_by_id = cu.id
             inner join flow.user mu on v.modified_by_id = mu.id
    where v.company_id = :companyId
    and case when :publishedOnly::boolean is true then v.parts_master_version_status_id = 2 else true end
    """;

  //language=PostgreSQL
  public static final String findAllByCompany = """
    select v.*,
           concat(cu.first_name, ' ', cu.last_name)                                  as created_by,
           concat(mu.first_name, ' ', mu.last_name)                                  as modified_by,
           case when pcpmv.parts_master_version_id is not null then true else false end as primary_version
    from brs.parts_master_version v
             inner join flow.user cu on v.created_by_id = cu.id
             inner join flow.user mu on v.modified_by_id = mu.id
             left join brs.primary_company_parts_master_version pcpmv
                       on v.id = pcpmv.parts_master_version_id and v.company_id = pcpmv.company_id
    where v.company_id = :companyId
    and case when :publishedOnly::boolean is true then v.parts_master_version_status_id = 2 else true end
    order by v.id desc
    limit :limit
    offset :offset
    """;

  //language=PostgreSQL
  public static final String findById = """
    select v.*,
           concat(cu.first_name, ' ', cu.last_name)                                  as created_by,
           concat(mu.first_name, ' ', mu.last_name)                                  as modified_by,
           case when pcpmv.parts_master_version_id is not null then true else false end as primary_version
    from brs.parts_master_version v
             inner join flow.user cu on v.created_by_id = cu.id
             inner join flow.user mu on v.modified_by_id = mu.id
             left join brs.primary_company_parts_master_version pcpmv
                       on v.id = pcpmv.parts_master_version_id and v.company_id = pcpmv.company_id
    where v.id = :id
    """;

  //language=PostgreSQL
  public static final String findObjectTypes = """
    select ot.id, ot.object_type as name, ot.object_code as code
    from brs.object_type ot
    where ot.parent_id = (select id from brs.object_type where object_code = 'PARTS')
      and ot.archived is false
    """;

  //language=PostgreSQL
  public static final String findPartsMasterFieldsByObjectCode = """
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
      and cfg.archived is false
    order by cfg.group_order, cfga.field_order
    """;

  //language=PostgreSQL
  public static final String partsMasterVersionCustomFieldValues = """
    with version_values as (select distinct on ( vw.parts_master_group_uuid, vw.custom_field_group_assignment_id ) vw.id,
                                                                                                               vw.custom_field_group_assignment_id,
                                                                                                               vw.parts_master_group_uuid,
                                                                                                               vw.parts_master_version_id,
                                                                                                               vw.value,
                                                                                                               vw.field_id,
                                                                                                               vw.field_code,
                                                                                                               vw.modified_by_id,
                                                                                                               vw.modified_by,
                                                                                                               vw.date_modified
                            from brs.parts_master_version_custom_field_value_vw vw
                            where vw.parts_master_version_id <= :versionId
                              and vw.object_code = :objectCode
                              and vw.parts_master_group_uuid not in (select distinct g.parts_master_group_uuid
                                                                 from brs.parts_master_version_custom_field_group g
                                                                 where g.archived is not null
                                                                   and g.parts_master_version_id <= :versionId)
                            order by vw.parts_master_group_uuid, vw.custom_field_group_assignment_id, vw.date_modified desc) -- TODO: CHECK vw.parts_master_version_custom_field_group_id
         select json_build_object('pk', vv.parts_master_group_uuid,
                                        'archived', grp.archived is not null,
                                        'versionId', max(case
                                                             when grp.archived is null then vv.parts_master_version_id
                                                             else :versionId end))::jsonb ||
                      json_object_agg(vv.field_id, vv.value)::jsonb as row
               from version_values vv
                        left join brs.parts_master_version_custom_field_group grp
                                  on grp.parts_master_group_uuid = vv.parts_master_group_uuid
                                      and grp.parts_master_version_id = :versionId
               group by vv.parts_master_group_uuid, archived
    """;

  //language=PostgreSQL
  public static final String partsMasterVersionCustomFieldValuesByUUID = """
    with version_values as (
        select distinct on ( parts_master_group_uuid, custom_field_group_assignment_id ) id,
                                                                             custom_field_group_assignment_id,
                                                                             parts_master_group_uuid,
                                                                             parts_master_version_id,
                                                                             value,
                                                                             field_id,
                                                                             field_code,
                                                                             modified_by_id,
                                                                             modified_by,
                                                                             date_modified
        from brs.parts_master_version_custom_field_value_vw
        where parts_master_version_id <= :versionId
          and object_code = :objectCode
        order by parts_master_group_uuid, custom_field_group_assignment_id, date_modified desc)
    select json_build_object('pk',  parts_master_group_uuid, 'versionId', max(parts_master_version_id))::jsonb || json_object_agg(field_id, value)::jsonb as row
    from version_values
    where parts_master_group_uuid = :groupUUID
    group by parts_master_group_uuid
    """;

  //language=PostgreSQL
  public static final String createCompanyPartsMasterVersion = """
    insert into brs.primary_company_parts_master_version (company_id, date_created, date_modified, created_by_id, modified_by_id)
      values (:companyId, now(), now(), :currentUserId, :currentUserId)
      on conflict(company_id)
      do update
      set
        version_number = brs.primary_company_parts_master_version.version_number + 1,
        date_modified = now(),
        modified_by_id = excluded.modified_by_id
    """;

  //language=PostgreSQL
  public static final String createPartsMasterVersion = """
    insert into brs.parts_master_version (company_id, version, parts_master_version_status_id, date_created, date_modified, created_by_id, modified_by_id)
    values (:companyId, :version, :statusId, now(), now(), :currentUserId, :currentUserId)
    """;

  //language=PostgreSQL
  public static final String publishPartsMasterVersion = """
    update brs.parts_master_version
      set
        parts_master_version_status_id = :statusId ,
        notes = :notes,
        date_modified = now(),
        modified_by_id = :currentUserId
    where id = :id
    """;

  //language=PostgreSQL
  public static final String setAsCompanyPrimary = """
      update brs.primary_company_parts_master_version
      set
        parts_master_version_id = :versionId,
        date_modified = now(),
        modified_by_id = :currentUserId
       where company_id = :companyId
    """;

  //language=PostgreSQL
  public static final String insertCustomValue = """
    with parts_master_group as (
      select upsert_parts_master_custom_field_group as id
      from brs.upsert_parts_master_custom_field_group(:partsMasterVersionId, :groupUUID, :currentUserId)
    )
    insert
    into brs.parts_master_version_custom_field_value (
      parts_master_version_custom_field_group_id,
      custom_field_group_assignment_id,
      value,
      date_created,
      date_modified,
      created_by_id,
      modified_by_id
    )
    select (select id from parts_master_group),
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
    on conflict (parts_master_version_custom_field_group_id, custom_field_group_assignment_id)
        do update
        set value     = excluded.value,
            date_modified  = now(),
            modified_by_id = excluded.modified_by_id
    """;

  //language=postgresql
  public final static String deleteEmptyCustomFieldValues = """
    delete
    from brs.parts_master_version_custom_field_value
    where id in (select pvcfv.id
                 from brs.parts_master_version_custom_field_value pvcfv
                          inner join brs.parts_master_version_custom_field_group pvcfg
                                     on pvcfv.parts_master_version_custom_field_group_id = pvcfg.id
                          inner join brs.custom_field_group_assignment cfga
                                     on pvcfv.custom_field_group_assignment_id = cfga.id
                          inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                          inner join brs.custom_field cf on cfga.custom_field_id = cf.id
                          inner join brs.object_type ot on cfg.object_type_id = ot.id
                          inner join brs.parts_master_version pv on pvcfg.parts_master_version_id = pv.id
                     and pv.parts_master_version_status_id = 1 -- DRAFT
                 where pvcfg.parts_master_group_uuid = :groupUUID
                   and pvcfg.parts_master_version_id = :partsMasterVersionId
                   and ot.object_code = :objectCode
                   and cf.archived is false
                   and cfga.archived is false
                   and cf.id = :fieldId)
    """;

  //language=PostgreSQL
  public final static String archiveCustomFieldGroup = """
    insert into brs.parts_master_version_custom_field_group
    (parts_master_version_id, parts_master_group_uuid, archived, created_by_id, date_created, modified_by_id, date_modified)
    values (:versionId, :groupUUID, now(), :currentUserId, now(), :currentUserId, now())
    """;

  //language=PostgreSQL
  public final static String deleteCustomFieldGroup = """
    delete from brs.parts_master_version_custom_field_group g
        using brs.parts_master_version v
    where g.parts_master_version_id = v.id
      and v.parts_master_version_status_id <> 2 -- only in draft mode
      and g.parts_master_group_uuid = :groupUUID
      and g.parts_master_version_id = :versionId
    """;

  //language=PostgreSQL
  public final static String resetCustomFieldGroup = """
    delete
    from brs.parts_master_version_custom_field_group pvcfg
        using
            brs.parts_master_version_custom_field_value pvcfv
                , brs.custom_field_group_assignment cfga
                , brs.custom_field_group cfg
                , brs.object_type ot
                , brs.parts_master_version pv
    where pvcfg.id = pvcfv.parts_master_version_custom_field_group_id
      and pvcfv.custom_field_group_assignment_id = cfga.id
      and cfga.custom_field_group_id = cfg.id
      and cfg.object_type_id = ot.id
      and pvcfg.parts_master_version_id = pv.id
      and pv.parts_master_version_status_id <> 2 -- only in draft mode
      and pv.id = :versionId
      and ot.object_code = :objectCode
    """;

  // language=postgresql
  public final static String unarchiveCustomFieldGroup = """
        with version_values as (select distinct parts_master_group_uuid
                            from brs.parts_master_version_custom_field_value_vw
                            where parts_master_version_id <= :versionId
                              and object_code = :objectCode),
         archived as (select pvcfg.id, pvcfg.parts_master_group_uuid, archived
                      from brs.parts_master_version_custom_field_group pvcfg
                               inner join brs.parts_master_version pv on pvcfg.parts_master_version_id = pv.id
                      where pvcfg.parts_master_version_id = :versionId
                        and pv.parts_master_version_status_id <> 2
                        and archived is not null)
    delete
    from brs.parts_master_version_custom_field_group
    where id in (select distinct a.id
                 from archived a
                          inner join version_values vv on a.parts_master_group_uuid = vv.parts_master_group_uuid);
    """;

  //language=PostgreSQL
  public static final String findPartsMasterVersionValues = """
with a as (select (jsonb_path_query(get_parts_master_version_value,
                                    '$.fields[*] ? (@.fieldId == $targetFieldId || @.flowCustomFieldId == $targetFieldId)',
                                    jsonb_build_object('targetFieldId', :fieldId)) -> 'intValue')::int as int_value,
                  get_parts_master_version_value                                                           as row
           from brs.get_parts_master_version_value(:versionId, null::partsmasterfieldfilter[], :objectCode)),
     t as (select (jsonb_path_query(row,
                                    '$.fields[*] ? (@.fieldId == $targetFieldId || @.flowCustomFieldId == $targetFieldId)',
                                    jsonb_build_object('targetFieldId', :fieldId)) -> 'intValue')::int as       int_value,
                  jsonb_path_exists(row,
                                    '$.fields[*] ? (@.fieldId == $customFieldId && @.intValue == $intValue)',
                                    jsonb_build_object('customFieldId', :customFieldId, 'intValue', :intValue)) is_match
           from a
           where jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $customFieldId)',
                                   jsonb_build_object('customFieldId', :customFieldId)))
select a.int_value
from a
where a.int_value not in (select t.int_value from t where t.is_match is false)
  """;

  //language=PostgreSQL
  public final static String findFilterableValues = """
      with version_values as (select distinct on ( parts_master_group_uuid, custom_field_group_assignment_id ) id,
                                                                                                         parts_master_group_uuid,
                                                                                                         value,
                                                                                                         field_id
                            from brs.parts_master_version_custom_field_value_vw
                            where parts_master_version_id <= :versionId
                              and parts_master_group_uuid not in (select distinct parts_master_group_uuid
                                                              from brs.parts_master_version_custom_field_group
                                                              where archived is not null
                                                                and parts_master_version_id <= :versionId)
                            order by parts_master_group_uuid, custom_field_group_assignment_id, date_modified desc),
         grouped_rows as (select jsonb_build_object('pk', parts_master_group_uuid,
                                                    'fields',
                                                    array_to_json(array_agg(jsonb_strip_nulls(
                                                                jsonb_build_object('fieldId', vv.field_id,
                                                                                   'flowCustomFieldId', cf.flow_custom_field_id) || vv.value)))
                                     ) as row
                          from version_values vv
                                   inner join brs.custom_field cf on cf.id = vv.field_id
                          group by parts_master_group_uuid)
    select jsonb_array_elements(jsonb_path_query(row,
                                                 '$.fields[*] ? (@.fieldId == $targetFieldId || @.flowCustomFieldId == $targetFlowCustomFieldId)',
                                                 :vars) -> 'intArrayValue')::bigint as ids
    from grouped_rows
    where jsonb_path_exists(row,
                            '$.fields[*] ? (@.fieldId == $parentFieldId && @.intValue == $parentFieldValue)',
                            :vars)
    union
    select (jsonb_path_query(row,
                              '$.fields[*] ? (@.fieldId == $targetFieldId || @.flowCustomFieldId == $targetFlowCustomFieldId)',
                               :vars) -> 'intValue')::bigint as ids
    from grouped_rows
    where jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $parentFieldId && @.intValue == $parentFieldValue)', :vars)
    """;

  // language=postgresql
  public static final String findFilterableValuesByFieldIdAndValue = """
    with version_values as (select distinct on ( parts_master_group_uuid, custom_field_group_assignment_id ) id,
                                                                                                         parts_master_group_uuid,
                                                                                                         value,
                                                                                                         field_id
                            from brs.parts_master_version_custom_field_value_vw
                            where parts_master_version_id <= :versionId
                              and case when :objectCode is not null then object_code = :objectCode else 1 = 1 end
                              and parts_master_group_uuid not in (select distinct parts_master_group_uuid
                                                              from brs.parts_master_version_custom_field_group
                                                              where archived is not null
                                                                and parts_master_version_id <= :versionId)
                            order by parts_master_group_uuid, custom_field_group_assignment_id, date_modified desc),
         grouped_rows as (select jsonb_build_object('pk', parts_master_group_uuid,
                                                    'fields',
                                                    array_to_json(array_agg(jsonb_strip_nulls(
                                                                jsonb_build_object('fieldId', vv.field_id,
                                                                                   'flowCustomFieldId',
                                                                                   cf.flow_custom_field_id) || vv.value)))
                                     ) as row
                          from version_values vv
                                   inner join brs.custom_field cf on cf.id = vv.field_id
                          group by parts_master_group_uuid),
         filtered as (select jsonb_path_query(row,
                                              '$.fields[*] ? (@.fieldId == $targetFieldId || @.flowCustomFieldId == $targetFieldId)',
                                              jsonb_build_object('targetFieldId', :fieldId)) as row
                      from grouped_rows g
                               left join lateral jsonb_path_query(row,
                                                                  '$.fields[*] ? (@.fieldId == $filterFieldId || @.flowCustomFieldId == $filterFieldId)',
                                                                  jsonb_build_object('filterFieldId', :filterFieldId)) b
                                         on true
                      where jsonb_path_exists(row, '$.fields[*] ? (@.fieldId == $targetFieldId )',
                                              jsonb_build_object('targetFieldId', :fieldId))
                        and (b is null or
                             jsonb_array_length(
                                     jsonb_path_query_array(b -> 'intArrayValue',
                                                            '$[*] ? (@ == $filterFieldValue)',
                                                            jsonb_build_object('filterFieldValue', :filterFieldValue))) <= 0))
          select distinct (row -> 'intValue') from filtered
    """;

  // language=postgresql
  public static final String findVersionHistoryByVersionId = """
    with version_values
         as (select distinct on ( vw.parts_master_group_uuid, vw.custom_field_group_assignment_id ) vw.object_code,
                                                                                                vw.object_type,
                                                                                                vw.parts_master_group_uuid,
                                                                                                vw.custom_field_group_assignment_id,
                                                                                                vw.parts_master_version_id,
                                                                                                vw.field_id,
                                                                                                vw.value                                                                                                                          current_value,
                                                                                                lag(vw.value)
                                                                                                over (partition by object_code, parts_master_group_uuid, custom_field_group_assignment_id, field_id order by parts_master_version_id ) as previous_value,
                                                                                                vw.modified_by_id,
                                                                                                vw.modified_by,
                                                                                                vw.date_modified
             from brs.parts_master_version_custom_field_value_vw vw
             where vw.parts_master_version_id <= :versionId
               and vw.parts_master_group_uuid not in (select distinct g.parts_master_group_uuid
                                                  from brs.parts_master_version_custom_field_group g
                                                  where g.archived is not null
                                                    and g.parts_master_version_id <=
                                                        (select id
                                                         from brs.parts_master_version
                                                         where id < :versionId
                                                           and company_id = 3
                                                         order by date_modified desc
                                                         limit 1))
             order by vw.parts_master_group_uuid, vw.custom_field_group_assignment_id, vw.date_modified desc),
     x as (select vv.parts_master_group_uuid,
                  grp.archived is not null                               as archived,
                  vv.object_type,
                  cf.field_name,
                  vv.current_value,
                  vv.previous_value,
                  case
                      when grp.archived is null then vv.parts_master_version_id
                      else grp.parts_master_version_id end                   as version_id,
                  case
                      when grp.archived is null then vv.modified_by
                      else concat_ws(' ', u.first_name, u.last_name) end as modified_by,
                  case
                      when grp.archived is null then vv.date_modified
                      else grp.date_modified end                         as date_modified
           from version_values vv
                    inner join brs.custom_field cf on cf.id = vv.field_id
                    left join brs.parts_master_version_custom_field_group grp
                              on grp.parts_master_group_uuid = vv.parts_master_group_uuid
                                  and grp.parts_master_version_id = :versionId
                                  and grp.archived is not null
                    left join flow."user" u on grp.modified_by_id = u.id),
     grouped_rows as (select max(x.version_id)                                                                   as max_version_id,
                             jsonb_build_object(
                                     'objectType', object_type,
                                     'pk', parts_master_group_uuid,
                                     'archived', archived,
                                     'modifiedDate', max(date_modified),
                                     'modifiedBy', ( (select x2.modified_by
                                                      from x as x2
                                                      where x2.parts_master_group_uuid = x.parts_master_group_uuid
                                                        and x2.object_type = x.object_type
                                                        and x2.archived = x.archived
                                                        and x2.date_modified = max(x.date_modified)
                                                      order by x2.date_modified desc
                                                      limit 1)),
                                     'changes', jsonb_agg(jsonb_strip_nulls(jsonb_build_object('fieldName', field_name,
                                                                                               'currentValue', current_value,
                                                                                               'previousValue', previous_value,
                                                                                               'versionId', x.version_id,
                                                                                               'modifiedBy', modified_by,
                                                                                               'modifiedDate', date_modified)))) as row
                      from x
                      group by parts_master_group_uuid, archived, object_type
                      order by object_type, parts_master_group_uuid, archived)
select row
from grouped_rows
where max_version_id = :versionId
                            """;

}
