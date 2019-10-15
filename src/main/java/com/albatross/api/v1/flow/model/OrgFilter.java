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
public class OrgFilter {

  private Long companyId, orgLevelId, rank;
  private String levelName;
  private List<Org> orgs;
  private Boolean showType;
}

