package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.company.blueraven.models.*;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
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

    @Autowired
    private ObjectMapper om;

    @Autowired
    private SecurityService securityService;

    @Autowired
    private BlueravenCustomFieldGroupService blueravenCustomFieldGroupService;

    public List<AhjUtility> getAllAhjUtilities() {
        HashMap<String, Object> params = new HashMap<>();
        return sqlCache.query("ahj.utility.list.all", params, AhjUtility.class);
    }

    public Optional<AhjUtilityDetail> getUtilityById(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        return sqlCache.get("ahj.utility.detailById", params, new AhjUtilityDetailMapper<>(AhjUtilityDetail.class, om));
    }

    public Optional<AhjUtilityDetail> simpleUpdateUtility(AhjUtility utility) {
        User currentUser = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("currentUser", currentUser.getId());
        params.put("utilityName", utility.getName());
        params.put("metroAreaId", utility.getMetroAreaId());
        params.put("archived", utility.getArchived());
        params.put("id", utility.getId());

        sqlCache.update("ahj.utility.simple.update", params);
        return getUtilityById(utility.getId());
    }

    public Optional<AhjUtilityDetail> updateUtility(AhjUtility utility) {
        User currentUser = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("currentUser", currentUser.getId());
        params.put("utilityName", utility.getName());
        params.put("metroAreaId", utility.getMetroAreaId());
        params.put("timelinesAndStages", utility.getTimelinesAndStages());
        params.put("regulatedBy", utility.getRegulatedBy());
        params.put("monthlyFacilityCharge", utility.getMonthlyFacilityCharge());
        params.put("populationOfService", utility.getPopulationOfService());
        params.put("netMeteringRate", utility.getNetMeteringRate());
        params.put("rebateRates", utility.getRebateRates());
        params.put("utilityRateNotes", utility.getUtilityRateNotes());
        params.put("customerSignatureInstructions", utility.getCustomerSignatureInstructions());
        params.put("expectedApprovalTimeline", utility.getExpectedApprovalTimeline());
        params.put("rejectionInstructions", utility.getRejectionInstructions());
        params.put("notes", utility.getNotes());
        params.put("overviewOfSubmissionProcess", utility.getOverviewOfSubmissionProcess());
        params.put("submissionInstructions", utility.getSubmissionInstructions());
        params.put("timelines", utility.getTimelines());
        params.put("ptoFollowupInstructions", utility.getPtoFollowupInstructions());
        params.put("finalCompletionInstructions", utility.getFinalCompletionInstructions());
        params.put("archived", utility.getArchived());

        Long id;

        if(null != utility.getId()){
            id = utility.getId();
            params.put("id", utility.getId());
            sqlCache.update("ahj.utility.update", params);
        } else {
            id = sqlCache.updateReturningId("ahj.utility.insert", params, "id").longValue();
        }

        blueravenCustomFieldGroupService.handleSavingCustomFieldValues(utility.getCustomFieldGroups(), id);

        return getUtilityById(id);
    }

    // CONTACTS
    public void saveUtilityContact(Long utilityId, Long contactId) {
        HashMap<String, Object> params = new HashMap<>();

        params.put("ahjUtilityId", utilityId);
        params.put("ahjContactId", contactId);
        sqlCache.update("ahj.utility.contact.create", params);
    }

    public static class BaseAhjDetailMapper<T> extends BeanPropertyRowMapper<T> {
        private final ObjectMapper objectMapper;

        public BaseAhjDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
            super(mappedClass);
            this.objectMapper = objectMapper;
        }
    }

    public static class AhjUtilityDetailMapper<T> extends BaseAhjDetailMapper<T> {

        public AhjUtilityDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
            super(mappedClass, objectMapper);
        }

        @Override
        protected void initBeanWrapper(BeanWrapper bw) {
            TypeReference<List<AhjChecklistItem>> itemRef = new TypeReference<>() {};
            TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};
            TypeReference<List<AhjLink>> linkTypeRef = new TypeReference<>() {};
            TypeReference<List<AhjRequirement>> requirementTypeRef = new TypeReference<>() {};

            bw.registerCustomEditor(List.class, "customerSignatureLinks",
                    new JsonCollectionDeserializer(linkTypeRef, super.objectMapper));

            bw.registerCustomEditor(List.class, "ptoLinks",
                    new JsonCollectionDeserializer(linkTypeRef, super.objectMapper));

            bw.registerCustomEditor(List.class, "ptoFollowupLinks",
                    new JsonCollectionDeserializer(linkTypeRef, super.objectMapper));

            bw.registerCustomEditor(List.class, "submissionLinks",
                    new JsonCollectionDeserializer(linkTypeRef, super.objectMapper));

            bw.registerCustomEditor(List.class, "submissionChecklist",
                    new JsonCollectionDeserializer(itemRef, super.objectMapper));

            bw.registerCustomEditor(List.class, "approvalChecklist",
                    new JsonCollectionDeserializer(itemRef, super.objectMapper));

            bw.registerCustomEditor(List.class, "ptoChecklist",
                    new JsonCollectionDeserializer(itemRef, super.objectMapper));

            bw.registerCustomEditor(List.class, "utilityInspectionChecklist",
                    new JsonCollectionDeserializer(itemRef, super.objectMapper));

            bw.registerCustomEditor(List.class, "contacts",
                    new JsonCollectionDeserializer(contactTypeRef, super.objectMapper));

            bw.registerCustomEditor(List.class, "utilityRequirements",
                    new JsonCollectionDeserializer(requirementTypeRef, super.objectMapper));
        }
    }
}
