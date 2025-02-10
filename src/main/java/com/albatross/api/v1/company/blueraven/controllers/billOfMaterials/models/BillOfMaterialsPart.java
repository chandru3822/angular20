package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models;

import com.albatross.api.v1.company.blueraven.controllers.partsMaster.models.PartsMasterCustomValuesRow;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@NoArgsConstructor
public class BillOfMaterialsPart {
    private Long id, quantity, partsMasterId, supplierId, createdById, modifiedById;
    private Date dateCreated, dateModified;
    private Boolean supplierConfirmed, archived;
    private PartsMasterCustomValuesRow partDetails;
}
