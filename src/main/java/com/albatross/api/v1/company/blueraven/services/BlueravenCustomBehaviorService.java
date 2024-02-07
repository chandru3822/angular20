package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.CustomBehaviorQuery;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.User;
import com.mypurecloud.sdk.v2.ApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.*;


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
  private final Five9Service five9Service;

  private final Set<Long> FIVE9_LEAD_LEVELS = new HashSet<>(Arrays.asList(1L, 2L, 40L, 201L, 202L, 203L, 204L, 205L, 206L, 207L, 208L, 209L));

  public void handleCustomContactCreation(Long contactId, Boolean isNew, List<CustomFieldValue> cfvs, List<CustomFieldGroup> cfgs) {
    Long leadLevel = getContactLeadLevel(cfgs);

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

      if (leadLevel != null && FIVE9_LEAD_LEVELS.contains(leadLevel)) {
        five9Service.handleContact(contactId, cfvs, false, false, leadLevel);
      }
      else {
        genesysService.handleAddContact(contactId, cfvs);
      }
    }
    else {
      if (leadLevel != null && FIVE9_LEAD_LEVELS.contains(leadLevel)) {
        five9Service.handleContact(contactId, cfvs, true, false, leadLevel);
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

  private Long getContactLeadLevel(List<CustomFieldGroup> cfgs) {
    CustomFieldGroup paidLeadGen = cfgs.stream()
      .filter(cfv -> cfv.getGroupName().equals("Paid Lead Gen"))
      .findFirst()
      .orElse(null);

    if (paidLeadGen != null) {
      Optional<Long> leadLevel = paidLeadGen.getCustomFieldValues().stream()
        .filter(cfv -> cfv.getFieldName().equals("Lead Level"))
        .map(CustomFieldValue::getIntValue)
        .filter(Objects::nonNull)
        .findFirst();

      if (leadLevel.isPresent()) {
        return leadLevel.get();
      }
    }
    return null;
  }
}
