package com.albatross.api.v1.company.blueraven.controllers.proposal.query;

public class ProposalQuery {

  //language=PostgreSQL
  public final static String getProjects = """
          select distinct pps.project_id,
                          p.project_name
          from flow.project_process_step pps
                   inner join flow.project p on pps.project_id = p.id
                   inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
          where p.archived is false
            and pps.process_step_id in (3507, 3546)
            and cpsst.process_step_status_type_id in (1, 2)
            and case
                    when lower(trim(:query::text)) is not null then (p.id::text like '%' || lower(trim(:query::text)) || '%' OR
                                                                     lower(p.project_name) like '%' || lower(trim(:query::text)) || '%')
                    else 1 = 1 end
          """;

  //language=PostgreSQL
  public final static String getProjectById = """
with project as (select pd.project_id,
                        pd.project_name,
                        pd.project_street1                                               as street1,
                        pd.project_city                                                  as city,
                        pd.project_state_abbreviation                                    as state,
                        pd.project_postal_code                                           as postal_code,
                        pd.contact_mobile_phone                                          as mobile,
                        case
                            when pd.closer_appointment_start is not null then
                                pd.closer_appointment_start - interval '450 minutes' end as closer_appointment_start,
                        pd.closer_appointment_end,
                        pd.ahj                                                           as ahj_id,
                        pd.metro_area                                                    as metro_area_id,
                        --this should be added to the data views but i'll just do this for now
                        (select object_category_id from flow.project p where p.id = pd.project_id) as object_category_id
                 from brs.project_details pd
                 where pd.archived is false
                   and pd.project_id = :id
                 union
                 select pd.project_id,
                        pd.project_name,
                        pd.project_street1            as street1,
                        pd.project_city               as city,
                        pd.project_state_abbreviation as state,
                        pd.project_postal_code        as postal_code,
                        pd.contact_mobile_phone       as mobile,
                        null                          as closer_appointment_start,
                        null                          as closer_appointment_end,
                        pd.nh_ahj                     as ahj_id,
                        pd.metro_area                 as metro_area_id,
                        --this should be added to the data views but i'll just do this for now
                        (select object_category_id from flow.project p where p.id = pd.project_id) as object_category_id
                 from brs.new_homes_details pd
                 where pd.archived is false
                   and pd.project_id = :id)
select p.project_id,
       project_name,
       street1,
       city,
       state,
       postal_code,
       mobile,
       closer_appointment_start,
       closer_appointment_end,
       ahj_id,
       metro_area_id,
       object_category_id,
       coalesce((SELECT array_to_json(array_agg(row_to_json(modules)))
                 FROM (select cf.field_name  as "fieldName",
                              cfv.text_value as "textValue"
                       from brs.feat_db_ahj_design_custom_field_value cfv
                                inner join brs.feat_db_ahj_design d on d.id = cfv.ahj_design_id
                                inner join brs.custom_field_group_assignment cfga
                                           on cfga.id = cfv.custom_field_group_assignment_id
                                inner join brs.custom_field cf on cf.id = cfga.custom_field_id
                       where d.ahj_id = p.ahj_id
                         and cfv.custom_field_group_assignment_id in (491, 492, 493) --whatever those fields are
                      ) modules), '[]') AS "availableModules"
from project p
    """;

  //language=PostgreSQL
  public final static String getDesignedByAuroraValue = """
    select boolean_value
    from flow.project_process_step_custom_field_value ppscfv
    inner join flow.project_process_step pps on ppscfv.project_process_step_id = pps.id
    where ppscfv.custom_field_group_assignment_id = 26962 --designed by aurora
      and ppscfv.project_process_step_id = (
          select ppscfv.project_process_step_id
            from flow.project_process_step_custom_field_value ppscfv
            inner join flow.project_process_step pps on ppscfv.project_process_step_id = pps.id
            where ppscfv.custom_field_group_assignment_id = 22560 -- aurora design id
            and pps.project_id = :projectId
            and ppscfv.text_value = :firstDesignId
            order by pps.date_created
            limit 1
        )
    """;

  //language=PostgreSQL
  public final static String getAuroraUserId = """
    select text_value
    from flow.user_custom_field_value ucfv
    where ucfv.custom_field_group_assignment_id = 27264 --aurora user id cfga
    and ucfv.text_value is not null
    and ucfv.user_id = :userId
  """;

