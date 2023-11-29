package com.albatross.api.v1.company.blueraven.integration.bitrise;

import com.albatross.api.config.company.blueraven.BitriseProperties;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;


@Slf4j
@Service
public class BitriseService {
  private final SecurityService securityService;
  private final SqlCache sqlCache;
  private final BitriseProperties bitriseProperties;
  private final BitriseApi bitriseApi;

  public BitriseService(SecurityService securityService, SqlCache sqlCache, BitriseProperties bitriseProperties) {
    this.securityService = securityService;
    this.sqlCache = sqlCache;
    this.bitriseProperties = bitriseProperties;
    this.bitriseApi = BitriseApi.connect(bitriseProperties.getKey(), bitriseProperties.getSlug());
  }

  public void triggerBitriseBuild(BitriseApiBuildRequest request) {
    bitriseApi.triggerAppBuild(request);
  }

}
