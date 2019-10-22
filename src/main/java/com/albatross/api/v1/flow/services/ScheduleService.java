package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Schedule;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ScheduleService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  public List<Schedule> getSchedulesForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Schedule> results = sqlCache.query("schedule.getAllForCompany", params, Schedule.class);
    return results;
  }


  public Schedule getSchedule(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Schedule> result = sqlCache.get("schedule.getOne", params, Schedule.class);
    return result.orElse(null);
  }

  public Schedule saveSchedule(Schedule schedule) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("aField", schedule.getId());

    Long id;
    if (null != schedule.getId()) {
      id = schedule.getId();
      params.put("modifiedById", user.getCompanyId());
      params.put("id", id);
      sqlCache.update("schedule.updateSchedule", params);
    } else {
      params.put("createdById", user.getCompanyId());
      id = sqlCache.updateReturningId("schedule.insertSchedule", params, "id").longValue();
    }

    return getSchedule(id);
  }


}