  //language=PostgreSQL
  public final static String saveAuroraUserId = """
    select from flow.set_user_cfv(:userId::int, 3, :userId::int, 27264, :auroraUserId::text, true)
  """;

  //language=PostgreSQL
  public final static String getOldestDesignIdForProject = """
    select text_value
    from flow.project_process_step_custom_field_value ppscfv
        inner join flow.project_process_step pps on ppscfv.project_process_step_id = pps.id
        inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
    where ppscfv.custom_field_group_assignment_id = 22560 --aurora design id
    and pps.archived is false
    and cpsst.process_step_status_type_id != 3
    and ppscfv.text_value is not null
    and pps.project_id = :projectId
    order by pps.date_created
    limit 1
  """;

  //language=PostgreSQL
  public final static String getDesignIdForCreatePredesignStep = """
    select text_value
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on ppscfv.project_process_step_id = pps.id
             inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
    where ppscfv.custom_field_group_assignment_id = 27106 --aurora design id on create predesign
      and pps.archived is false
      and cpsst.process_step_status_type_id != 3
      and ppscfv.text_value is not null
      and pps.project_id = :projectId
    order by pps.date_created
    limit 1
    """;

  //language=PostgreSQL
  public final static String getProjectsCount = """
          select count(distinct pps.project_id)
          from flow.project_process_step pps
            inner join flow.project p on pps.project_id = p.id
            inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
          where p.archived is false
          and pps.process_step_id in (3507, 3546)
          and cpsst.process_step_status_type_id in (1,2)
          and case when lower(trim(:query::text)) is not null then (p.id::text like '%' || lower(trim(:query::text)) || '%' OR
           lower(p.project_name) like '%' ||  lower(trim(:query::text))  || '%') else 1=1 end
    """;

  //language=PostgreSQL
  public final static String getDesigns = """

    select p.id                                                                   as project_id,
           pps.id                                                                 as project_process_step_id,
           pps.process_step_id,
           ps.process_step_name,
           cpsst.process_step_status_type_id,
           cpsst.process_step_status_type                                         as company_process_step_status_type,
           pps.date_created,
           pps.date_modified,
           ppscfv.timestamp_value                                                 as proposal_due_date,
           ppscfv2.text_value as design_name,
           ppscfv4.text_value as design_id,
           coalesce(ppscfv3.boolean_value, false) as designed_by_aurora_ai,
           coalesce((select array_to_json(array_agg(rows))
                     from (select p.id,
                                  p.proposal_nbr                                as "proposalNbr",
                                  p.name,
                                  p.revision_number                             as "revisionNumber",
                                  p.date_created                                as "dateCreated",
                                  p.date_modified                               as "dateModified",
                                  p.archived,
                                  p.locked_tsz is not null                      as locked,
                                  p.credit_check_submitted_tsz is not null      as "creditCheckSubmitted",
                                  p.finance_docs_sent_tsz is not null           as "financeDocsSent",
                                  p.installation_agreement_sent_tsz is not null as "installationAgreementSent"
                           from brs.proposal p
                           where p.archived is not true
                             and p.project_process_step_id = pps.id
                        order by p.date_created desc) rows), '[]') AS proposals,
           coalesce((select array_to_json(array_agg(rows))
                     from (SELECT a.id,
                                  a.uuid,
                                  a.attachment_type_id                 as "attachmentTypeId",
                                  a.content_type                       as "contentType",
                                  a.filename,
                                  a.s3_key                             as "s3Key",
                                  a.size,
                                  substring(a.filename, '\\.([^\\.]+)$') as file_extension,
                                  src.project_process_step_id,
                                  a.archived
                           FROM flow.attachment a
                                    INNER JOIN flow.project_process_step_attachment src ON src.attachment_id = a.id
                                    INNER JOIN flow.attachment_type at ON at.id = a.attachment_type_id
                           WHERE src.project_process_step_id = pps.id
                             AND at.id in (select unnest(string_to_array(value, ',')::bigint[])
                                           from flow.company_configuration_value
                                           where code = 'AURORA_ATTACHMENT_TYPE_IDS'
                                             and archived is false)
                             AND a.archived IS NOT TRUE
                           order by at.id, a.date_created) rows), '[]')           AS attachments
    from flow.project p
             inner join flow.project_process_step pps on pps.project_id = p.id
             inner join flow.process_step ps on pps.process_step_id = ps.id
             inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
             left join flow.project_process_step_custom_field_value ppscfv
                       on ppscfv.project_process_step_id = pps.id
                           and ppscfv.custom_field_group_assignment_id = 22678 --proposal due date
             left join flow.project_process_step_custom_field_value ppscfv2
                                on ppscfv2.project_process_step_id = pps.id
                                    and ppscfv2.custom_field_group_assignment_id = 26300 --design name
             left join flow.project_process_step_custom_field_value ppscfv3
                       on ppscfv3.project_process_step_id = pps.id
                           and ppscfv3.custom_field_group_assignment_id = 26962 --designed by aurora ai
             left join flow.project_process_step_custom_field_value ppscfv4
                       on ppscfv4.project_process_step_id = pps.id
                           and ppscfv4.custom_field_group_assignment_id = 22560 --design id
    where pps.process_step_id = 3507 --create proposal design
      and p.id = :projectId
      and p.archived is false
      and cpsst.process_step_status_type_id = 2
    order by pps.date_created desc
    """;

