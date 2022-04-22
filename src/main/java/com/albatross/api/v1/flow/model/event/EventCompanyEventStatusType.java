package com.albatross.api.v1.flow.model.event;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class EventCompanyEventStatusType {

  private Long id, companyId, eventId, companyEventStatusTypeId, eventStatusTypeId, createdById, modifiedById;
  private String eventStatusType, rootEventStatusType, eventName;
  private Boolean archived;
}

