package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.enums.RecipientType;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

@Getter
@Setter
public class SMSQueueItem {

    private Long id, userId, recipient_type_id;
    private String firstName, lastName, fullName, email, message;
    private String messageGroup, messageSid, messageStatus, fromPhone, toPhone, errorMessage, projectStatus;
    private List<String> mediaUrls;
    private boolean priority, messageRead;
    private Owner owner;

    private Date created, updated, twilioCreated, twilioSent, twilioDelivered, lastMessageSent, lastMessageReceived;

    public boolean getPrioirty() {return priority;}
    public boolean getMessageRead() {return messageRead;}

    public String getFullname() {
        return String.format("%s %s", firstName, lastName);
    }

    public RecipientType getRecipientType() {
        return RecipientType.values()[recipient_type_id.intValue()];
    }
}
