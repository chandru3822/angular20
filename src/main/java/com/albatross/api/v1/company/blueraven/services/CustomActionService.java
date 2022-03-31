package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.CustomActionController;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Optional;


/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class CustomActionService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public CustomActionController.RescheduleResponse rescheduleCloserAppt(Long ppsEventId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ppsEventId", ppsEventId);
    params.put("userId", user.getId());
    Optional<CustomActionController.RescheduleResponse> result = sqlCache.get("customAction.rescheduleCloserAppt", params, CustomActionController.RescheduleResponse.class);
    if(result.isPresent()) {
      return result.get();
    } else {
      CustomActionController.RescheduleResponse temp = new CustomActionController.RescheduleResponse();
      temp.setFailReason("Unhandled Exception");
      temp.setSuccess(false);
      return temp;
    }
  }

}
