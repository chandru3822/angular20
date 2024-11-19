package com.albatross.api.v1.flow.queries;

public class ContactQuery {

  //language=PostgreSQL
  public final static String searchDownline = """
    select *
    from flow.search_contacts_with_down_line(:query::character varying, :companyId::bigint, :objectCategoryIds::bigint[],
                                                            :isParent::boolean,
                                                            :userId::bigint,
                                                            :limit::bigint, :offset::bigint,
                                                            :partnerIds::bigint[])
    """;

  //language=PostgreSQL
  public final static String search = """
    select *
    from flow.search_contacts(:query::character varying, :companyId::bigint, :objectCategoryIds::bigint[],
                              :isParent::boolean,:limit::bigint, :offset::bigint, array[ :partnerIds ]::bigint[])
    """;

  //language=PostgreSQL
  public final static String searchByOwner = """
    select *
    from flow.search_contacts_by_user(:query::character varying, :companyId::bigint, :objectCategoryIds::bigint[],
                                   :isParent::boolean,:userId::bigint,:limit::bigint, :offset::bigint, array[ :partnerIds ]::bigint[])
    """;

  //language=PostgreSQL
  public final static String getById = """
select c.id,
       c.first_name,
       c.last_name,
       c.date_created,
       concat(c.first_name, ' ', c.last_name) as full_name,
       c.email,
       c.phone,
       c.mobile,
       c.latitude,
       c.longitude,
       c.contact_type_id,
       ct.contact_type,
       c.company_id,
       c.street1,
       c.city,
       c.company_state_id,
       s.state,
       coalesce(cs.active, false) as active_state,
       comp.company_name,
       c.postal_code,
       c.company_country_id,
       ctr.country,
       cc.country_id,
       c.owner_user_position_id,
       cot.owner_read_only,
       cot.owner_read_only_allow,
       c.object_category_id,
       oc.object_category,
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
                             WHERE wlp.white_list_type_id = 5
                             AND wlp.company_id = :companyId
                               AND wlp.archived is not true) wlp), '[]') AS "ownerReadOnlyWhiteListedPositions",
       coalesce((
            SELECT array_to_json(array_agg(row_to_json(projects)))
            FROM (
                     select
                         p.id,
                         p.project_name as "projectName",
                        p.street1,
                        p.city,
                        p.latitude,
                        p.longitude,
                        p.postal_code as "postalCode",
                        s.state,
                        s.abbreviation as "stateAbbreviation",
                        ctr.country,
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
                        left join flow.company_state cs on cs.id = p.company_state_id
                        left join flow.state s on s.id = cs.state_id
                        left join flow.company_country cc on cc.id = p.company_country_id
                        left join flow.country ctr on ctr.id = cc.country_id
                        left join flow.project_custom_field_value pcfv on pcfv.project_id = p.id and
                                                                          pcfv.custom_field_group_assignment_id = 27972
                     where p.contact_id = c.id
                     and p.archived is false
                     and (p.parent_id is null OR
                            not p.contact_id in (
                                select parentP.contact_id
                                from flow.project parentP
                                where parentP.id = p.parent_id
                            ))
                     and case
                         when :partnerIds is not null and array_length(array[ :partnerIds ]::bigint[], 1) > 0 then
                           pcfv.int_array_value && array[ :partnerIds ]::bigint[]
                         else true
                     end
                 ) projects), '[]') AS "projects",
       (SELECT row_to_json(o)
            FROM (SELECT u.id as "userId",
                     u.first_name as "firstName",
                     u.last_name as "lastName",
                     concat(u.first_name, ' ', u.last_name) as "fullName",
                     p.position,
                     up.id as "userPositionId",
                     ust.has_access as "hasAccess",
                     p.sms_enabled as "hasSmsAccess",
                     p.active as "isActive"
                  FROM flow."user" u
                    inner join flow.user_position up on up.user_id = u.id
                    inner join flow.position p on p.id = up.position_id
                    inner join flow.company_user_status cus on cus.user_id = u.id
                    inner join flow.user_status_type ust on cus.user_status_type_id = ust.id and ust.company_id = c.company_id
                  WHERE up.id = c.owner_user_position_id) o) AS owner
    from flow.contact c
             inner join flow.contact_type ct on ct.id = c.contact_type_id
             inner join flow.company comp on comp.id = c.company_id
             inner join flow.object_category oc on oc.id = c.object_category_id
             inner join flow.company_object_type cot on cot.company_id = comp.id and cot.object_type_id = 2
             left outer join flow.company_state cs on cs.id = c.company_state_id
              left outer join flow.state s on s.id = cs.state_id
             left outer join flow.company_country cc on cc.id = c.company_country_id
             left join flow.country ctr on ctr.id = cc.country_id
             left join flow.contact_custom_field_value ccfv on ccfv.contact_id = c.id and
                                                               ccfv.custom_field_group_assignment_id = 27973
    where c.id = :contactId
      and c.company_id = :companyId
      and c.archived is not true
      and case
            when :partnerIds is not null and array_length(array[ :partnerIds ]::bigint[], 1) > 0 then
              ccfv.int_array_value && array[ :partnerIds ]::bigint[]
            else true
        end
    """;

