package com.albatross.api.v1.flow.model.smartlist;

import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.DataTypeRequirement;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class SmartlistRequirement extends SmartlistSuperField {

  // @TODO humes: should probably make this have a field of type SmartlistField since it uses most
  // of those fields anyways

  private Long operatorTypeId,
      dataTypeRequirementId,
      listOfValueId,
      systemListOptionId,
      customSqlOptionId;
  private String requirementValue, secondaryRequirementValue, operatorType;
  private Boolean immutable, isCustomValue;

  private List<Long> listOfValueIds;

  private List<ListOfValue> availableListOfValues;

  private DataTypeRequirement dataTypeRequirement;

  // Used for smartlist generation
  @JsonIgnore private String valueReferenceTable, valueEventReferenceTable;

  @JsonIgnore private CustomField customField;

  // @TODO: #smartlistsv2 - temp until v1 is gone
  public com.albatross.api.v1.flow.model.smartlistv1.SmartlistRequirement toV1(ObjectMapper om) {
    var requirement = om.convertValue(this, com.albatross.api.v1.flow.model.smartlistv1.SmartlistRequirement.class);
    requirement.setValueReferenceTable(this.getValueReferenceTable());
    requirement.setValueEventReferenceTable(this.getValueEventReferenceTable());
    requirement.setCustomField(this.getCustomField());
    requirement.setReferenceTable(this.getReferenceTable());
    requirement.setReferenceColumn(this.getReferenceColumn());
    requirement.setJoinTable(this.getJoinTable());
    requirement.setJoinColumn(this.getJoinColumn());
    requirement.setValueReferenceTable(this.getValueReferenceTable());
    requirement.setPpsTable(this.getPpsTable());
    requirement.setPpsEventTable(this.getPpsEventTable());
    requirement.setUserPositionTable(this.getUserPositionTable());
    requirement.setEventResourceSystemListId(this.getEventResourceSystemListId());
    return requirement;
  }
}
