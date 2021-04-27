package com.albatross.api.v1.company.blueraven.controllers.commissionManagement;

import com.albatross.api.v1.company.blueraven.models.commissionManagement.PlanUser;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.CommissionManagementService;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.OverridePlanService;
import com.google.common.collect.ImmutableMap;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Hidden
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/commissionManagement/overrides")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class OverridePlanController {

    private final OverridePlanService overridePlanService;
    private final CommissionManagementService commissionManagementService;

    @GetMapping(value = "/plans/{positionId}")
    public String getOverridePlans(@PathVariable Long positionId) {
        return overridePlanService.findOverridePlans(positionId, false);
    }

    @GetMapping(value = "/plans/{positionId}/active")
    public String getActiveOverridePlans(@PathVariable Long positionId) {
        return overridePlanService.findOverridePlans(positionId,true);
    }

    @GetMapping(value = "/_search")
    public String findOverridePlanUsers(@RequestParam String query,
                                        @RequestParam(required = false) Long positionId,
                                        @RequestParam(required = false) Long planId,
                                        @RequestParam(required = false) Boolean isReceiving) {
        String userForOverrides = overridePlanService.findUserForOverrides(query, positionId, planId, isReceiving);
        return userForOverrides;
    }

    @PostMapping(value = "")
    public ResponseEntity<Object> createOverridePlanDetails(@RequestBody OverridePlanService.OverridePlan overridePlan) {
        String detail = overridePlanService.updateOverridePlan(overridePlan);
        return detail == null ? ResponseEntity.notFound().build() : ResponseEntity.ok(detail);
    }

    @PostMapping(value = "/{planId}/updateUser")
    public void updatePlanUser(@PathVariable Long planId,
                               @RequestBody PlanUser planUser) {
        overridePlanService.updatePlanUser(planId, planUser);
    }

    @GetMapping(value = "/{id}")
    public ResponseEntity<Object> getOverridePlanDetails(@PathVariable Long id) {
        String detail = overridePlanService.findOverridePlanDetail(id);
        return detail == null ? ResponseEntity.notFound().build() : ResponseEntity.ok(detail);
    }

    @PostMapping(value = "/{id}/approve")
    public ResponseEntity<Object> approvePlan(@PathVariable Long id) {
        overridePlanService.approvePlan(id);
        return getOverridePlanDetails(id);
    }

    @PostMapping(value = "/{id}/clone")
    public ResponseEntity cloneOverridePlanById(@PathVariable Long id,
                                                @RequestBody OverridePlanService.CloneOverridePlan overridePlan) {
        try {
            Optional<Long> cloneOverridePlan = overridePlanService.cloneOverridePlan(id, overridePlan, overridePlan.getUserId());
            if (cloneOverridePlan.isPresent()) {
                String overridePlanDetail = overridePlanService.findOverridePlanDetail(cloneOverridePlan.get());
                return ResponseEntity.ok(overridePlanDetail);
            }else{
                log.error("COMMISSION: Unable to create a clone of override plan id={}", id);
            }

        } catch (SQLException e) {
            log.error("COMMISSION: Error creating cloned override plane", e);
        } catch (OverridePlanService.BackdatedPlanApprovalRequiredException e) {
            SimpleDateFormat f = new SimpleDateFormat("MM/dd/yyyy");
            Map<String, String> body = ImmutableMap.of("msg", e.getMessage(),
                    "reason", "approvalRequired",
                    "userStartDate", f.format(e.getUserStartDate()),
                    "payrollId", String.valueOf(e.getPayrollId()),
                    "payrollEndDate", f.format(e.getPayrollEndDate()));
            return ResponseEntity.badRequest()
                    .body(body);
        } catch (OverridePlanService.BackdatedPlanApprovalBadCredentialsException e) {
            Map<String, String> body = ImmutableMap.of("msg", e.getMessage(),
                    "reason", "badCredentials");
            return ResponseEntity.badRequest()
                    .body(body);
        }

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }

    @PostMapping(value = "/{id}/inactivate")
    public ResponseEntity<Object> inactivateOverridePlan(@PathVariable Long id) {
        overridePlanService.inactivatePlan(id);
        return getOverridePlanDetails(id);
    }

    @DeleteMapping(value = "/{id}")
    public void deletePlan(@PathVariable Long id) {
        overridePlanService.deletePlan(id);
    }

    @PostMapping(value = "/{id}/receivingUsers")
    public String addReceivingUser(@PathVariable Long id,
                                 @RequestBody OverridePlanService.OverrideReceivingUser receivingUser) {
        return overridePlanService.addReceivingUser(id, receivingUser);
    }

    @PostMapping(value = "/{id}/receivingUser")
    public void updateReceivingUser(@PathVariable Long id,
                                    @RequestBody OverridePlanService.OverrideReceivingUser receivingUser) {
        overridePlanService.updateReceivingUser(id, receivingUser);
    }

    @GetMapping(value = "/{id}/receivingUsers")
    public String getReceivingUsers(@PathVariable Long id) {
        return overridePlanService.getPlanReceivingUsers(id);
    }

    @DeleteMapping(value = "/{id}/receivingUsers/{userId}")
    public void deleteReceivingUser(@PathVariable Long id,
                                    @PathVariable Long userId) {
        overridePlanService.deleteReceivingUser(id, userId);
    }

    @GetMapping(value = "/assignedUsers/{userId}/history")
    public ResponseEntity<String> getAssignedUserHistory(@PathVariable Long userId) {
        String userDetail = overridePlanService.getAssignedUserDetail(userId);
        return userDetail != null ? ResponseEntity.ok(userDetail) : ResponseEntity.notFound().build();
    }

    @PostMapping(value = "/{id}/assignedUsers/{positionId}")
    public ResponseEntity addAssignedUser(@PathVariable Long id,
                                          @PathVariable Long positionId,
                                          @RequestBody OverridePlanService.OverrideAssignedUser assignedUser) {
        try {
            String result = overridePlanService.updateAssignedUser(id, assignedUser, positionId);
            return ResponseEntity.ok(result);
        } catch (OverridePlanService.BackdatedPlanApprovalRequiredException e) {
            SimpleDateFormat f = new SimpleDateFormat("MM/dd/yyyy");
            Map<String, String> body = ImmutableMap.of("msg", e.getMessage(),
                    "reason", "approvalRequired",
                    "userStartDate", f.format(e.getUserStartDate()),
                    "payrollId", String.valueOf(e.getPayrollId()),
                    "payrollEndDate", f.format(e.getPayrollEndDate()));
            return ResponseEntity.badRequest()
                    .body(body);
        } catch (OverridePlanService.BackdatedPlanApprovalBadCredentialsException e) {
            Map<String, String> body = ImmutableMap.of("msg", e.getMessage(),
                    "reason", "badCredentials");
            return ResponseEntity.badRequest()
                    .body(body);
        }
    }

    @GetMapping(value = "/{id}/assignedUsers")
    public String getAssignedUsers(@PathVariable Long id){
        return overridePlanService.getPlanAssignedUsers(id);
    }

    @DeleteMapping(value = "/{id}/assignedUsers/{assignedUserId}")
    public void deleteAssignedUser(@PathVariable Long id,
                                   @PathVariable Long assignedUserId) {
        overridePlanService.deleteAssignedUser(id, assignedUserId);
    }
}
