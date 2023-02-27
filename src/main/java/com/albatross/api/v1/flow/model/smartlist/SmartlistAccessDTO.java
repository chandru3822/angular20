package com.albatross.api.v1.flow.model.smartlist;

import lombok.Data;

import java.util.List;

//Ugly data holder class to know if smartlist's public status should be updated,
//new access should be added, and/or existing access should be updated
@Data
public class SmartlistAccessDTO {

  private Smartlist smartlist;

  private boolean updatePublic, isPublic;

  private SmartlistAccessControl newAccess;

  private List<SmartlistAccessControl> updatedAccess;
}
