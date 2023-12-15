package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.CustomBehaviorQuery;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.User;
import com.mypurecloud.sdk.v2.ApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;


/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class BlueravenCustomBehaviorService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final GenesysService genesysService;

  public void handleCustomContactCreation(Long contactId, Boolean isNew, List<CustomFieldValue> cfvs) {

    if(isNew) {
      User user = securityService.getCurrentUser();

      Map<String, Object> params = new HashMap<>();
      params.put("contactId", contactId);
      params.put("userId", user.getId());

      //lead source detail: always set to the value from the org (if present)
      params.put("valueToSave", null);
      params.put("cfgaId", 396);
      sqlCache.queryBySql(CustomBehaviorQuery.saveValueFromOrg, params, String.class);

      //lead source: if a value was sent in, do nothing. otherwise use from org if present
      Optional<CustomFieldValue> leadSourceCfv = cfvs.stream().filter(cfv -> cfv.getCustomFieldGroupAssignmentId() == 395).findFirst();
      if(leadSourceCfv.isEmpty()) {
        //if there is a value in the field, the normal save will have already handled that
        params.put("cfgaId", 395);
        sqlCache.queryBySql(CustomBehaviorQuery.saveValueFromOrg, params, String.class);
      }

      //add contact to genesys stuff
      genesysService.handleAddContact(contactId, cfvs);
    }
    else {
      try {
        genesysService.updateContact(contactId);
      } catch (ApiException e) {
        JSONObject apiException = new JSONObject(e.getRawBody());
        String msg = "GENE: Error updating contact: {}";
        //log.error(msg, apiException.getString("message"));
      }
      catch (IOException e) {
        String msg = "GENE: Error updating contact: {}";
        //log.error(msg, e.getMessage());
      }
    }
  }
}
