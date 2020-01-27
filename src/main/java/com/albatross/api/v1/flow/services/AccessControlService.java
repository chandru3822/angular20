package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;


/**
 * Created by randanunn on 12/17/19.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class AccessControlService {

  private final SqlCache sqlCache;

  public List<FeatureAccessControl> getAccessControlList() {
    List<FeatureAccessControl> results = sqlCache.query("accessControl.getAll", Collections.emptyMap(), FeatureAccessControl.class);
    return results;
  }

}