  //language=PostgreSQL
  public final static String getActiveDesign = """

    select p.id                                                                   as project_id,
           pps.id                                                                 as project_process_step_id,
           pps.process_step_id,
           ps.process_step_name,
           pps.company_process_step_status_type_id,
           cpsst.process_step_status_type_id,
           cpsst.process_step_status_type                                         as company_process_step_status_type,
           pps.date_created,
           pps.date_modified,
           ppscfv.timestamp_value                                                 as due_date,
           ppscfv1.text_value                                                     as comments,
           ppscfv4.text_value as design_id,
           coalesce(ppscfv3.boolean_value, false) as designed_by_aurora_ai,
           coalesce((select array_to_json(array_agg(rows))
                     from (select p.id,
                                  p.proposal_nbr                                as "proposalNbr",
                                  p.name,
                                  p.revision_number                             as "revisionNumber",
                                  p.date_created                                as "dateCreated",
                                  p.date_modified                               as "dateModified",
                                  p.archived,
                                  p.locked_tsz is not null                      as locked,
                                  p.credit_check_submitted_tsz is not null      as "creditCheckSubmitted",
                                  p.finance_docs_sent_tsz is not null           as "financeDocsSent",
                                  p.installation_agreement_sent_tsz is not null as "installationAgreementSent"
                           from brs.proposal p
                           where p.archived is not true
                             and p.project_process_step_id = pps.id) rows), '[]') AS proposals,
           coalesce((select array_to_json(array_agg(rows))
                     from (SELECT a.id,
                                  a.attachment_type_id                 as "attachmentTypeId",
                                  a.content_type                       as "contentType",
                                  a.filename,
                                  a.s3_key                             as "s3Key",
                                  a.size,
                                  substring(a.filename, '\\.([^\\.]+)$') as file_extension,
                                  src.project_process_step_id,
                                  a.archived
                           FROM flow.attachment a
                                    INNER JOIN flow.project_process_step_attachment src ON src.attachment_id = a.id
                                    INNER JOIN flow.attachment_type at ON at.id = a.attachment_type_id
                           WHERE src.project_process_step_id = pps.id
                             AND at.id in (select unnest(string_to_array(value, ',')::bigint[])
                                           from flow.company_configuration_value
                                           where code = 'AURORA_ATTACHMENT_TYPE_IDS'
                                             and archived is false)
                             AND a.archived IS NOT TRUE
                           order by at.id, a.date_created) rows), '[]')           AS attachments
    from flow.project_process_step pps
             inner join flow.project p on pps.project_id = p.id
             inner join flow.process_step ps on ps.id = pps.process_step_id
             inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
             left join flow.project_process_step_custom_field_value ppscfv
                       on pps.id = ppscfv.project_process_step_id and ppscfv.custom_field_group_assignment_id = 22678
             left join flow.project_process_step_custom_field_value ppscfv1
                       on ppscfv1.project_process_step_id = pps.id
                         and ppscfv1.custom_field_group_assignment_id = 23623
             left join flow.project_process_step_custom_field_value ppscfv3
                                    on ppscfv3.project_process_step_id = pps.id
                                        and ppscfv3.custom_field_group_assignment_id = 26962 --designed by aurora ai
              left join flow.project_process_step_custom_field_value ppscfv4
                       on ppscfv4.project_process_step_id = pps.id
                           and ppscfv4.custom_field_group_assignment_id = 22560 --design id
    where pps.process_step_id in (3507, 3546)
      and pps.project_id = :projectId
      and cpsst.process_step_status_type_id = 1
      limit 1
    """;

