package com.albatross.api.v1.flow.model;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;

import java.util.Date;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter
@Setter
public class CustomField {

  private Long id,
      companyDataTypeId,
      listOfValueId,
      companyId,
      defaultFieldId,
      fieldOrder,
      createdById,
      modifiedById,
      customFieldGroupId,
      ancillaryCustomFieldGroupAssignmentId,
      customFieldGroupAssignmentId,
      customFieldObjectTypeId,
      dataTypeId,
      companySystemListId,
      flowCustomFieldId;
  private List<Long> systemListOptionIds;
  private String fieldName,
    fieldCode,
    objectType,
    groupName,
    customFieldSqlKey,
    customFieldSqlReferenceTable,
    processStepName,
    eventName,
    dataType;
  private Boolean archived,
    showOnInsert,
    requireOnInsert, //todo: this needs to go away and fully be replaced by "required" after mobile has matched our code
    required,
    showOnUserProfile,
    hasListValues,
    allowMultiple,
    detailView,
    readonly,
    systemReadonly,
    customFieldGroupAssignmentReadOnly,
    customFieldGroupAssignmentHidden,
    useParentData,
    sortListValuesAlphabetically,
    lazyLoadValues,
    allowNow;
  private List<ListOfValue> listOfValues;
  private List<WhiteListedPosition> whiteListedPositions, hiddenWhiteListedPositions;
  private Date dateCreated, dateModified;
  private Double minValue, maxValue;

  public boolean shouldHaveListOfValues() {
    if (this.listOfValues != null && !this.listOfValues.isEmpty()) {
      return true;
    }

    if (this.customFieldSqlKey != null) {
      return true;
    }

    return this.companySystemListId != null || this.flowCustomFieldId != null;
  }

  public static class CustomFieldMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CustomFieldMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {

      TypeReference<List<ListOfValue>> listOfValueRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "listOfValues", new JsonCollectionDeserializer(listOfValueRef, objectMapper));

      TypeReference<List<Long>> systemListOptionIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "systemListOptionIds",
          new JsonCollectionDeserializer(systemListOptionIdsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> whiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "whiteListedPositions",
          new JsonCollectionDeserializer(whiteListedPositionsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> hiddenWhiteListedPositionsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "hiddenWhiteListedPositions",
          new JsonCollectionDeserializer(hiddenWhiteListedPositionsRef, objectMapper));
    }
  }
}
