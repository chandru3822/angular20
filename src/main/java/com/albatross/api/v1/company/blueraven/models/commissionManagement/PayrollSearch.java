package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
public class PayrollSearch {

    private String customerName;
    private Long salesRepId, projectId, positionId;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private Date startDate, endDate;

    public String getCustomerName() {
        if (customerName == null) {
            return null;
        }
        return customerName.trim().toLowerCase();
    }
}
