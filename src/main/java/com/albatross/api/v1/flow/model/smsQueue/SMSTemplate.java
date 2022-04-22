package com.albatross.api.v1.flow.model.smsQueue;

import lombok.Data;

import java.util.Date;

@Data
public class SMSTemplate {
    private Long id;
    private String name, template;
    private Date date_created, date_updated;
}
