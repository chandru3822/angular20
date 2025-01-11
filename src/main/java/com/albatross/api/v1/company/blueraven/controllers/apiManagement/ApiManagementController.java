package com.albatross.api.v1.company.blueraven.controllers.apiManagement;

import com.albatross.api.v1.company.blueraven.controllers.apiManagement.models.Key;
import com.albatross.api.v1.company.blueraven.controllers.apiManagement.models.Partner;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/company/blueraven/apiManagement", produces = MediaType.APPLICATION_JSON_VALUE)
@PreAuthorize("hasRootLevelAccess() || hasFeatureAccessLevel('API_MANAGEMENT_ADMIN')")
@RequiredArgsConstructor
public class ApiManagementController {

    private final ApiManagementService apiService;

    @GetMapping("/partner")
    public ResponseEntity<List<Partner>> getPartners() {
        return new ResponseEntity<>(apiService.getPartners(), HttpStatus.OK);
    }

    @PostMapping("/partner")
    public ResponseEntity<Partner> addPartner(@RequestBody Partner partner) {
        return new ResponseEntity<>(apiService.addPartner(partner), HttpStatus.OK);
    }

    @PostMapping("/partner/{partnerId}")
    public ResponseEntity<Void> updatePartner(@RequestBody Partner partner) {
        apiService.updatePartner(partner);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @PostMapping("/partner/{partnerId}/key")
    public ResponseEntity<Key> addKey(@RequestBody Key key) {
        key.setIsAdmin(false);
        return new ResponseEntity<>(apiService.addKey(key), HttpStatus.OK);
    }

    @PostMapping("/partner/{partnerId}/key/{keyId}")
    public ResponseEntity<Void> updateKey(@RequestBody Key key) {
        apiService.updateKey(key);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/partner/{partnerId}/key/{keyId}")
    public ResponseEntity<Void> deleteKey(@PathVariable Long keyId) {
      apiService.deleteKey(keyId);
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
