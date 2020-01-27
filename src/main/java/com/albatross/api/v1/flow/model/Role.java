package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 12/17/19.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Role {

  private Long id;
  private String roleName;
  private Boolean archived;

  private List<CompanyFeature> companyFeatures;

}

