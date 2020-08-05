package com.blueraven.service;

import com.blueraven.model.User;

import javax.activation.DataSource;
import java.net.URL;
import java.util.Map;

public interface EmailMessage {
    String getSubject();
    String getRecipientEmailAddr();
    User getRecipientUser();
    String getSenderEmailAddr();
    String getTemplate();
    Map<String, DataSource> getAttachments();
    URL getUnsubscribeUrl();
}
