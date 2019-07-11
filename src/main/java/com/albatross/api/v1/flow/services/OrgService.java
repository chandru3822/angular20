package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Org;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class OrgService {

  @Autowired
  SqlCache sqlCache;

  public List<Org> getOrgsForCompany(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    List<Org> results = sqlCache.query("org.getAllForCompany", params, Org.class);
    return results;
  }
  public List<Org> getOwningOrgsForCompany(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    List<Org> results = sqlCache.query("org.getOwningOrgsForCompany", params, Org.class);
    return results;
  }

}
