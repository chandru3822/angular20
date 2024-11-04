package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
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
}
