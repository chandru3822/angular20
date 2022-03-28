package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.CustomActionController;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class CustomActionService {

  private final SqlCache sqlCache;

  public CustomActionController.RescheduleResponse rescheduleCloserAppt(Long ppsEventId) {
    CustomActionController.RescheduleResponse temp = new CustomActionController.RescheduleResponse();
    temp.setFailReason("This is not a first time appointment.");
    temp.setSuccess(false);
    temp.setLeadSource("Closer Gen");
    temp.setLeadSourceId(523L);
    return temp;
  }

}
