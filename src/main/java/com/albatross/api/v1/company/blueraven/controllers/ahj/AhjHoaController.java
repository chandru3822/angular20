package com.albatross.api.v1.company.blueraven.controllers.ahj;

import com.albatross.api.v1.company.blueraven.models.ahj.AhjUtility;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjUtilityDetail;
import com.albatross.api.v1.company.blueraven.services.ahj.AhjHoaService;
import io.swagger.v3.oas.annotations.Hidden;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/ahjHoa")
public class AhjHoaController {
    @Autowired
    private AhjHoaService ahjHoaService;

    @GetMapping(value = "/list/all")
    public List<AhjUtility> getAllAhjUtilities() {
        return ahjHoaService.getAllAhjUtilities();
    }

    @GetMapping(value = "/{id}")
    public Optional<AhjUtilityDetail> getUtilityById(@PathVariable Long id) {
        return ahjHoaService.getUtilityById(id);
    }

    @PostMapping(value = "")
    public Optional<AhjUtilityDetail> createUtility(@RequestBody AhjUtility utility) {
        return ahjHoaService.updateUtility(utility);
    }

    @PutMapping(value = "/simpleUpdate")
    public Optional<AhjUtilityDetail> simpleUpdate(@RequestBody AhjUtility utility) {
        return ahjHoaService.simpleUpdate(utility);
    }

    @PutMapping(value = "")
    public Optional<AhjUtilityDetail> editUtility(@RequestBody AhjUtility utility) {
        return ahjHoaService.updateUtility(utility);
    }


}
