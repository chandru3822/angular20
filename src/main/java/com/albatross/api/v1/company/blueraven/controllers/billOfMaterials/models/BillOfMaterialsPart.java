package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.UUID;

@Data
@NoArgsConstructor
public class BillOfMaterialsPart {
    private Long id, quantity, partsMasterId, customPartId, permitPackLogNbr, supplierId, createdById, modifiedById;
    private Date dateCreated, dateModified;
    private Boolean supplierConfirmed, archived;
    private UUID partsMasterGroupUuid;
    private String description, brand, partNumber, supplierName, objectCode, objectType;
}
