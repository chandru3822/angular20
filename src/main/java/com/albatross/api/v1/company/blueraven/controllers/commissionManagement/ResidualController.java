package com.albatross.api.v1.company.blueraven.controllers.commissionManagement;

import com.albatross.api.v1.company.blueraven.models.commissionManagement.Residual;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.ResidualService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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


}


