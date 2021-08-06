package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.MetroArea;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-16.
 */
@Slf4j
@Service
public class MetroAreaService {
    @Autowired
    private SqlCache sqlCache;

    public List<MetroArea> getAllActiveMetroAreas() {
      return sqlCache.query("metroArea.getAllActive", Collections.emptyMap(), MetroArea.class);
    }
}
