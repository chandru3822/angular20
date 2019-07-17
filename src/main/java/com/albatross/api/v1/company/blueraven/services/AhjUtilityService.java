package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.v1.company.blueraven.models.AhjUtility;
import com.albatross.api.v1.company.blueraven.models.AhjUtilityDetail;

import com.albatross.api.utils.SqlCache;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Slf4j
@Service
public class AhjUtilityService {
    @Autowired
    private SqlCache sqlCache;

    public List<AhjUtility> getAllAhjUtilities() {
        HashMap<String, Object> params = new HashMap<>();
        return sqlCache.query("ahj.utility.list.all", params, AhjUtility.class);
    }

    public Optional<AhjUtilityDetail> getUtilityById(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        return sqlCache.get("ahj.utility.detailById", params, AhjUtilityDetail.class);
    }

    public Optional<AhjUtilityDetail> simpleUpdateUtility(AhjUtility utility) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("utilityName", utility.getName());
        params.put("metroAreaId", utility.getMetroAreaId());
        params.put("active", utility.getActive());
        params.put("id", utility.getId());

        sqlCache.update("ahj.utility.simple.update", params);
//        return getUtilityById(utility.getId());
        return null;
    }

    public Optional<AhjUtilityDetail> updateUtility(AhjUtility utility) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("utilityName", utility.getName());
        params.put("metroAreaId", utility.getMetroAreaId());
        params.put("acDisconnectRequired", utility.getAcDisconnectRequired());
        params.put("pvProductionMeterRequired", utility.getPvProductionMeterRequired());
        params.put("meterCanTapsAllowed", utility.getMeterCanTapsAllowed());
        params.put("pvacSwapLocations", utility.getPvAcSwapLocations());
        params.put("utilityWarningLabelsOverride", utility.getUtilityWarningLabelsOverride());
        params.put("timelinesAndStages", utility.getTimelinesAndStages());
        params.put("regulatedBy", utility.getRegulatedBy());
        params.put("monthlyFacilityCharge", utility.getMonthlyFacilityCharge());
        params.put("populationOfService", utility.getPopulationOfService());
        params.put("netMeteringRate", utility.getNetMeteringRate());
        params.put("rebateRates", utility.getRebateRates());
        params.put("utilityRateNotes", utility.getUtilityRateNotes());
        params.put("rebateProgramTypeId", utility.getRebateProgramTypeId());
        params.put("rebateProgramTypeOther", utility.getRebateProgramTypeOther());
        params.put("signatureRequiredPriorTypeId", utility.getSignatureRequiredPriorTypeId());
        params.put("signatureRequiredPriorTypeOther", utility.getSignatureRequiredPriorTypeOther());
        params.put("signatureRequestedAtTypeId", utility.getSignatureRequestedAtTypeId());
        params.put("signatureRequestedAtTypeOther", utility.getSignatureRequestedAtTypeOther());
        params.put("customerSignatureInstructions", utility.getCustomerSignatureInstructions());
        params.put("expectedApprovalTimeline", utility.getExpectedApprovalTimeline());
        params.put("customerSignatureResubmissionTypeId", utility.getCustomerSignatureResubmissionTypeId());
        params.put("customerSignatureResubmissionTypeOther", utility.getCustomerSignatureResubmissionTypeOther());
        params.put("rejectionInstructions", utility.getRejectionInstructions());
        params.put("notes", utility.getNotes());
        params.put("overviewOfSubmissionProcess", utility.getOverviewOfSubmissionProcess());
        params.put("whenToCreateApplicationTypeId", utility.getWhenToCreateApplicationTypeId());
        params.put("whenToCreateApplicationTypeOther", utility.getWhenToCreateApplicationTypeOther());
        params.put("submissionMethodTypeId", utility.getSubmissionMethodTypeId());
        params.put("submissionMethodTypeOther", utility.getSubmissionMethodTypeOther());
        params.put("interconnectionFeeTypeId", utility.getInterconnectionFeeTypeId());
        params.put("interconnectionFeeTypeOther", utility.getInterconnectionFeeTypeOther());
        params.put("submissionInstructions", utility.getSubmissionInstructions());
        params.put("utilityMethodTypeId", utility.getUtilityMethodTypeId());
        params.put("utilityMethodTypeOther", utility.getUtilityMethodTypeOther());
        params.put("inspectionSubmissionTypeId", utility.getInspectionSubmissionTypeId());
        params.put("inspectionSubmissionTypeOther", utility.getInspectionSubmissionTypeOther());
        params.put("utilityInspectionRequiredTypeId", utility.getUtilityInspectionRequiredTypeId());
        params.put("utilityInspectionRequiredTypeOther", utility.getUtilityInspectionRequiredTypeOther());
        params.put("followupMethodTypeId", utility.getFollowupMethodTypeId());
        params.put("followupMethodTypeOther", utility.getFollowupMethodTypeOther());
        params.put("timelines", utility.getTimelines());
        params.put("ptoFollowupInstructions", utility.getPtoFollowupInstructions());
        params.put("finalCompletionInstructions", utility.getFinalCompletionInstructions());
        params.put("active", utility.getActive());

        Long id;

        if(null != utility.getId()){
            id = utility.getId();
            params.put("id", utility.getId());
            sqlCache.update("ahj.utility.update", params);
        } else {
            id = sqlCache.updateReturningId("ahj.utility.insert", params, "id").longValue();
        }

//        return getUtilityById(id);
        return null;
    }
}