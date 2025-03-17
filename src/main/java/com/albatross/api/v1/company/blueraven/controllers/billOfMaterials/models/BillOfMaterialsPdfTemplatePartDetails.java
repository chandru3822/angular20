package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BillOfMaterialsPdfTemplatePartDetails {
    private String partNumber, description;
    private Long quantity;
}