  //language=PostgreSQL
  public final static String getProposalVersionId = """
    select proposal_version_id from brs.proposal where id = :proposalId and archived is false
    """;

  //language=PostgreSQL
  public final static String getCommissionDetails = """
    select * from brs.get_proposal_commission_details(:proposalId::bigint, :brsProductId::bigint, :financialProductId::bigint)
    """;

  //language=PostgreSQL
  public final static String updateProposalVersion = """
    update brs.proposal
    set proposal_version_id = :versionId,
        date_modified = now(),
        modified_by_id = :userId
    where id = :proposalId;
  """;

  //language=PostgreSQL
  public final static String get = """
    select p.id,
           p.proposal_nbr,
           p.proposal_version_id,
           p.name,
           p.revision_number,
           pv.version,
           pps.project_id,
           prj.project_name,
           cs.state_id,
           c.email,
           p.project_process_step_id,
           p.archived,
           p.date_created,
           p.date_modified,
           p.locked_tsz is not null                               as locked,
           p.credit_check_submitted_tsz is not null               as credit_check_submitted,
           p.finance_docs_sent_tsz is not null                    as finance_docs_sent,
           p.installation_agreement_sent_tsz is not null          as installation_agreement_sent,
           brs.get_max_proposal_discount_amount(p.id)             as max_discount_amount,
          brs.get_minimum_price_per_watt(p.id)                    as min_price_per_watt,
           util_ppscfv.int_value                                  as utility_company_id,
           coalesce((SELECT array_to_json(array_agg(row_to_json(cfgs)))
                     FROM (select cfg.id,
                                  cfg.group_name                                          as "groupName",
                                  cfg.object_type_id                                      as "objectTypeId",
                                  cfg.group_order                                         as "groupOrder",
                                  cfg.archived,
                                  coalesce((SELECT array_to_json(array_agg(row_to_json(cfvs)))
                                            FROM (select pcv.id,
                                                         pps3.project_id                                                    as "projectId",
                                                         pps3.process_step_id                                               as "processStepId",
                                                         case
                                                             when cotAnc.object_type_id = 1 then pcfv.date_value
                                                             when cotAnc.object_type_id = 4 then ppscfv.date_value
                                                             else pcv.date_value
                                                             end                                                            as "dateValue",
                                                         case
                                                             when cotAnc.object_type_id = 1 then pcfv.timestamp_value
                                                             when cotAnc.object_type_id = 4 then ppscfv.timestamp_value
                                                             else pcv.timestamp_value
                                                             end                                                            as "timestampValue",
                                                         case
                                                             when cotAnc.object_type_id = 1 then pcfv.boolean_value
                                                             when cotAnc.object_type_id = 4 then ppscfv.boolean_value
                                                             else pcv.boolean_value
                                                             end                                                            as "booleanValue",
                                                         case
                                                             when cotAnc.object_type_id = 1 then pcfv.text_value
                                                             when cotAnc.object_type_id = 4 then ppscfv.text_value
                                                             else pcv.text_value
                                                             end                                                            as "textValue",
                                                         case
                                                             when cotAnc.object_type_id = 1 then pcfv.numeric_value
                                                             when cotAnc.object_type_id = 4 then ppscfv.numeric_value
                                                             else pcv.numeric_value
                                                             end                                                            as "numericValue",
                                                         case
                                                             when cotAnc.object_type_id = 1 then pcfv.int_value
                                                             when cotAnc.object_type_id = 4 then ppscfv.int_value
                                                             else pcv.int_value
                                                             end                                                            as "intValue",
                                                         case
                                                             when cotAnc.object_type_id = 1 then pcfv.int_array_value
                                                             when cotAnc.object_type_id = 4 then ppscfv.int_array_value
                                                             else pcv.int_array_value
                                                             end                                                            as "intArrayValue",
                                                         cfga.custom_field_group_id                                         as "customFieldGroupId",
                                                         cfga.id                                                            as "customFieldGroupAssignmentId",
                                                         cfga.ancillary_custom_field_group_assignment_id                    as "ancillaryCustomFieldGroupAssignmentId",
                                                         case
                                                             when cotAnc.object_type_id = 1 then '(Project)'
                                                             when cotAnc.object_type_id = 4 and cfga.use_parent_data is true
                                                                 then '(Parent)'
                                                             when cotAnc.object_type_id = 4 and cfga.use_parent_data is false
                                                                 then '(Primary)' end                                       as "ancillaryCustomFieldHint",
                                                         cfga.custom_field_id                                               as "customFieldId",
                                                         cfga.field_order                                                   as "fieldOrder",
                                                         cfga.required                                                      as "required",
                                                         cfga.read_only                                                     as "customFieldGroupAssignmentReadOnly",
                                                         cfga.hidden                                                        as "customFieldGroupAssignmentHidden",
                                                         cfga.use_parent_data                                               as "useParentData",
                                                         cfga.conditional_on_cfga_id                                        as "conditionalOnId",
                                                         cfga.min_value                                                     as "minValue",
                                                         cfga.max_value                                                     as "maxValue",
                                                         cfga.visibility                                                    as "visibility",
                                                         coalesce(cf.list_of_value_id, flowCf.list_of_value_id)             as "listOfValueId",
                                                         coalesce(cf.field_name, flowCf.field_name)                         as "fieldName",
                                                         coalesce(cf.sort_list_values_alphabetically,
                                                                  flowCf.sort_list_values_alphabetically)                   as "sortListValuesAlphabetically",
                                                         cf.flow_custom_field_id                                            as "flowCustomFieldId",
                                                         coalesce(cf.custom_field_sql, flowCf.custom_field_sql)             as "customFieldSql",
                                                         coalesce(cf.company_system_list_id, flowCf.company_system_list_id) as "companySystemListId",
                                                         coalesce(cf.system_list_option_ids, flowCf.system_list_option_ids) as "systemListOptionIds",
                                                         coalesce(cf.company_data_type_id, flowCf.company_data_type_id)     as "companyDataTypeId",
                                                         coalesce(cdt.data_type_id, flowCdt.data_type_id)                   as "dataTypeId",
                                                         coalesce(cdt.has_list_values, flowCdt.has_list_values)             as "hasListValues",
                                                         coalesce(
                                                                 (SELECT array_to_json(array_agg(row_to_json(listOfValues)))
                                                                  FROM (select lov.id,
                                                                               lov.name,
                                                                               lov.code,
                                                                               lov.parent_id,
                                                                               lov.display_order
                                                                        from brs.list_of_value lov
                                                                        where lov.parent_id is not null
                                                                          and lov.parent_id = cf.list_of_value_id
                                                                          and lov.archived is not true
                                                                        union all
                                                                        select lov.id,
                                                                               lov.name,
                                                                               lov.code,
                                                                               lov.parent_id,
                                                                               lov.display_order
                                                                        from flow.list_of_value lov
                                                                        where lov.parent_id is not null
                                                                          and lov.parent_id = flowCf.list_of_value_id
                                                                          and lov.archived is not true) listOfValues),
                                                                 '[]')                                                      AS "listOfValues",
                                                         coalesce((SELECT array_to_json(array_agg(row_to_json(wlp)))
                                                                   FROM (SELECT wlp.id,
                                                                                wlp.position_id                      as "positionId",
                                                                                wlp.custom_field_group_assignment_id as "customFieldGroupAssignmentId",
                                                                                wlp.created_by_id                    as "createdById",
                                                                                wlp.modified_by_id                   as "modifiedById",
                                                                                wlp.archived
                                                                         FROM brs.white_listed_position wlp
                                                                         WHERE wlp.custom_field_group_assignment_id = cfga.id
                                                                           AND wlp.white_list_type_id = 1
                                                                           AND wlp.archived is not true) wlp),
                                                                  '[]')                                                     AS "whiteListedPositions",
                                                         coalesce((SELECT array_to_json(array_agg(row_to_json(wlp)))
                                                                   FROM (SELECT wlp.id,
                                                                                wlp.position_id                      as "positionId",
                                                                                wlp.custom_field_group_assignment_id as "customFieldGroupAssignmentId",
                                                                                wlp.created_by_id                    as "createdById",
                                                                                wlp.modified_by_id                   as "modifiedById",
                                                                                wlp.archived
                                                                         FROM brs.white_listed_position wlp
                                                                         WHERE wlp.custom_field_group_assignment_id = cfga.id
                                                                           AND wlp.white_list_type_id = 2
                                                                           AND wlp.archived is not true) wlp),
                                                                  '[]')                                                     AS "hiddenWhiteListedPositions"
                                                  from brs.custom_field_group_assignment cfga
                                                           left join brs.custom_field_group cfg1 on cfg1.id = cfga.custom_field_group_id
                                                           left join flow.object_type ot1 on ot1.id = cfg1.object_type_id
                                                           left join flow.custom_field_group_assignment cfga1
                                                                     on cfga1.id = cfga.ancillary_custom_field_group_assignment_id
                                                           left join flow.custom_field_group cfgAnc
                                                                     on cfgAnc.id = cfga1.custom_field_group_id
                                                           left join flow.company_object_type cotAnc
                                                                     on cotAnc.id = cfgAnc.company_object_type_id
                                                           left join flow.project_process_step pps1
                                                                     on pps1.project_id = pps.project_id and
                                                                        pps1.process_step_id = cfgAnc.process_step_id and
                                                                        pps1.archived is false
                                                                         and case
                                                                                 when cfga.use_parent_data is true then
                                                                                         pps1.id = (select id
                                                                                                    from flow.pps_parent_hierarchy(
                                                                                                            pps.id,
                                                                                                            cfga.ancillary_custom_field_group_assignment_id,
                                                                                                            true))
                                                                                 else pps1.main is true end
                                                           left join flow.company_process_step_status_type cpsst
                                                                     on cpsst.id = pps1.company_process_step_status_type_id
                                                           left join brs.custom_field cf on cf.id = cfga.custom_field_id
                                                           left join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                                                           left join flow.custom_field flowCf
                                                                     on flowCf.id = cfga.custom_field_id or flowCf.id = cfga1.custom_field_id
                                                           left join flow.company_data_type flowCdt
                                                                     on flowCdt.id = flowCf.company_data_type_id
                                                           left join brs.proposal_custom_field_value pcv
                                                                     on pcv.custom_field_group_assignment_id = cfga.id and
                                                                        pcv.proposal_id = p.id
                                                           left join flow.project_process_step_custom_field_value ppscfv
                                                                     on ppscfv.custom_field_group_assignment_id =
                                                                        cfga.ancillary_custom_field_group_assignment_id and
                                                                        ppscfv.project_process_step_id = pps1.id
                                                           left join flow.project_process_step pps3 on pps3.id = pps.id
                                                           left join flow.project proj on proj.id = pps3.project_id
                                                           left join flow.project_custom_field_value pcfv
                                                                     on pcfv.custom_field_group_assignment_id = cfga1.id and
                                                                        pcfv.project_id = pps3.project_id
                                                  where cfga.custom_field_group_id = cfg.id
                                                    and cfga.archived is not true
                                                  order by cfga.field_order) cfvs), '[]') AS "customFieldValues"
                           from brs.custom_field_group cfg
                           where cfg.object_type_id = 10
                             and cfg.archived is not true
                           order by cfg.group_order) cfgs), '[]') AS "customFieldGroups"
    from brs.proposal p
             inner join flow.project_process_step pps on p.project_process_step_id = pps.id
             inner join flow.project prj on pps.project_id = prj.id
             inner join flow.company_state cs on cs.id = prj.company_state_id
             inner join flow.contact c on prj.contact_id = c.id
             inner join brs.proposal_version pv on pv.id = p.proposal_version_id
             left join flow.project_process_step_custom_field_value util_ppscfv
                       on pps.id = util_ppscfv.project_process_step_id
                           and util_ppscfv.custom_field_group_assignment_id = 23802
    where p.id = :proposalId
      and p.archived is false
    """;

