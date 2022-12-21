package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.CloserAvailabilityController;
import com.albatross.api.v1.company.blueraven.services.queries.CloserAvailabilityQuery;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueOwner;
import com.albatross.api.v1.flow.queries.WorkQueueQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;


/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class CloserAvailabilityService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public String getBrsCloserAvailability(CloserAvailabilityController.EventSearchParams esp) {
    HashMap<String, Object> params = new HashMap<>();

    params.put("postalCodeZoneUserIds", esp.getPostalCodeZoneUserIds());
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());

    String results = sqlCache.queryForObjectBySql(CloserAvailabilityQuery.get, params, String.class);

    return null == results ? "[]": results;
  }

}
