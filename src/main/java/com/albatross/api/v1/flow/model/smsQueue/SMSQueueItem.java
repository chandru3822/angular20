package com.albatross.api.v1.flow.model.smsQueue;

import com.albatross.api.v1.flow.enums.RecipientType;
import com.albatross.api.v1.flow.model.Owner;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

@Getter
@Setter
public class SMSQueueItem {

    private Long id, userId, recipient_type_id, projectId, messageSentByUserId;
    private String firstName, lastName, fullName, full_name, email, message;  //wtf why do i have to add full_name to get the value?
    private String messageGroup, messageSid, messageStatus, fromPhone, toPhone, errorMessage, projectStatus, sentByName;
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
