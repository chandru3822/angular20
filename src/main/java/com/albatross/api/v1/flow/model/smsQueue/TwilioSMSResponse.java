package com.albatross.api.v1.flow.model.smsQueue;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;

import java.io.IOException;
import java.util.Date;

@Data
public class TwilioSMSResponse {
  private static final ObjectMapper om = new ObjectMapper();

  @JsonProperty(value = "MessagingServiceSid")
  private String messagingServiceSid;

  @JsonProperty(value = "From")
  private String from;

  @JsonProperty(value = "MessageSid")
  private String messageSid;

  @JsonProperty(value = "SmsStatus")
  private String smsStatus;

  @JsonProperty(value = "ApiVersion")
  private String apiVersion;

  @JsonProperty(value = "AccountSid")
  private String accountSid;

  @JsonProperty(value = "MessageStatus")
  private String messageStatus;

  /**
   * See the following for more details:
   * https://www.twilio.com/docs/sms/api/message-resource#delivery-related-errors
   */
  @JsonProperty(value = "ErrorMessage")
  private String errorMessage;

  @JsonProperty(value = "To")
  private String to;

  private int attempts;
  private Date dateReceived;

  public static TwilioSMSResponse fromJSON(String json) throws IOException {
    return om.readValue(json, TwilioSMSResponse.class);
  }

  public void addAttempt() {
    attempts++;
  }

  public Date getDateReceived() {
    if (dateReceived == null) {
      dateReceived = new Date();
    }

    return dateReceived;
  }

  public String toJSON() throws JsonProcessingException {
    // it seems that we have to use json.toString() to avoid an "end of stream" error...?
    return om.writeValueAsString(this).toString();
  }
}
