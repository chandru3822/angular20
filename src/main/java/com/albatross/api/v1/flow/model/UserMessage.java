package com.blueraven.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by randa on 5/21/17.
 * !Describe Purpose!
 */
@Getter @Setter
public class UserMessage {


    private Long closerId;

    private String customerName, closerName, closerPhone, email;

//    these are used for Closer Availability Reminder Texts
    private Date appointmentStartTime;
    private Long appointmentId;

}