  public final static String simple = """
select p.id,
       p.proposal_nbr,
       p.proposal_version_id,
       p.name,
       p.revision_number,
       pps.project_id,
       prj.project_name,
       cs.state_id,
       p.project_process_step_id,
       p.archived,
       p.date_created,
       p.date_modified,
       p.locked_tsz is not null                      as locked,
       p.credit_check_submitted_tsz is not null      as credit_check_submitted,
       p.finance_docs_sent_tsz is not null           as finance_docs_sent,
       p.installation_agreement_sent_tsz is not null as installation_agreement_sent,
       ocpt.proposal_template_id                     as proposal_template_id
from brs.proposal p
         inner join flow.project_process_step pps on p.project_process_step_id = pps.id
         inner join flow.project prj on pps.project_id = prj.id
         inner join flow.company_state cs on cs.id = prj.company_state_id
         inner join brs.object_category_proposal_template ocpt on ocpt.object_category_id = prj.object_category_id
where p.id = :proposalId
  and p.archived is false
      """;

  public final static String findVersionByProjectProcessStep = """
    select get_project_proposal_version from brs.get_project_proposal_version(:ppsId, :currentUserId);
    """;

  //language=PostgreSQL
  public final static String insert = """
    insert into brs.proposal(project_process_step_id, created_by_id, proposal_version_id) values(:projectProcessStepId, :userId, :proposalVersionId)
    """;