  //language=PostgreSQL
  public final static String getByProjectId = """
 select
      c.id,
      c.first_name,
      c.last_name,
      c.date_created,
      concat(c.first_name, ' ', c.last_name) as full_name,
      c.email,
      c.phone,
      c.latitude,
      c.longitude,
      c.mobile,
      c.contact_type_id,
      c.postal_code,
      c.company_id,
      c.street1,
      c.city,
      c.company_state_id,
      s.state,
      c.company_country_id,
      ct.country
    from flow.contact c
      inner join flow.project p on p.contact_id = c.id
      left outer join flow.company_state cs on cs.id = c.company_state_id
      left outer join flow.state s on s.id = cs.state_id
      left join flow.company_country cc on cc.id = c.company_country_id
      left join flow.country ct on ct.id = cc.country_id
    where p.id = :projectId
       and case when :isParent then c.company_id = any (select id
                                                 from flow.company_hierarchy_filter_down(:parentCompanyId::bigint))
            else c.company_id = :companyId end
            and c.archived is not true
 """;

  //language=PostgreSQL
  public final static String updateContact = """
    update flow.contact
        set
           contact_type_id = :contactTypeId,
           first_name = trim(:firstName),
           last_name = trim(:lastName),
           street1 = :street1,
           city = :city,
           latitude = :latitude,
           longitude = :longitude,
           company_state_id = :companyStateId,
           postal_code = :postalCode,
           company_country_id = :companyCountryId,
           phone = :phone,
           email = :email,
           mobile = :mobile,
           modified_by_id = :modifiedById,
           date_modified = now(),
           owner_user_position_id = :ownerUserPositionId
    where id = :id
    """;

  //language=PostgreSQL
  public final static String delete = """
    update flow.contact set
           archived = true,
           modified_by_id = :modifiedById,
           date_modified = now()
    where id = :contactId
    """;

  //language=PostgreSQL
  public final static String insertContact = """
  insert into flow.contact(contact_type_id, first_name, last_name, street1, city, company_state_id, postal_code,
                           company_country_id, phone, email, mobile, created_by_id, date_created, modified_by_id,
                           date_modified, company_id, owner_user_position_id, latitude, longitude, object_category_id)
  values (:contactTypeId, trim(:firstName), trim(:lastName), :street1, :city, :companyStateId, trim(:postalCode),
          :companyCountryId, :phone, :email, :mobile, :createdById, now(), :createdById, now(), :companyId,
          :ownerUserPositionId, :latitude, :longitude, COALESCE(:objectCategoryId, (select id
                                                                                    from flow.object_category
                                                                                    where is_default is true
                                                                                      and archived is false
                                                                                      and object_type_id = 2
                                                                                    limit 1)))
    """;

  //language=PostgreSQL
  public final static String insertContactFromChildProject = """
  insert into flow.contact(contact_type_id, first_name, last_name, postal_code,
                           company_country_id, phone, email, created_by_id,
                           company_id, object_category_id)
  values (1, trim(:firstName), trim(:lastName), trim(:postalCode), 1, :phone, :email, :userId, :companyId, :objectCategoryId)
    """;

