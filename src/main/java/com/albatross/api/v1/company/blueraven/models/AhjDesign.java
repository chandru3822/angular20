package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@Data
public class AhjDesign {
    private Long id;
    private String codes, note, referenceStandards, groundSnowLoad, windSpeed, roofSnowLoad;
    private Long utilityId, electricalCodeId, buildingCodeId, electricalEngineerId,
        structuralEngineerId, stampTypeId, standardRackingEquipmentId,
        raillessLandscapeAttachmentSpacingId, fireSetbacksId, raillessPortraitAttachmentSpacingId,
        standardConduitRunId, warningLabelsId, supplementalGroundRodRequiredId,
        loadStandardId, woodStandardId, ultId, seismicDesignCategoryId,
        roofSnowLoadAhjOverrideId, snowLoadReductionAllowedId, windExposureFactorId,
        windExposureFactorAhjOverrideId, riskCategoryId, structuralPostInstallLetterRequiredId;
}