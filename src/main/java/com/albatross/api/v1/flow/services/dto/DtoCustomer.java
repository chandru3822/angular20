package com.albatross.api.v1.flow.services.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class DtoCustomer {
    private Long id, companyId;
    private String firstName, lastName, fullName, email, phone;
}
