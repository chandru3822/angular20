package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.EmailSenderQuery;
import com.albatross.api.v1.flow.model.EmailSender;
import com.albatross.api.v1.flow.model.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-16.
 */
@Slf4j
@Service
public class EmailSenderService {
    @Autowired
    private SqlCache sqlCache;

    @Autowired
    private SecurityService securityService;

    public List<EmailSender> getEmailSenders() {
    List<EmailSender> results = sqlCache.queryBySql(EmailSenderQuery.getEmailSenders, null, EmailSender.class);
    return results;
  }

  public void saveEmailSenders(List<EmailSender> emailSenders) {
    User user = securityService.getCurrentUser();
    for(EmailSender emailSender : emailSenders) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("emailAddress", emailSender.getEmailAddress());
        params.put("archived", emailSender.getArchived());

      if(null != emailSender.getId()) {
        params.put("id", emailSender.getId());
        params.put("modifiedById", user.trueUserId());
        sqlCache.updateBySql(EmailSenderQuery.updateEmailSender, params);
      } else {
        params.put("createdById", user.trueUserId());
        sqlCache.updateBySql(EmailSenderQuery.insertEmailSender, params);
      }
    }
  }

  public void deleteEmailSenders(List<Long> emailSenderIds) {
    HashMap<String, Object> params = new HashMap<>();
    for(Long emailSendersId : emailSenderIds) {
      params.put("id", emailSendersId);
      sqlCache.updateBySql(EmailSenderQuery.deleteEmailSender, params);
    }
  }
}
