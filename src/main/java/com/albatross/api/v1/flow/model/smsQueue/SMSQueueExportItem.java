package com.albatross.api.v1.flow.model.smsQueue;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.joda.time.DateTime;

import java.util.Objects;

@Data
public class SMSQueueExportItem {

    //I had to create this so that the export fields are all aligned correctly without having to do a
    // _.forEach() on so many results.  Only add to this object if you are adding to the SMS Export
    // otherwise use SMSQueueItem.java
    private String fullName, email, toPhone, message;
    private String messageStatus;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "MM-dd-yyyy h:mm a")
    private DateTime created, twilioSent, twilioDelivered;

    public String getCsvHeadersString() {
        return String.join(",","User","Email","Phone","Message","Status","Created","Sent","Delivered")+"\n";
    }

    public String getCsvDataString() {
        return  Objects.toString(fullName, "")+","+ Objects.toString(email, "")+","+
                Objects.toString(toPhone, "")+","+ Objects.toString(messageStatus, "")+","+
                Objects.toString(created, "")+","+ Objects.toString(twilioSent, "")+","+
                Objects.toString(twilioDelivered, "")+"\n";
    }
}
