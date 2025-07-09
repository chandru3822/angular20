package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@NoArgsConstructor
public class ContactWithCfvs {

  private Contact contact;

  @NonNull
  private List<CustomFieldValue> cfvs;

  //when saving cfvs web and mobile send in dirtyCfvs. but the response we need to send back needs to retun the cfgs, not the cfvs
  //and i am lazy so i am putting it into here
  private List<CustomFieldGroup> cfgs;
  
  private List<Long> projectIds;
}
