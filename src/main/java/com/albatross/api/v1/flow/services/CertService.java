package com.albatross.api.v1.flow.services;

import com.albatross.api.config.ScheduledConfig;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Cert;
import com.albatross.api.v1.flow.model.CertAdmin;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.CertQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.util.*;

/**
 * Created by randanunn on 12/17/19. !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CertService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final CommunicationService communicationService;

  @Value("${app.home_url}")
  private String homeUrl;

  public List<Cert> getAllCerts() {
    return sqlCache.queryBySql(CertQuery.getAll, Map.of(), Cert.class);
  }

  public Cert saveCert(Cert f) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("certName", f.getCertName());
    params.put("notes", f.getNotes());
    params.put("expirationDate", f.getExpirationDate());

    Long id;
    if (null != f.getId()) {
      id = f.getId();
      params.put("id", id);
      sqlCache.updateBySql(CertQuery.updateCert, params);

    } else {
      id = sqlCache.updateBySqlReturningId(CertQuery.insertCert, params, "id").longValue();
    }
    return getOneCert(id);
  }

  public Cert getOneCert(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Cert> f = sqlCache.getBySql(CertQuery.getOneCert, params, Cert.class);
    return f.orElse(null);
  }

  public void deleteCert(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.updateBySql(CertQuery.deleteCert, params);
  }

  public void sendEmails() {
    //could have put a property on our user accounts but...i wasn't sure if i should
    List<CertAdmin> adminEmailsToNotify = sqlCache.queryBySql(CertQuery.getCertAdmins, Collections.emptyMap(), CertAdmin.class);

    try {
      InputStream inputStream =
      ScheduledConfig.class.getResourceAsStream(
        "/communication/templates/expiring-certs.ftl.html");
      String template = IOUtils.toString(inputStream);

      List<Cert> expiring30dayCerts = sqlCache.queryBySql(CertQuery.getExpiring30DayCerts, Collections.emptyMap(), Cert.class);
      List<Cert> expiring7dayCerts = sqlCache.queryBySql(CertQuery.getExpiring7DayCerts, Collections.emptyMap(), Cert.class);

      if(!expiring30dayCerts.isEmpty() || !expiring7dayCerts.isEmpty()) {
        Map<String, Object> context = new HashMap<>();
        context.put("expiring30dayCerts", expiring30dayCerts);
        context.put("expiring7dayCerts", expiring7dayCerts);
        context.put("adminPageLink", homeUrl + "/admin/certs");

        for(CertAdmin admin : adminEmailsToNotify) {
          communicationService.sendEmail(
            "NOTICE: Expiring BR Certs",
            admin.getEmail(),
            template,
            context,
            "cert.monitoring@7oaksgroup.com",
            "7Oaks Cert Monitoring",
            2417172L,
            null);
        }

        for(Cert c : expiring30dayCerts) {
          Map<String, Object> params = new HashMap<>();
          params.put("id", c.getId());

          sqlCache.updateBySql(CertQuery.update30DayNotice, params);
        }
      }
    } catch (IOException e) {
      throw new RuntimeException(e);
    }

  }
}
