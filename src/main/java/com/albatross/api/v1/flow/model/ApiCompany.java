package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.services.dto.DtoCompany;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.hateoas.EntityModel;


@EqualsAndHashCode(callSuper = false)
@Data
@AllArgsConstructor
public class ApiCompany extends EntityModel<ApiCompany> {
    private Long identifier;
    private String name;

    public static ApiCompany from(DtoCompany other) {
        return new ApiCompany(other.getId(), other.getName());
    }
}
