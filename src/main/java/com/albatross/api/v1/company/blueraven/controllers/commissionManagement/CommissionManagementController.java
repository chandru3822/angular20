package com.albatross.api.v1.company.blueraven.controllers.commissionManagement;

import com.albatross.api.v1.company.blueraven.models.commissionManagement.*;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.CommissionManagementService;
import com.albatross.api.v1.flow.model.User;
import com.google.common.collect.ImmutableMap;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/commissionManagement")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class CommissionManagementController {

    private final CommissionManagementService commissionManagementService;

    @PostMapping(value = "")
    public ResponseEntity<Object> updateCommissionPlan(@RequestBody CommissionPlan commissionPlan) {
        String detail = commissionManagementService.updateCommissionPlan(commissionPlan);
        return detail == null ? ResponseEntity.notFound().build() : ResponseEntity.ok(detail);
    }

    @PostMapping(value = "/{id}/clone")
    public ResponseEntity cloneOverridePlanById(@PathVariable Long id,
                                                @RequestBody CommissionPlan commissionPlan) {
        try {
            Optional<Long> clonePlan = commissionManagementService.clonePlan(id, commissionPlan);
            if (clonePlan.isPresent()) {
                String commissionPlanDetail = commissionManagementService.getCommissionPlanDetails(clonePlan.get());
                return ResponseEntity.ok(commissionPlanDetail);
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        } catch (CommissionManagementService.BackdatedPlanApprovalRequiredException e) {
            SimpleDateFormat f = new SimpleDateFormat("MM/dd/yyyy");
            Map<String, String> body = ImmutableMap.of("msg", e.getMessage(),
                    "reason", "approvalRequired",
                    "userStartDate", f.format(e.getUserStartDate()),
                    "payrollId", String.valueOf(e.getPayrollId()),
                    "payrollEndDate", f.format(e.getPayrollEndDate()));
            return ResponseEntity.badRequest()
                    .body(body);
        } catch (CommissionManagementService.BackdatedPlanApprovalBadCredentialsException e) {
            Map<String, String> body = ImmutableMap.of("msg", e.getMessage(),
                    "reason", "badCredentials");
            return ResponseEntity.badRequest()
                    .body(body);
        } catch (CommissionManagementService.PlanStartDateBeforeHireDate e) {
            Map<String, Object> body = ImmutableMap.of("msg", e.getMessage(),
                    "reason", "startDateBeforeHireDate",
                    "problems", e.getProblematicUsers().stream()
                                                           .map(BackdatedUser::new)
                                                           .collect(Collectors.<BackdatedUser>toList()));
            return ResponseEntity.badRequest()
                    .body(body);
        }
    }

    @Data
    private static class BackdatedUser {
        private static final SimpleDateFormat f = new SimpleDateFormat("MM/dd/yy");
        private final String userName;
        private final String hireDate;

        public BackdatedUser(User user) {
            this.userName = user.getFirstName() + " " + user.getLastName();
            //todo: figure this out since it is a custom field
//            this.hireDate = f.format(user.getHireDate());
            this.hireDate = null;
        }
    }

    @DeleteMapping(value = "/{id}")
    public void deletePlan(@PathVariable Long id) {
        commissionManagementService.deletePlan(id);
    }

    @PostMapping(value = "/{id}/approve")
    public String approvePlan(@PathVariable Long id) {
        commissionManagementService.approvePlan(id);
        return getCommissionPlanDetail(id);
    }

    @PostMapping(value = "/{id}/inactivate")
    public String inactivatePlan(@PathVariable Long id) {
        commissionManagementService.inactivatePlan(id);
        return getCommissionPlanDetail(id);
    }

    @GetMapping(value = "/milestones")
    public List<CommissionManagementService.MilestoneType> getActiveMilestones() {
        return commissionManagementService.findActiveMilestones();
    }

    @GetMapping(value = "/{id}/availableMilestones")
    public List<CommissionManagementService.MilestoneType> getAvailableMilestones(@PathVariable Long id) {
        return commissionManagementService.findAvailableMilestones(id);
    }

    @GetMapping(value = "/plans/{positionId}")
    public List<CommissionPlan> getCommissionPlans(@PathVariable Long positionId) {
        return commissionManagementService.getCommissionPlans(positionId);
    }

    @GetMapping(value = "/plan/{planId}")
    public String getCommissionPlanDetail(@PathVariable Long planId) {
        return commissionManagementService.getCommissionPlanDetails(planId);
    }

    @GetMapping(value = "/plan/{planId}/users")
    public String getCommissionPlanUsers(@PathVariable Long planId) {
        return commissionManagementService.getCommissionPlanUsers(planId);
    }

    @GetMapping(value = "/{id}/availableSources")
    public List<Source> getAvailableSources(@PathVariable Long id) {
        return commissionManagementService.getAvailableSources(id);
    }

    @GetMapping(value = "/_search")
    public String findCommissionPlanUsers(@RequestParam String query,
                                          @RequestParam(required = false) String positions,
                                          @RequestParam(required = false) Long planId) {
        String userForCommissions = commissionManagementService.findUserForCommissions(query, positions, planId);
        return userForCommissions;
    }

    @GetMapping(value = "/closers")
    public List<ClosersPlan> getClosers() {
        return commissionManagementService.getClosers();
    }

    @GetMapping(value = "/setters")
    public List<ClosersPlan> getSetters() {
      return commissionManagementService.getSetters();
    }

    @DeleteMapping(value = "/{id}/commissionUser/{commissionPlanUserId}")
    public void deleteUser(@PathVariable Long id,
                           @PathVariable Long commissionPlanUserId) {
        commissionManagementService.deleteUser(id, commissionPlanUserId);
    }

    @PostMapping(value = "/{planId}/milestone")
    public String saveMilestone(@PathVariable Long planId,
                              @RequestBody Milestone milestone) {
        return commissionManagementService.saveMilestone(planId, milestone);
    }

    @DeleteMapping(value = "/{planId}/milestone/{id}")
    public void removeMilestone(@PathVariable Long planId,
                                @PathVariable Long id) {
        commissionManagementService.removeMilestone(planId, id);
    }

    @PutMapping(value = "/{planId}/milestone")
    public void updateMilestone(@PathVariable Long planId,
                                @RequestBody Milestone milestone) {
        commissionManagementService.updateMilestone(planId, milestone);
    }

    @GetMapping(value = "/sources")
    public List<Source> getSources() {
        return commissionManagementService.getSources();
    }

    @PostMapping(value = "/{planId}/source")
    public Source saveSource(@PathVariable Long planId, @RequestBody Source source) {
        return commissionManagementService.saveSource(planId, source);
    }

    @PutMapping(value = "/{planId}/source")
    public Source updateSource(@PathVariable Long planId, @RequestBody Source source) {
        return commissionManagementService.updateSource(planId, source);
    }

    @DeleteMapping(value = "/{planId}/source/{sourceId}")
    public void removeSource(@PathVariable Long planId, @PathVariable Long sourceId) {
        commissionManagementService.removeSource(planId, sourceId);
    }

    @PostMapping(value = "/{planId}/updateUser")
    public void updatePlanUser(@PathVariable Long planId,
                               @RequestBody PlanUser user) {
        commissionManagementService.updatePlanUser(planId, user);
    }

    @PostMapping(value = "/{planId}/users/{positionId}")
    public ResponseEntity insertUser(@PathVariable Long planId,
                                     @PathVariable Long positionId,
                                     @RequestBody PlanUser user) {
        try {
            commissionManagementService.insertUser(planId, user, positionId);
//            String users = commissionManagementService.getCommissionPlanUsers(planId);
            String plans = commissionManagementService.getPlans(user.getUserId());
            return ResponseEntity.ok(plans);
        } catch (CommissionManagementService.BackdatedPlanApprovalRequiredException e) {
            SimpleDateFormat f = new SimpleDateFormat("MM/dd/yyyy");
            Map<String, String> body = ImmutableMap.of("msg", e.getMessage(),
                                                       "reason", "approvalRequired",
                                                       "userStartDate", f.format(e.getUserStartDate()),
                                                       "payrollId", String.valueOf(e.getPayrollId()),
                                                       "payrollEndDate", f.format(e.getPayrollEndDate()));
            return ResponseEntity.badRequest()
                                 .body(body);
        } catch (CommissionManagementService.BackdatedPlanApprovalBadCredentialsException e) {
            Map<String, String> body = ImmutableMap.of("msg", e.getMessage(),
                    "reason", "badCredentials");
            return ResponseEntity.badRequest()
                    .body(body);
        }
    }

    @PostMapping(value = "/customerSearch/{userId}")
    public List<Payroll> customerSearch(@PathVariable Long userId,
                                        @RequestBody String query) {
        return commissionManagementService.customerSearch(userId, query);
    }

    @GetMapping(value = "/commissionUser/{userId}/history")
    public String getOldPlans(@PathVariable Long userId) {
        return commissionManagementService.getCommissionPlanUserHistory(userId);
    }

    @GetMapping(value = "/closerDetails/{userId}")
    public String getCloserDetails(@PathVariable Long userId) {
        return commissionManagementService.getCloserDetails(userId);
    }
}


