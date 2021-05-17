package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EventStatusType {

  //oh boy. this is confusing af.  id = companyEventStatusTypeId.  EventStatusTypeId = rootEventStatusTypeId
    private Long id, eventStatusTypeId, displayOrder;

    private String eventStatusType, rootEventStatusType;
    private Attachment icon;

    private Boolean archived, isDefault;

}
