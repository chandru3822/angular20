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
        String detail = commissionManagementService.updateCommissionPlan(commissionPlan.getId(), commissionPlan);
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

    @GetMapping(value = "/plans")
    public List<CommissionPlan> getCommissionPlans() {
        return commissionManagementService.getCommissionPlans();
    }

    @GetMapping(value = "/plan/{planId}")
    public String getCommissionPlanDetail(@PathVariable Long planId) {
        return commissionManagementService.getCommissionPlanDetails(planId);
    }

    @GetMapping(value = "/plan/{planId}/users")
    public String getCommissionPlanUsers(@PathVariable Long planId) {
        return commissionManagementService.getCommissionPlanUsers(planId);
    }

    @GetMapping(value = "/sources")
    public List<GetSource> getSources() {
        return commissionManagementService.getSources();
    }

//    @PostMapping(value = "/notes/{planType}/{planId}/{userId}")
//    public void editNote(@PathVariable Long planType,
//                         @PathVariable Long planId,
//                         @PathVariable Long userId,
//                         @RequestBody String note) {
//        commissionManagementService.editNote(planType, planId, note, userId);
//    }

    @PostMapping(value = "/availableSources")
    public List<GetSource> getAvailableSources(@RequestBody List<Integer> sourceIds) {
        return commissionManagementService.getAvailableSources(sourceIds);
    }

    @GetMapping(value = "/getMilestones")
    public String getMilestones() {
        return commissionManagementService.findMilestoneQueryConditions(1L);
    }


    @GetMapping(value = "/_search")
    public String findCommissionPlanUsers(@RequestParam String query,
                                          @RequestParam(required = false) String positions) {
        String userForCommissions = commissionManagementService.findUserForCommissions(query, positions);
        return userForCommissions;
    }

    @GetMapping(value = "/queryConditions")
    public List<GetQueryCondition> getQueryConditions() {
        return commissionManagementService.getQueryConditions();
    }

    @GetMapping(value = "/closers")
    public List<ClosersPlan> getClosers() {
        return commissionManagementService.getClosers();
    }

    @DeleteMapping(value = "/{id}/commissionUser/{commissionPlanUserId}")
    public void deleteUser(@PathVariable Long id,
                           @PathVariable Long commissionPlanUserId) {
        commissionManagementService.deleteUser(id, commissionPlanUserId);
    }

    @PostMapping(value = "/{planId}/milestone")
    public void saveMilestone(@PathVariable Long planId,
                              @RequestBody Milestone milestone) {
        commissionManagementService.saveMilestone(planId, milestone);
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

    @PostMapping(value = "/{planId}/source")
    public void saveSource(@PathVariable Long planId, @RequestBody Source source) {
        commissionManagementService.saveSource(planId, source);
    }

    @PutMapping(value = "/{planId}/source")
    public void updateSource(@PathVariable Long planId, @RequestBody Source source) {
        commissionManagementService.updateSource(planId, source);
    }

    @DeleteMapping(value = "/{planId}/source")
    public void removeSource(@PathVariable Long planId, @RequestBody Source source) {
        commissionManagementService.removeSource(planId, source);
    }

    @PostMapping(value = "/{planId}/updateUser")
    public void updatePlanUser(@PathVariable Long planId,
                               @RequestBody PlanUser user) {
        commissionManagementService.updatePlanUser(planId, user);
    }

    @PostMapping(value = "/{planId}/users")
    public ResponseEntity insertUser(@PathVariable Long planId,
                                     @RequestBody PlanUser user) {
        try {
            commissionManagementService.insertUser(planId, user);
            String users = commissionManagementService.getCommissionPlanUsers(planId);
            return ResponseEntity.ok(users);
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

    @GetMapping(value = "/getPayrollOverridePlans/{userId}")
    public Long getPayrollOverridePlans(@PathVariable Long userId) {
        return commissionManagementService.getPayrollOverridePlans(userId);
    }

    @PostMapping(value = "/getUserPayrolls/{userId}")
    public List<Payroll> getPayrolls(@PathVariable Long userId) {
        return commissionManagementService.getUserPayrolls(userId);
    }

    @GetMapping(value = "/getUserCommissions/{userId}")
    public String getUserCommissions(@PathVariable Long userId) {
        return commissionManagementService.getUserCommissions(userId);
    }

    @GetMapping(value = "/getUserOverrides/{userId}")
    public String getUserOverrides(@PathVariable Long userId) {
        return commissionManagementService.getUserOverrides(userId);
    }

    @PostMapping(value = "/customerSearch/{userId}")
    public List<Payroll> customerSearch(@PathVariable Long userId,
                                        @RequestBody String query) {
        return commissionManagementService.customerSearch(userId, query);
    }

    @PostMapping(value = "/getPayrollDetailsCommissions/{userId}/{payrollId}")
    public String getPayrollDetailsCommissions(@PathVariable Long userId,
                                               @PathVariable Long payrollId) {
        return commissionManagementService.getUserPayrollDetailsCommissions(userId, payrollId);
    }

    @PostMapping(value = "/getPayrollDetailsOverrides/{userId}/{payrollId}")
    public String getPayrollDetailsOverrides(@PathVariable Long userId,
                                             @PathVariable Long payrollId) {
        return commissionManagementService.getPayrollDetailsOverrides(userId, payrollId);
    }

    @GetMapping(value = "/commissionUser/{userId}/history")
    public String getOldPlans(@PathVariable Long userId) {
        return commissionManagementService.getCommissionPlanUserHistory(userId);
    }

    @GetMapping(value = "/closerDetails/{userId}")
    public String getCloserDetails(@PathVariable Long userId) {
        return commissionManagementService.getCloserDetails(userId);
    }


    @GetMapping(value = "/admin/milestoneList")
    public List<GetMilestone> getAdminMilestones() {
        return commissionManagementService.getAdminMilestones();
    }

    @PostMapping(value = "/admin/{id}/save")
    public void adminSave(@PathVariable Long id,
                          @RequestBody String condition) {
        commissionManagementService.adminSave(id, condition);
    }
}


