package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.services.dto.DtoProcess;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.hateoas.EntityModel;

@EqualsAndHashCode(callSuper = false)
@Data
@AllArgsConstructor
public class ApiProcess extends EntityModel<ApiProcess> {
    private Long identifier, companyIdentifier;
    private String name;

    public static ApiProcess from(DtoProcess other) {
        return new ApiProcess(other.getId(), other.getCompanyId(), other.getName());
    }
}
