package com.albatross.api.v1.company.blueraven.controllers.ahj;

import com.albatross.api.v1.company.blueraven.models.ahj.AhjHoa;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjHoaDetail;
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
    public List<AhjHoa> getAllAhjHoa() {
        return ahjHoaService.getAllAhjHoa();
    }

    @GetMapping(value = "/{id}")
    public Optional<AhjHoaDetail> getHoaById(@PathVariable Long id) {
        return ahjHoaService.getHoaById(id);
    }

    @PostMapping(value = "")
    public Optional<AhjHoaDetail> createHoa(@RequestBody AhjHoa hoa) {
        return ahjHoaService.updateHoa(hoa);
    }

    @PutMapping(value = "/simpleUpdate")
    public Optional<AhjHoaDetail> simpleUpdate(@RequestBody AhjHoa hoa) {
        return ahjHoaService.simpleUpdate(hoa);
    }

    @PutMapping(value = "")
    public Optional<AhjHoaDetail> editHoa(@RequestBody AhjHoa hoa) {
        return ahjHoaService.updateHoa(hoa);
    }


}