  //language=PostgreSQL
  public final static String getCalculatedProposalValues = """
    select calc.* from brs.get_calculated_proposal_values(:proposalId::bigint, :insertPropLogHistory::boolean) calc
    """;

  public final static String getCalculatedProposalValuesNH = """
    select calc.* from brs.get_calculated_proposal_values_nh(:proposalId::bigint, :insertPropLogHistory::boolean) calc
    """;

  //language=PostgreSQL
  public final static String getAttachments = """
    select a.id as id, a.attachment_type_id, a.uuid
    from flow.project_process_step_attachment ppsa
             inner join flow.attachment a on a.id = ppsa.attachment_id
             inner join brs.proposal p on p.project_process_step_id = ppsa.project_process_step_id
    where p.id = :proposalId
      and ppsa.archived is false
      and a.archived is false
    """;

  //language=PostgreSQL
  public final static String setLocked = """
    update brs.proposal
    set locked_tsz     = now(),
        locked_by_id   = :modifiedById,
        date_modified  = now(),
        modified_by_id = :modifiedById
    where id = :id and locked_tsz is null and archived is false
    """;
  //language=PostgreSQL
  public final static String setCreditChecked = """
    update brs.proposal
    set credit_check_submitted_tsz     = now(),
        credit_check_submitted_by_id = :modifiedById,
        date_modified  = now(),
        modified_by_id = :modifiedById
    where id = :id and credit_check_submitted_tsz is null and archived is false
    """;

