package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.List;

@Data
@NoArgsConstructor
public class BillOfMaterials {

    private Long id, bomTypeId, projectId, createdById, modifiedById;
    private String bomType;
    private List<BillOfMaterialsPart> partsList;
    private Date dateCreated, dateModified;
    private Boolean archived;
}
