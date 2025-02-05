package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models;

import com.albatross.api.v1.company.blueraven.controllers.partsMaster.models.PartsMasterCustomValuesRow;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.UUID;

@Data
@NoArgsConstructor
public class BillOfMaterialsPart {
    private Long id, quantity, bomId, partsMasterId, createdById, modifiedById;
    private UUID partsMasterUuid;
    private Date dateCreated, dateModified;
    private Boolean archived;
    private PartsMasterCustomValuesRow partDetails;
}
