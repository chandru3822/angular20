package com.albatross.api.v1.flow.model.smsQueue;

import lombok.Data;

import java.util.List;

@Data
public class SMSQueuePage {
    private Long pageSize;
    private Long pageNumber;
    private Long itemCount;
    private Long pages;
    private List<SMSQueueItem> items;
}
