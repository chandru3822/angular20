package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ListOfValue;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class ListOfValueService {

    private final SqlCache sqlCache;

    public List<ListOfValue> getByCustomFieldId(Long customFieldId) {
        return sqlCache.query("listOfValue.getByCustomFieldId", Map.of("customFieldId", customFieldId), ListOfValue.class);
    }
}
