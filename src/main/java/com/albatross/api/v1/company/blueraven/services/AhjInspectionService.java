package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.AhjInspection;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-17.
 */
@Service
public class AhjInspectionService {
  @Autowired
  private SqlCache sqlCache;
  private ObjectMapper om;

  public Optional<AhjInspection> createAhjInspection(Long ahjId, Long userId, AhjInspection inspection) {
    return saveAhjInspection(ahjId, userId, null, inspection);
  }

  public Optional<AhjInspection> saveAhjInspection(Long ahjId, Long userId, Long inspectionId, AhjInspection inspection) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);
    params.put("inspectionFee", inspection.getInspectionFee());
    params.put("reInspectionFee", inspection.getReInspectionFee());
    params.put("paymentMethod", inspection.getPaymentMethod());
    params.put("inspectionTimeWindow", inspection.getInspectionTimeWindow());
    params.put("brsInspectionRep", inspection.getBrsInspectionRep());
    params.put("portalUrl", inspection.getPortalUrl());
    params.put("portalUsername", inspection.getPortalUsername());
    params.put("portalPassword", inspection.getPortalPassword());
    params.put("obtainingResultsMethod", inspection.getObtainingResultsMethod());
    params.put("approvalDocumentMethod", inspection.getApprovalDocumentMethod());
    params.put("obtainingResultsPortalUrl", inspection.getObtainingResultsPortalUrl());
    params.put("obtainingResultsPortalUsername", inspection.getObtainingResultsPortalUsername());
    params.put("obtainingResultsPortalPassword", inspection.getObtainingResultsPortalPassword());
    params.put("businessLicense", inspection.getBusinessLicense());
    params.put("contractorLicense", inspection.getContractorLicense());
    params.put("homeownerRequiredOnSite", inspection.getHomeownerRequiredOnSite());
    params.put("currentUser", userId);
    params.put("callForTimeWindow", inspection.getCallForTimeWindow());
    params.put("ladderRequired", inspection.getLadderRequired());
    params.put("timeWindow", inspection.getTimeWindow());
    params.put("timeWindowCallTime", inspection.getTimeWindowCallTime());
    params.put("timeWindowPhone", inspection.getTimeWindowPhone());
    params.put("fallProtectionRequired", inspection.getFallProtectionRequired());

    //notes
    params.put("schedulingNote", inspection.getSchedulingNote());
    params.put("technicianInstructionNote", inspection.getTechnicianInstructionNote());
    params.put("schedulingWithCustomerNote", inspection.getSchedulingWithCustomerNote());
    params.put("obtainingResultsNote", inspection.getObtainingResultsNote());
    params.put("reinspectionNote", inspection.getReinspectionNote());
    params.put("documentationNote", inspection.getDocumentationNote());
    params.put("mpuInspectionNote", inspection.getMpuInspectionNote());

    //custom fields
    params.put("homeownerRequired", inspection.getHomeownerRequired());
    params.put("brsTechRequired", inspection.getBrsTechRequired());

    //all the various type related fields
    params.put("schedulingMethodTypeId", inspection.getSchedulingMethodTypeId());
    params.put("schedulingMethodTypeOther", inspection.getSchedulingMethodTypeOther());
    params.put("handyInformationTypeId", inspection.getHandyInformationTypeId());
    params.put("handyInformationTypeOther", inspection.getHandyInformationTypeOther());
    params.put("schedulingLeadTimeTypeId", inspection.getSchedulingLeadTimeTypeId());
    params.put("schedulingLeadTimeTypeOther", inspection.getSchedulingLeadTimeTypeOther());
    params.put("inspectionCapacityTypeId", inspection.getInspectionCapacityTypeId());
    params.put("inspectionCapacityTypeOther", inspection.getInspectionCapacityTypeOther());
    params.put("siteAccessTypeId", inspection.getSiteAccessTypeId());
    params.put("siteAccessTypeOther", inspection.getSiteAccessTypeOther());
    params.put("roughInspectionRequiredTypeId", inspection.getRoughInspectionRequiredTypeId());
    params.put("roughInspectionRequiredTypeOther", inspection.getRoughInspectionRequiredTypeOther());
    params.put("midpointInspectionLeadTimeTypeId", inspection.getMidpointInspectionLeadTimeTypeId());
    params.put("midpointInspectionLeadTimeTypeOther", inspection.getMidpointInspectionLeadTimeTypeOther());
    params.put("soladeckAccessTypeId", inspection.getSoladeckAccessTypeId());
    params.put("soladeckAccessTypeOther", inspection.getSoladeckAccessTypeOther());
    params.put("placardRequiredTypeId", inspection.getPlacardRequiredTypeId());
    params.put("placardRequiredTypeOther", inspection.getPlacardRequiredTypeOther());
    params.put("requiredInspectionTypes", inspection.getRequiredInspectionTypes());
    params.put("representativeRequiredOnsiteTypeId", inspection.getRepresentativeRequiredOnsiteTypeId());
    params.put("representativeRequiredOnsiteTypeOther", inspection.getRepresentativeRequiredOnsiteTypeOther());
    params.put("specialEquipmentTypeId", inspection.getSpecialEquipmentTypeId());
    params.put("specialEquipmentTypeOther", inspection.getSpecialEquipmentTypeOther());
    params.put("plansRequiredTypeId", inspection.getPlansRequiredTypeId());
    params.put("plansRequiredTypeOther", inspection.getPlansRequiredTypeOther());
    params.put("specialDocumentsTypeId", inspection.getSpecialDocumentsTypeId());
    params.put("specialDocumentsTypeOther", inspection.getSpecialDocumentsTypeOther());
    params.put("resultsDocumentationTypeId", inspection.getResultsDocumentationTypeId());
    params.put("resultsDocumentationTypeOther", inspection.getResultsDocumentationTypeOther());
    params.put("reinspectionFeeTypeId", inspection.getReinspectionFeeTypeId());
    params.put("reinspectionFeeTypeOther", inspection.getReinspectionFeeTypeOther());


    if (inspectionId == null) {
      inspectionId = sqlCache.updateReturningId("ahj.inspection.create", params, "id").longValue();
    } else {
      params.put("id", inspectionId);
      sqlCache.update("ahj.inspection.update", params);
    }

    HashMap<String, Object> keyParam = new HashMap<>();
    keyParam.put("id", inspectionId);

    return sqlCache.get("ahj.inspection.findById", keyParam, AhjInspection.class);
  }
}