package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.Date;

@Getter
@Setter
public class Payroll {

    private Long id;
    private BigDecimal currentPay;
    private String description;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private Date periodEnd;
}
