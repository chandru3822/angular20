package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.services.dto.DtoProcess;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.springframework.hateoas.EntityModel;

@EqualsAndHashCode(callSuper = false)
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ApiProcess extends EntityModel<ApiProcess> {
    private Long id, companyId, createdById, modifiedById, parentCompanyId;
    private String processName;
    private Boolean archived;

    public static ApiProcess from(DtoProcess other) {
        return new ApiProcess(other.getId(), other.getCompanyId(), other.getCreatedById(), other.getModifiedById(),
            other.getParentCompanyId(), other.getProcessName(), other.getArchived());
    }
}
