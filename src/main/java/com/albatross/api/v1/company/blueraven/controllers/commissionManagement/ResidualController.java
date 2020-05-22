package com.albatross.api.v1.company.blueraven.controllers.commissionManagement;

import com.albatross.api.v1.company.blueraven.models.commissionManagement.PlanUser;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.Residual;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.ResidualPlan;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.ResidualPlanAllocation;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.ResidualService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/commissionManagement/residuals")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ResidualController {

    private final ResidualService residualService;

    @PostMapping(value = "")
    public Residual updateResidual(@RequestBody Residual residual) {
        return residualService.updateResidual(residual);
    }

    @DeleteMapping(value = "/{id}")
    public void deleteResidual(@PathVariable Long id) {
        residualService.deleteResidual(id);
    }

    @GetMapping(value = "")
    public List<Residual> getResiduals() {
        return residualService.getResiduals();
    }

    @GetMapping(value = "{id}")
    public Residual getResidual(@PathVariable Long id) {
        return residualService.getResidual(id);
    }

    @GetMapping(value = "/plans")
    public List<ResidualPlan> getResidualPlans() {
        return residualService.getResidualPlans();
    }

    @GetMapping(value = "/plan/{planId}")
    public String getResidualPlanDetails(@PathVariable Long planId) {
        return residualService.getResidualPlanDetails(planId);
    }

    @PostMapping(value = "/plan")
    public ResponseEntity<Object> updateCommissionPlan(@RequestBody ResidualPlan residualPlan) {
        String detail = residualService.updateResidualPlan(residualPlan);
        return detail == null ? ResponseEntity.notFound().build() : ResponseEntity.ok(detail);
    }

    @GetMapping(value = "/residualPlanUser/{userId}/history")
    public String getOldPlans(@PathVariable Long userId) {
        return residualService.getResidualPlanUserHistory(userId);
    }

    @PostMapping(value = "/{planId}/users")
    public ResponseEntity insertUser(@PathVariable Long planId,
                                     @RequestBody PlanUser user) {
        residualService.insertUser(planId, user);
        String users = residualService.getResidualPlanUsers(planId);
        return ResponseEntity.ok(users);
    }

    @DeleteMapping(value = "/plan/{id}")
    public void deletePlan(@PathVariable Long id) {
        residualService.deletePlan(id);
    }

    @PostMapping(value = "/plan/{id}/approve")
    public String approvePlan(@PathVariable Long id) {
        residualService.approvePlan(id);
        return getResidualPlanDetails(id);
    }

    @PostMapping(value = "/plan/{planId}/allocation")
    public String insertAllocation(@PathVariable Long planId,
                                @RequestBody ResidualPlanAllocation rpa) {
        return residualService.insertAllocation(planId, rpa);
    }

    @DeleteMapping(value = "/plan/{planId}/allocation/{id}")
    public void removeAllocation(@PathVariable Long planId,
                                @PathVariable Long id) {
        residualService.removeAllocation(planId, id);
    }

    @PutMapping(value = "/plan/{planId}/allocation")
    public void updateAllocation(@PathVariable Long planId,
                                @RequestBody ResidualPlanAllocation rpa) {
        residualService.updateAllocation(planId, rpa);
    }

    @PostMapping(value = "/plan/{id}/clone")
    public ResponseEntity cloneResidualPlan(@PathVariable Long id,
                                            @RequestBody ResidualPlan residualPlan) {
        Optional<Long> clonePlan = residualService.clonePlan(id, residualPlan);
        if (clonePlan.isPresent()) {
            String residualPlanDetail = residualService.getResidualPlanDetails(clonePlan.get());
            return ResponseEntity.ok(residualPlanDetail);
        }
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
}


