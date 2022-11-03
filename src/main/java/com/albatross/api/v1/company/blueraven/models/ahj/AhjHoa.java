package com.albatross.api.v1.company.blueraven.models.ahj;

import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import lombok.Data;

import java.util.List;

@Data
public class AhjHoa {
    private Long id;
    private Long ahjHoaId, ahjId, stateId, metroAreaId, companyStateId, managementCompanyId;
    private String name, metroArea, state, managementCompany;
    private Boolean archived;

    //this is only used for saving custom field groups
    List<CustomFieldGroup> customFieldGroups;


}
