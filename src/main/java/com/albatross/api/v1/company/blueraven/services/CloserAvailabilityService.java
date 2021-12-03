package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.CloserAvailabilityController;
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

  public String getBrsCloserAvailability(CloserAvailabilityController.EventSearchParams esp) {
    HashMap<String, Object> params = new HashMap<>();

    params.put("postalCodeZoneUserIds", esp.getPostalCodeZoneUserIds());
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());

    String results = sqlCache.queryForObject("closerAvailability.get", params, String.class);

    return null == results ? "[]": results;
  }

}