  //language=PostgreSQL
  public final static String setArchived = """
    update brs.proposal
    set archived       = true,
        date_modified  = now(),
        modified_by_id = :modifiedById
    where id = :id and locked_tsz is null and archived is false
    """;

  //language=PostgreSQL
  public final static String setFinanceDocsSent = """
    update brs.proposal
    set finance_docs_sent_tsz     = now(),
        finance_docs_sent_by_id = :modifiedById,
        date_modified  = now(),
        modified_by_id = :modifiedById
    where id = :id and finance_docs_sent_tsz is null and archived is false
    """;

  //language=PostgreSQL
  public final static String setInstallationAgreementDocsSent = """
    update brs.proposal
    set installation_agreement_sent_tsz     = now(),
        installation_agreement_sent_by_id = :modifiedById,
        date_modified  = now(),
        modified_by_id = :modifiedById
    where id = :id and installation_agreement_sent_tsz is null and archived is false
    """;

  //language=PostgreSQL
  public final static String setProcessed = """
    update brs.proposal set processed_tsz = now() where id = :id
    """;

  //language=PostgreSQL
  public final static String setProposalName = """
    update brs.proposal
    set name          = :name,
        date_modified = now(),
        modified_by_id = :modifiedById
    where id = :id
      and locked_tsz is null
       and archived is false
    """;

  //language=PostgreSQL
  public final static String duplicate = """
    select proposal_duplicate from brs.proposal_duplicate(:proposalId, :userId);
    """;

  //language=PostgreSQL
  public final static String postalCodeApproved = """
      select * from brs.check_project_zipcode(:projectId::bigint) as approved
    """;

  //language=PostgreSQL
  public final static String getLockedProposalsForProcessing = """
    select p.id
    from brs.proposal p
    where p.locked_tsz is not null
      and p.processed_tsz is null
      and p.error_msg is null
    order by locked_tsz
    LIMIT 10
    """;

  //language=PostgreSQL
  public final static String setProcessingErrorMessage = """
    update brs.proposal set error_msg = :errorMsg,
        date_modified = now(),
        modified_by_id = :modifiedById
    where id = :id
      and locked_tsz is not null
      and processed_tsz is null
      and error_msg is null
    """;

