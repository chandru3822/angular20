package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.services.dto.DtoCustomer;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.hateoas.EntityModel;

@EqualsAndHashCode(callSuper = false)
@Data
@AllArgsConstructor
public class ApiCustomer extends EntityModel<ApiCompany> {
    private Long identifier, companyIdentifier;
    private String firstName, lastName, fullName, email, phone;

    public static ApiCustomer from(DtoCustomer other) {
        return new ApiCustomer(other.getId(),
                other.getCompanyId(),
                other.getFirstName(),
                other.getLastName(),
                other.getFullName(),
                other.getEmail(),
                other.getPhone());
    }
}
