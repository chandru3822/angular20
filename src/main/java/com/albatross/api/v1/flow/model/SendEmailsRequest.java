package com.blueraven.view.api.v1.dto.admin;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.util.List;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SendEmailsRequest {
    private String from, subject, template, templatingEngine;
    private List<Long> userIds;
}
