package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class DataView {

  private Long id, companyId;
  private String viewName, displayName;
  private Boolean archived;
  private List<DataViewFieldConfig> dataViewFieldConfigs;
  private List<Long> companyProcessIds;
  private List<CompanyProcess> companyProcesses;

  //only used for saving differences
  private List<Long> editedCompanyProcessIds;
}

