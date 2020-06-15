package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.services.WellsFargoService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/api/v1/wellsfargo")
@RequiredArgsConstructor
public class WellsFargoController {

    @Autowired
    private WellsFargoService wellsFargoService;

    @GetMapping(value="/")
    public String renderFile() throws Exception {
      return wellsFargoService.renderFile();
    }


    @PreAuthorize("hasAnyAuthority('SYSTEM_ADMIN')")
    @PostMapping(value = "/setCheckNumber/{checkNumber}")
    public void setCheckNumber(@PathVariable int checkNumber) {
        wellsFargoService.setCheckNumber(checkNumber);
    }

    @PreAuthorize("hasAnyAuthority('SYSTEM_ADMIN')")
    @GetMapping(value = "/getCheckNumberWithoutIncrement")
    public String getCheckNumberWithoutIncrement() {
        return wellsFargoService.getCheckNumberWithoutIncrement();
    }
}
