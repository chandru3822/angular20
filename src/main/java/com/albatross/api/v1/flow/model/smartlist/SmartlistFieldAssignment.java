package com.albatross.api.v1.flow.model.smartlist;

import com.albatross.api.v1.flow.model.CustomField;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SmartlistFieldAssignment extends SmartlistSuperField {

  //@TODO humes: customField brings in fields making some direct fields on this class redundant. Remove the direct redundant fields

  private Long systemListTypeId;

  private CustomField customField;

  @Deprecated //@TODO: turns out this field wasn't needed. Remove it's use from `buildProcessStepSql` function
  @JsonIgnore
  private String valueEventReferenceTable;

  // @TODO: #smartlistsv2 - temp until v1 is gone
  public com.albatross.api.v1.flow.model.smartlistv1.SmartlistFieldAssignment toV1(ObjectMapper om) {
    var field = om.convertValue(this, com.albatross.api.v1.flow.model.smartlistv1.SmartlistFieldAssignment.class);
    field.setValueEventReferenceTable(this.getValueEventReferenceTable());
    field.setReferenceTable(this.getReferenceTable());
    field.setReferenceColumn(this.getReferenceColumn());
    field.setJoinTable(this.getJoinTable());
    field.setJoinColumn(this.getJoinColumn());
    field.setValueReferenceTable(this.getValueReferenceTable());
    field.setPpsTable(this.getPpsTable());
    field.setPpsEventTable(this.getPpsEventTable());
    field.setUserPositionTable(this.getUserPositionTable());
    field.setEventResourceSystemListId(this.getEventResourceSystemListId());
    return field;
  }
}
