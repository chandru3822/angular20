package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.App;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class AppService {

    private final SqlCache sqlCache;
    private final SecurityService securityService;

    public List<App> getApps() {
      //doing this for all contexts for now so they can download it from anywhere
      return sqlCache.query("app.getAll", Collections.emptyMap(), App.class);
    }

}
