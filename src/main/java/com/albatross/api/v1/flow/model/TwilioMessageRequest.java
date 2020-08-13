package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.Date;
import java.util.HashMap;

@Data
public class TwilioMessageRequest {
    private Long id;

    @JsonProperty(value = "MessageSid")
    private String messageSid;

    @JsonProperty(value = "SmsSid")
    private String smsSid;

    @JsonProperty(value = "AccountSid")
    private String accountSid;

    @JsonProperty(value = "MessagingServiceSid")
    private String messagingServiceSid;

    @JsonProperty(value = "From")
    private String from;

    @JsonProperty(value = "To")
    private String to;

    @JsonProperty(value = "Body")
    private String body;

    @JsonProperty(value = "NumMedia")
    private Integer numMedia;

    private Date date_received;

    public HashMap<String, Object> toHashMap() {
        HashMap<String, Object> data = new HashMap<>();

        data.put("messageSid", messageSid);
        data.put("smsSid", smsSid);
        data.put("accountSid", accountSid);
        data.put("messagingServiceSid", messagingServiceSid);
        data.put("from", from);
        data.put("to", to);
        data.put("body", body);
        data.put("numMedia", numMedia);

        return data;
    }
}
