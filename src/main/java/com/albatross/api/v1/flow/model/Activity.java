package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Activity {

  private Long id, createdById, modifiedById, createdByPositionOrgId, activityTypeId, linkedPpsId, linkedPpseId, pinnedById;
  private String note, createdBy, modifiedBy, createdByPosition, createdByPositionOrg, linkLabel, pinnedBy;
  private Boolean archived, pinned, linked;

  private List<ActivityHashtag> activityHashtags;

  //various object ids
  private Long projectId, contactId, userId, orgId;

  private Date dateCreated, dateModified;

}

