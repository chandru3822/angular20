package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.VirtualResourceCapacitySchedule;
import com.albatross.api.v1.flow.queries.CapacityQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;


@Slf4j
@Service
@RequiredArgsConstructor
public class VirtualResourceCapacityService {

    private final SqlCache sqlCache;
    private final SecurityService securityService;


    public List<VirtualResourceCapacitySchedule> getCapacityForRange(Long orgId, String startTime, String endTime){
        HashMap<String, Object> params = new HashMap<>();
        params.put("orgId", orgId);
        params.put("rangeStart", startTime);
        params.put("rangeEnd", endTime);

        return sqlCache.queryBySql(
                CapacityQuery.getForRange,
                params,
                VirtualResourceCapacitySchedule.class
        );
    }

    public Long getCurrentBookedCountForCapacityScheduleRow(Long orgId, String startTime, String endTime){
        HashMap<String, Object> params = new HashMap<>();
        params.put("orgId", orgId);
        params.put("positionId", 761L);//todo: get prod position Id or pass it in with params
        params.put("startTime", startTime);
        params.put("endTime", endTime);

        return sqlCache.queryForObjectBySql(CapacityQuery.getOrgEventCount, params, Long.class);

    }

    public List<VirtualResourceCapacitySchedule> getCapacitySchedule(Long orgId, String rangeStartTime, String rangeEndTime){
        List<VirtualResourceCapacitySchedule> capacitySchedules = getCapacityForRange(orgId, rangeStartTime, rangeEndTime);
        for (VirtualResourceCapacitySchedule cs: capacitySchedules) {
            cs.setCurrentlyBooked(getCurrentBookedCountForCapacityScheduleRow(orgId, cs.getStartTime(), cs.getEndTime()));
        }
        return capacitySchedules;
    }

    public void updateMaxCapacity(List<VirtualResourceCapacitySchedule> resourceCapacitySchedules){
        User user = securityService.getCurrentUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", user.getId());
        params.put("companyId", user.getCompanyId());

        for (VirtualResourceCapacitySchedule capacity: resourceCapacitySchedules) {
            params.put("orgId", capacity.getOrgId());
            params.put("maxCapacity", capacity.getMaxCapacity());
            params.put("startTime", capacity.getStartTime());
            params.put("endTime", capacity.getEndTime());
            sqlCache.updateBySql(CapacityQuery.upsertMaxCapacity, params);
        }
    }

    public List<VirtualResourceCapacitySchedule> duplicatePreviousWeek(Long orgId, String currentWeekStartTime, String currentWeekEndTime){
        User user = securityService.getCurrentUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("orgId", orgId);
        params.put("userId", user.getId());
        params.put("companyId", user.getCompanyId());
        params.put("currentWeekStart", currentWeekStartTime);
        params.put("currentWeekEnd", currentWeekEndTime);

        sqlCache.executeSql(CapacityQuery.duplicateCapacityWeek, params);
        //return getCapcitySchedule for the new week (this will include the existing bookings)
        return getCapacitySchedule(orgId, currentWeekStartTime, currentWeekEndTime);
    }

}