  public static String getProjectProcessStepCustomFieldValuesAsJSON = """
    select json_agg(json_build_object(
            'fieldId', cf.id,
            'fieldName', cf.field_name,
            'value',
            case
                when dt.data_type = 'date' then to_json(ppscfv.date_value)
                when dt.data_type = 'integer' then to_json(ppscfv.int_value)
                when dt.data_type = 'boolean' then to_json(ppscfv.boolean_value)
                when dt.data_type = 'text' then to_json(ppscfv.text_value)
                when dt.data_type = 'timestamp' then to_json(ppscfv.timestamp_value)
                when dt.data_type = 'system' then to_json(ppscfv.int_value)
                when dt.data_type = 'System List' then to_json(ppscfv.int_value)
                when dt.data_type = 'numeric' then to_json(ppscfv.int_value)
                end)) as val
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.custom_field_group_assignment cfga on ppscfv.custom_field_group_assignment_id = cfga.id
             inner join flow.project_process_step pps on ppscfv.project_process_step_id = pps.id
             inner join flow.custom_field cf on cfga.custom_field_id = cf.id
             inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
             inner join flow.data_type dt on cdt.data_type_id = dt.id
    where pps.id = :ppsId
    """;

  public static final String findUserOrgId = """
          select vw.org_id
      from flow.user_positions_vw vw
               inner join flow.org o on vw.org_id = o.id
               inner join flow.org_type ot on o.org_type_id = ot.id
      where ot.id = 126
        and vw.user_id = :userId
        and vw.archived is not true
        and vw.user_archived is false
        and ((vw.end_date is null and vw.start_date <= now()) or now() between vw.start_date and vw.end_date)
        and vw.has_access is true
      limit 1
    """;

  public static final String filterCommissionStrategiesByUser = """
select unnest(int_array_value) as id
from flow.user_custom_field_value ucfv
         inner join flow.custom_field_group_assignment cfga on ucfv.custom_field_group_assignment_id = cfga.id
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
         inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
where cfga.custom_field_id = 12855
  and cot.object_type_id = 3 --user
  and ucfv.user_id = :userId
    """;

  public static final String filterProposalDealerOrgs = """
    select jsonb_path_query(a, '$.fields[*] ? (@.fieldId == 407).intValue')::integer
    from brs.get_proposal_version_value(:proposalVersionId, null::proposalfieldfilter[], 'PROPOSAL_DEALER_ORGS') a
    where jsonb_path_exists(a, '$.fields[*] ? (@.fieldId == 413) ? (@.intValue == $orgId)',
                            jsonb_build_object('orgId', :orgId))
    """;

  public static final String filterRebatesByStateAndUtility = """
      select jsonb_path_query(a, '$.fields[*] ? (@.fieldId == 93).intValue')::integer
      from brs.get_proposal_version_value(:proposalVersionId, null::proposalfieldfilter[], 'PROPOSAL_REBATE') a
      where jsonb_path_exists(a, '$.fields[*] ? (@.fieldId == 414 && @.value == true)')
        and (
              (
                      not jsonb_path_exists(a, '$.fields[*] ? (@.fieldId == 85)')
                      and not jsonb_path_exists(a, '$.fields[*] ? (@.fieldId == 86)')
                  )
              or (
                      not jsonb_path_exists(a, '$.fields[*] ? (@.fieldId == 86)') -- state id
                      and jsonb_path_exists(a, '$.fields[*] ? (@.fieldId == 85) ? (@.intValue == $utilityId)',
                                            jsonb_build_object('utilityId', :utilityId))
                  )
              or (
                      not jsonb_path_exists(a, '$.fields[*] ? (@.fieldId == 85)') -- state id
                      and jsonb_path_exists(a, '$.fields[*] ? (@.fieldId == 86) ? (@.intValue == $stateId)',
                                            jsonb_build_object('stateId', :stateId))
                  )
              or (
                      jsonb_path_exists(a, '$.fields[*] ? (@.fieldId == 85 && @.intValue == $utilityId)',
                                        jsonb_build_object('utilityId', :utilityId))
                      and jsonb_path_exists(a, '$.fields[*] ? (@.fieldId == 86 && @.intValue == $stateId)',
                                            jsonb_build_object('stateId', :stateId))
                  )
          )
    """;
}
