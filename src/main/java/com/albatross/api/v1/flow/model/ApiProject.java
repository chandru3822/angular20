package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.services.dto.DtoProject;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.server.core.Relation;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Relation(value="project", collectionRelation="projects")
public class ApiProject extends EntityModel<ApiProject> {
    private Long identifier, processIdentifier, companyIdentifier, customerIdentifier;
    private String name;

    public static ApiProject from(DtoProject other) {
        return new ApiProject(other.getId(),
                other.getProcessId(),
                other.getCompanyId(),
                other.getCustomerId(),
                other.getName());
    }
}
