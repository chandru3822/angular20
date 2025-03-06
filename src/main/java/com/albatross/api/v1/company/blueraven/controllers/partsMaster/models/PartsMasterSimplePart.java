package com.albatross.api.v1.company.blueraven.controllers.partsMaster.models;

import lombok.Data;

import java.util.UUID;

@Data
public class PartsMasterSimplePart {
    private Long id;
    private UUID partsMasterGroupUuid;
    private String description, brand, partNumber, objectCode, objectType;

}
