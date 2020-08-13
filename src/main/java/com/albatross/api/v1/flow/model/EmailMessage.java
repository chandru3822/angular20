package com.albatross.api.v1.flow.model;

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
