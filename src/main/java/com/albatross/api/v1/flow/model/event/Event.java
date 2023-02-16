package com.albatross.api.v1.flow.model.event;

import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.WhiteListedPosition;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Event {

  private Long id, companyId, resourceCustomFieldId;
  private String eventName;
  private Boolean archived, startTimeReadOnly, startTimeHidden, endTimeReadOnly, endTimeHidden, resourceReadOnly, resourceHidden;
  private List<CustomFieldGroup> customFieldGroups;
  private List<EventCompanyEventStatusType> companyEventStatusTypes;
  private List<WhiteListedPosition>
          startTimeWhiteListedPositions, startTimeHiddenWhiteListedPositions,
          endTimeWhiteListedPositions, endTimeHiddenWhiteListedPositions,
          resourceWhiteListedPositions, resourceHiddenWhiteListedPositions;
}

