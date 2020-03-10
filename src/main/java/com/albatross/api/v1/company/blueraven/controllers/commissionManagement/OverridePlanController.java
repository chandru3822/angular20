package com.albatross.api.v1.company.blueraven.controllers.commissionManagement;

import com.albatross.api.v1.company.blueraven.services.commissionManagement.CommissionManagementService;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.OverridePlanService;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Map;
import java.util.Optional;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/commissionManagemnt/overrides")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class OverridePlanController {

    private final OverridePlanService overridePlanService;
    private final CommissionManagementService commissionManagementService;

    @GetMapping(value = "")
    public String getOverridePlans() {
        return overridePlanService.findOverridePlans();
    }

    @GetMapping(value = "/milestones")
    public String getOverrideMilestoneConditions() {
        return commissionManagementService.findMilestoneQueryConditions(2L);
    }

    @GetMapping(value = "/_search")
    public String findOverridePlanUsers(@RequestParam String query,
                                        @RequestParam(required = false) Long positions) {
        String userForOverrides = overridePlanService.findUserForOverrides(query, positions);
        return userForOverrides;
    }

//    @GetMapping(value = "/export/allocations",
//                produces = "text/csv")
//    public ResponseEntity exportAllocationsAsCsv() throws IOException {
//        // set up CSV writing
//        CsvMapper mapper = new CsvMapper();
//        CsvSchema schema = mapper.typedSchemaFor(OverridePlanAllocationCsvTemplate.class)
//                                 .withHeader();
//        ObjectWriter writer = mapper.writer(schema);
//        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
//
//        // get override deets and write to CSV
//        try (SequenceWriter outToBuffer = writer.writeValues(buffer)) {
//            // first, get deets
//            Collection<OverridePlanAllocationCsvTemplate> details = Collections2.transform(
//                    overridePlanService.getAllocationDetails(),
//                    OverridePlanAllocationCsvTemplate::new);
//
//            // next, write them to a buffer so we can identify errors before writing across the network
//            outToBuffer.writeAll(details);
//            outToBuffer.flush();
//
//            // finally, write to network because no errors were encountered
//            return ResponseEntity.ok(buffer.toString("UTF-8"));
//        } catch (IOException e) {
//            log.error("Encountered error while writing override allocation to CSV", e);
//            return ResponseEntity.status(500)
//                                 .body("Encountered error while writing override allocation to CSV");
//        }
//    }

    @PostMapping(value = "")
    public ResponseEntity<Object> createOverridePlanDetails(@RequestBody OverridePlanService.OverridePlan overridePlan) {
        String detail = overridePlanService.updateOverridePlan(null, overridePlan);
        return detail == null ? ResponseEntity.notFound().build() : ResponseEntity.ok(detail);
    }

    @PostMapping(value = "/{id}")
    public ResponseEntity<Object> updateOverridePlanDetails(@PathVariable Long id,
                                                            @RequestBody OverridePlanService.OverridePlan overridePlan) {
        String detail = overridePlanService.updateOverridePlan(id, overridePlan);
        return detail == null ? ResponseEntity.notFound().build() : ResponseEntity.ok(detail);
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
                log.error("Unable to create a clone of override plan id={}", id);
            }

        } catch (SQLException e) {
            log.error("Error creating cloned override plane", e);
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

    @PostMapping(value = "/{id}/milestone")
    public void addMilestone(@PathVariable Long id, @RequestBody OverridePlanService.OverrideMilestone overrideMilestone) {
        overridePlanService.updateMilestone(id, overrideMilestone);
    }

    @DeleteMapping(value = "/{id}/milestone/{milestoneQueryId}")
    public void deleteMilestone(@PathVariable Long id, @PathVariable Long milestoneQueryId) {
        overridePlanService.deleteMilestone(id, milestoneQueryId);
    }

    @PostMapping(value = "/{id}/receivingUsers")
    public void addReceivingUser(@PathVariable Long id,
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

    @PostMapping(value = "/{id}/assignedUsers")
    public ResponseEntity addAssignedUser(@PathVariable Long id,
                                          @RequestBody OverridePlanService.OverrideAssignedUser assignedUser) {
        try {
            overridePlanService.updateAssignedUser(id, assignedUser);
            String s = String.format("/api/v1/plans/overrides/%d/assignedUsers", id);
            return ResponseEntity.created(URI.create(s))
                    .build();
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
