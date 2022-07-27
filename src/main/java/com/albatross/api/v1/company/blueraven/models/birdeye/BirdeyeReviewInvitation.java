package com.albatross.api.v1.company.blueraven.models.birdeye;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class BirdeyeReviewInvitation {
    private String id, birdeyeBusinessId;
    private String customerName, customerEmail, customerPhone, customerId, birdeyeCustomerId;
    private int projectId;
    private Boolean sendSms, saveCfv;
    private List<String> requestersEmails;
}
