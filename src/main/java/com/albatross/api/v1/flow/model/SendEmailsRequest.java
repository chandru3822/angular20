package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.util.List;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SendEmailsRequest {
    private String from, subject, template, templatingEngine;
    private List<Long> userIds;
}