  //language=PostgreSQL
  public final static String getContactsToUpdateForLatLong = """
select c.id, c.street1, c.city, c.company_state_id, st.state, st.abbreviation, c.postal_code
    from flow.contact c
    left join flow.company_state cs on c.company_state_id = cs.id
    left join flow.state st on st.id = cs.state_id
    where c.archived is false
    and c.street1 is not null and c.city is not null
      and c.temp_geo_attempted is false
      and c.latitude is null
      and c.longitude is null
    and c.id not in (
      select c2.id from flow.contact c2
      inner join flow.project p on c2.id = p.contact_id
      where p.street1 is not null and p.city is not null and p.company_state_id is not null and p.postal_code is not null
      and p.street1 = c2.street1 and p.city = c2.city and p.company_state_id = c2.company_state_id and p.postal_code = c2.postal_code
      and p.archived is false
      and p.latitude is not null
      and p.longitude is not null
      and c2.archived is false
      )
    order by date_created desc
    limit :limit
    """;

  //language=PostgreSQL
  public final static String updateLatLongTemp = """
    update flow.contact
    set latitude = :latitude,
        longitude = :longitude,
        temp_geo_attempted = true,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getOwners = """
select * from flow.get_contact_available_owners(:companyId::bigint, :inParentCompany)
    """;

  //language=PostgreSQL
  public final static String updateOwner = """
    update flow.contact set
           modified_by_id = :modifiedById,
           owner_user_position_id = :ownerUserPositionId,
           date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String updateMailingAddress = """
    update flow.contact set
           mailing_street1 = :street1,
           mailing_street2 = :street2,
           mailing_city = :city,
           mailing_company_state_id = :stateId,
           mailing_postal_code = :postalCode,
           modified_by_id = :modifiedById,
           date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String convertToContact = """
    update flow.contact set
           modified_by_id = :modifiedById,
           contact_type_id = :contactTypeId,
           date_modified = now()
    where id = :contactId
    """;

  //language=PostgreSQL
  public final static String getCompanyId = """
    select c.company_id
    from flow.contact c
    where c.id = :contactId
    """;

  //language=PostgreSQL
  public final static String getContactAttachments = """
select
      a.id,
      a.size,
      a.uuid,
      a.date_created,
      a.date_modified,
      a.filename,
      a.attachment_type_id,
      a.content_type,
      a.s3_key,
      a.display_name,
      a.archived,
      substring(filename, '\\.([^\\.]+)$') as file_extension,
      ca.contact_id,
      ca.linked,
      concat(u.first_name, ' ', u.last_name) AS uploaded_by,
      att.attachment_type,
      orgn.*
    from flow.contact_attachment ca
           inner join flow.attachment a on a.id = ca.attachment_id
           inner join flow."user" u ON a.created_by_id = u.id
           inner join flow.attachment_type att on a.attachment_type_id = att.id
           inner join flow.contact_attachment_type uat on uat.attachment_type_id = att.id and uat.archived is false
           left join lateral ( select * from flow.get_attachment_origin(a.id)) orgn on true
    where ca.contact_id = :contactId
      and a.company_id = :companyId
      and ca.archived is false
      and uat.archived is false
      and case when :linked is true then ca.linked is true and uat.linkable is true else ca.linked is false end
      and a.archived is not true
    order by ca.date_created desc
    """;

  //language=PostgreSQL
  public final static String linkAttachment = """
    insert into flow.contact_attachment(attachment_id, contact_id, created_by_id, linked)
    values(:attachmentId, :contactId, :userId, true)
    """;

  //language=PostgreSQL
  public final static String unlinkAttachment = """
    update flow.contact_attachment
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
    where attachment_id = :attachmentId
    and contact_id = :contactId
    and linked is true
    """;

  //language=PostgreSQL
  public final static String addAttachment = """
    insert into flow.contact_attachment(attachment_id, contact_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:attachmentId, :contactId, :createdById, now(), :createdById, now())
    """;

  //language=PostgreSQL
  public final static String getAttachmentType = """
    select oat.id,
               oat.company_id,
               oat.attachment_type_id,
               at.attachment_type,
               oat.focused,
               oat.linkable,
               oat.allow_upload,
               oat.archived,
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
                                                                                     AND wlp.company_id = :companyId
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
                                 WHERE cfg.contact_attachment_type_id = oat.id AND cfg.archived is not true
                                 order by cfg.group_order) cfGroups), '[]') AS custom_field_groups
        from flow.contact_attachment_type oat
               inner join flow.attachment_type at on oat.attachment_type_id = at.id
        where oat.id = :id
        and oat.company_id = :companyId
    """;

}
