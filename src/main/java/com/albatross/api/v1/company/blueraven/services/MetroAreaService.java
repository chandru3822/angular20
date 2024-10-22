package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.CustomFieldValue;
import com.albatross.api.v1.company.blueraven.models.MetroArea;
import com.albatross.api.v1.company.blueraven.services.queries.MetroAreaQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Joseph Canto on 2019-07-16.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MetroAreaService {

    private final SqlCache sqlCache;

    public List<MetroArea> getAllActiveMetroAreas() {
      return sqlCache.queryBySql(MetroAreaQuery.getAllActive, Collections.emptyMap(), MetroArea.class);
    }

    public List<CustomFieldValue> getAllowedModulesForMetroArea(Long metroId){
        Map<String, Object> params = new HashMap<>();
        params.put("metroAreaId", metroId);
        return sqlCache.queryBySql(MetroAreaQuery.getAllowedModules, params, CustomFieldValue.class);
    }
}
