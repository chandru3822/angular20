package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.v1.company.blueraven.model.AhjUtility;
import com.albatross.api.utils.SqlCache;
//import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

//import javax.inject.Inject;
import java.util.HashMap;
import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @__({@Inject}))
public class AhjUtilityService {

    @Autowired
    private SqlCache sqlCache;

    public List<AhjUtility> getAllAhjUtilities() {
        HashMap<String, Object> params = new HashMap<>();
        return sqlCache.query("ahj.utility.list.all", params, AhjUtility.class);
    }
}