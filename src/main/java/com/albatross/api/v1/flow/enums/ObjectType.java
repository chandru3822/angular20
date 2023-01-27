package com.albatross.api.v1.flow.enums;

import com.albatross.api.v1.flow.queries.*;
import com.albatross.api.v1.flow.queries.EventQuery;
import com.albatross.api.v1.flow.queries.customFieldValues.*;

public enum ObjectType {
  PROJECT(1L,
    "project",
    ProjectQuery.getAttachmentType,
    ProjectCfvQuery.getCompanyId,
    ProjectCfvQuery.upsertCustomFieldValue,
    ProjectCfvQuery.getAncillaryCustomFieldGroupsAndValuesForAttachments
  ),
  CONTACT(2L,
    "contact",
    ContactQuery.getAttachmentType,
    ContactCfvQuery.getCompanyId,
    ContactCfvQuery.upsertCustomFieldValue,
    ContactCfvQuery.getAncillaryCustomFieldGroupsAndValuesForAttachments
  ),
  USER(3L,
    "user",
    UserQuery.getAttachmentType,
    null,
    UserCfvQuery.upsertCustomFieldValue,
    UserCfvQuery.getAncillaryCustomFieldGroupsAndValuesForAttachments
  ),
  PROCESS_STEP(4L,
    "process_step",
    null,
    ProcessStepCfvQuery.getCompanyId,
    ProcessStepCfvQuery.upsertCustomFieldValue,
    ProcessStepCfvQuery.getAncillaryCustomFieldGroupsAndValuesForAttachments
  ),
  ORGANIZATION(5L,
    "org",
    OrgQuery.getAttachmentType,
    OrganizationCfvQuery.getCompanyId,
    OrganizationCfvQuery.upsertCustomFieldValue,
    OrganizationCfvQuery.getAncillaryCustomFieldGroupsAndValuesForAttachments
  ),
  EVENT(6L,
    "event",
    EventQuery.getAttachmentType,
    null,
    EventCfvQuery.upsertCustomFieldValue,
    EventCfvQuery.getAncillaryCustomFieldGroupsAndValuesForAttachments
  ),
  ATTACHMENT_TYPE(7L,
    "attachment_type",
    null,
    AttachmentTypeCfvQuery.getCompanyId,
    AttachmentTypeCfvQuery.upsertCustomFieldValue,
    null
  ),
  //until i remember how these all work, i am making them all null for data view
  DATA_VIEW(8L,
    "not_needed_maybe",
    null,
    null,
    null,
    null
  );

  public final Long id;
  public final String tablePrefix;
  public final String getAttachmentTypeQuery;
  public final String getCompanyIdQuery;
  public final String upsertCustomFieldValueQuery;
  public final String getAncillaryCustomFieldGroupsAndValuesForAttachmentsQuery;

  ObjectType(Long id, String tablePrefix, String getAttachmentTypeQuery, String getCompanyIdQuery,
             String upsertCustomFieldValueQuery, String getAncillaryCustomFieldGroupsAndValuesForAttachmentsQuery) {
    this.id = id;
    this.tablePrefix = tablePrefix;
    this.getAttachmentTypeQuery = getAttachmentTypeQuery;
    this.getCompanyIdQuery = getCompanyIdQuery;
    this.upsertCustomFieldValueQuery = upsertCustomFieldValueQuery;
    this.getAncillaryCustomFieldGroupsAndValuesForAttachmentsQuery = getAncillaryCustomFieldGroupsAndValuesForAttachmentsQuery;
  }

  public static ObjectType get(String name) {
    name = name.toLowerCase();
    for (ObjectType s : values()) {
      if (s.toString().equals(name) || s.textValue().equals(name)) {
        return s;
      }
    }
    throw new IllegalArgumentException();
  }

  public String toString() {
    return name().toLowerCase().replaceAll("_", " ");
  }

  public String textValue() {
    return name().toLowerCase();
  }
}
