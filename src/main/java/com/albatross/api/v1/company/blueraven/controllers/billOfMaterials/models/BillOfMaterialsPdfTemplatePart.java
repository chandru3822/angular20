package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class BillOfMaterialsPdfTemplatePart {
    private String objectType;
    private BillOfMaterialsPdfTemplatePartDetails details;

}
