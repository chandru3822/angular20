package com.albatross.api.v1.company.blueraven.controllers.commissionManagement;

import com.albatross.api.v1.company.blueraven.models.commissionManagement.CloserOverrideAssignment;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.OfficeOverrideAllowances;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.OverridePlanServiceV2;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/commissionManagement/overridesV2")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class OverridePlanControllerV2 {
    private final OverridePlanServiceV2 overridePlanService;

    @GetMapping(value = "/assignments/all")
    public ResponseEntity getAllCloserOverrideAssignments() {
        try {
            return ResponseEntity.ok(overridePlanService.getAllCloserOverrideAssignments());
        } catch (RuntimeException e) {
            log.error("Failed to retrieve all closer override assignments", e);
            return ResponseEntity.status(500).body("Failed to retrieve all closer override assignments");
        }
    }

    @GetMapping(value = "/assignments")
    public ResponseEntity getCloserOverrideAssignments(
            @RequestParam Long closerRegionalUserId) {
        try {
            return ResponseEntity.ok(overridePlanService.getCloserOverrideAssignments(closerRegionalUserId));
        } catch (RuntimeException e) {
            log.error("Failed to retrieve closer override assignments", e);
            return ResponseEntity.status(500).body("Failed to retrieve closer override assignments");
        }
    }

    @GetMapping(value = "/pendingAssignments")
    public ResponseEntity getPendingCloserOverrideAssignments() {
        try {
            return ResponseEntity.ok(overridePlanService.getPendingCloserOverrideAssignments());
        } catch (RuntimeException e) {
            log.error("Failed to retrieve closer override assignments", e);
            return ResponseEntity.status(500).body("Failed to retrieve closer override assignments");
        }
    }

    @PutMapping(value = "/setApprovalStatus")
    public void setApprovalStatus(@RequestBody ApprovalStatusRequest req) {
        overridePlanService.setApprovalStatus(
            req.getOverrideCloserId(),
            req.getCurrentUserId(),
            req.getEffectiveDate(),
            req.getStatusTypeId()
        );
    }

    @GetMapping(value = "/assignments/assignableUsers")
    public ResponseEntity getOverrideAssignableUsers() {
        try {
            return ResponseEntity.ok(overridePlanService.getAssignableUsers());
        } catch (RuntimeException e) {
            log.error("Failed to retrieve override assignable users", e);
            return ResponseEntity.status(500).body("{\"message\":\"Failed to retrieve override assignable users\"}");
        }
    }

    @PostMapping(value = "/assignments")
    public ResponseEntity saveOverrideAssignments(@RequestBody UpdateAssignmentEntriesRequest req) {
        try {
            overridePlanService.saveOverrideAssignments(
                req.getCloserId(),
                req.getOverrideCloserId(),
                req.getCreatedById(),
                req.getModifiedById(),
                req.getEffectiveDate(),
                req.getRecipients(),
                req.getIsUpdate()
            );
            return ResponseEntity.ok("{\"message\":\"Nice work.\"}");
        } catch (RuntimeException e) {
            log.error("Failed to save override assignments", e);
            return ResponseEntity.status(500).body("{\"message\":\"Failed to save override assignments\"}");
        }
    }

    @GetMapping(value = "/allowances")
    public ResponseEntity getOfficeAllowances() {
        try {
            return ResponseEntity.ok(overridePlanService.getAllowances());
        } catch (RuntimeException e) {
            log.error("Failed to retrieve office override allowances", e);
            return ResponseEntity.status(500).body("{\"message\":\"Failed to retrieve office override allowances\"}");
        }
    }

    @PostMapping(value = "/allowances")
    public ResponseEntity updateAllowanceEntries(@RequestBody UpdateAllowanceEntriesRequest req) {
        try {
            overridePlanService.updateAllowances(req.getOfficeId(), req.getAllowances());
            return ResponseEntity.ok("{\"message\":\"Well done.\"}");
        } catch (RuntimeException e) {
            log.error("Failed to save office allowances", e);
            return ResponseEntity.status(500).body("{\"message\":\"Failed to save office allowances\"}");
        }
    }

    @GetMapping(value = "/receiving")
    public ResponseEntity getOverridesReceivedForUser(@RequestParam Long userId,
                                                      @RequestParam Boolean isCloserRegional,
                                                      @RequestParam String effectiveDate) {
        try {
            return ResponseEntity.ok(overridePlanService.getOverridesReceivedForOffice(userId, isCloserRegional, effectiveDate));
        } catch (RuntimeException e) {
            log.error("Failed to retrieve overrides received for user " + userId, e);
            return ResponseEntity.status(500).body("{\"message\":\"Failed to retrieve overrides received for user.\"}");
        }
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class ApprovalStatusRequest {
        private Long overrideCloserId, currentUserId;
        private String effectiveDate;
        private Integer statusTypeId;
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class UpdateAllowanceEntriesRequest {
        private Long officeId;
        private List<OfficeOverrideAllowances.AllowanceEntry> allowances;
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class UpdateAssignmentEntriesRequest {
        private Long closerId, officeId, overrideCloserId, createdById, modifiedById;
        private LocalDate effectiveDate;
        private List<CloserOverrideAssignment.OverrideRecipient> recipients;
        private Boolean isUpdate;
    }
}
