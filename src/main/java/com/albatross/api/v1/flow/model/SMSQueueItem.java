package com.blueraven.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.joda.time.DateTime;

import java.util.List;

@Data
public class SMSQueueItem {

    private Long id, userId, recipient_type_id;
    private String firstName, lastName, email, message;
    private String messageGroup, messageSid, messageStatus, fromPhone, toPhone, errorMessage;
    private List<String> mediaUrls;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private DateTime created, updated, twilioCreated, twilioSent, twilioDelivered;

    public String getFullname() {
        return String.format("%s %s", firstName, lastName);
    }

    public RecordType getRecipientType() {
        return RecordType.values()[recipient_type_id.intValue()];
    }
}
