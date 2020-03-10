package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Date;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CloserOverrideAssignment {
    private Long userId;
    private String firstName, lastName;
    private String status;
    private BigDecimal totalAssigned;
    private LocalDate effectiveDate;
    private Date dateCreated, dateModified, dateApproved;
    private Long createdById, modifiedById, approvedById;

    private Long regionalManagerId;
    private String regionalManager;
    private BigDecimal officeOverrideAllowance;

    private Long recruitedByUserId;
    private String recruitedBy;

    private Long overrideCloserId;

    private List<OverrideRecipient> recipients;

    @JsonProperty("closerName")
    public String getCloserName() {
        return firstName + " " + lastName;
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class OverrideRecipient {
        private Long id, rowId;
        private String fullName;
        private BigDecimal amount;
    }
}
