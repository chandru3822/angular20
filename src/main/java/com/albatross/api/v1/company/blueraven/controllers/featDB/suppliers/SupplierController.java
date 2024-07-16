package com.albatross.api.v1.company.blueraven.controllers.featDB.suppliers;

import com.albatross.api.v1.company.blueraven.models.featDB.*;
import com.albatross.api.v1.company.blueraven.services.featDB.SupplierService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PostAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@Hidden
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/featDb/supplier")
public class SupplierController {

  private final SupplierService supplierService;

  @GetMapping(value = "/list/all")
  public List<Supplier> getAllSupplier() {
    return supplierService.getAllSuppliers();
  }

  @PostAuthorize("returnObject.get().getArchived() == true && hasFeatureAccessLevel('SUPPLIER_ADMIN') || returnObject.get().getArchived() == false")
  @GetMapping(value = "/{id}")
  public Optional<SupplierDetail> getSupplierById(@PathVariable Long id) {
    return supplierService.getSupplierById(id);
  }

  @PostMapping(value = "")
  public Optional<SupplierDetail> createSupplier(@RequestBody Supplier supplier) {
    return supplierService.updateSupplier(supplier);
  }

  @PutMapping(value = "/simpleUpdate")
  public Optional<SupplierDetail> simpleUpdate(@RequestBody Supplier supplier) {
    return supplierService.simpleUpdate(supplier);
  }

  @PutMapping(value = "")
  public Optional<SupplierDetail> editSupplier(@RequestBody Supplier supplier) {
    return supplierService.updateSupplier(supplier);
  }

  @DeleteMapping(value="/{id}/archive")
  public void deleteSupplier(@PathVariable Long id) {
      supplierService.deleteSupplier(id);
  }

  @PostMapping(value = "/{id}/restore")
  public Optional<SupplierDetail> restoreAhj(@PathVariable Long id) {
    return supplierService.restoreSupplier(id);
  }
  // CONTACTS
  @PostMapping(value = "/{supplierId}/contacts")
  public Optional<FeatDbContact> addSupplierContact(@PathVariable Long supplierId,
                                                   @RequestBody FeatDbContact utilityContact) {
    return supplierService.saveSupplierContact(supplierId, null, utilityContact);
  }

  @PutMapping(value = "/{supplierId}/contacts/{contactId}")
  public Optional<FeatDbContact> updateSupplierContact(@PathVariable Long supplierId,
                                                      @PathVariable Long contactId,
                                                      @RequestBody FeatDbContact utilityContact) {
    return supplierService.saveSupplierContact(supplierId, contactId, utilityContact);
  }

  @PutMapping(value = "/contacts/{contactId}/archive")
  public void deleteSupplierContact(@PathVariable Long contactId) {
    supplierService.deleteSupplierContact(contactId);
  }

  // LINKS
  @PostMapping(value = "/{supplierId}/links")
  public Optional<FeatDbLink> addSupplierLink(@PathVariable Long supplierId,
                                             @RequestBody FeatDbLink link) {
    return supplierService.saveSupplierLink(supplierId, null, link);
  }

  @PutMapping(value = "/{supplierId}/links/{linkId}")
  public Optional<FeatDbLink> updateSupplierLink(@PathVariable Long supplierId,
                                                @PathVariable Long linkId,
                                                @RequestBody FeatDbLink link) {
    return supplierService.saveSupplierLink(supplierId, linkId, link);
  }

  @PutMapping(value = "/links/{linkId}/archive")
  public void deleteSupplierLink(@PathVariable Long linkId) {
    supplierService.deleteSupplierLink(linkId);
  }

  @GetMapping(value="/{supplierId}/getSupplierHistory")
  public List<DatabaseHistory> getSupplierHistory(@PathVariable Long supplierId) {
    return supplierService.getSupplierHistory(supplierId);
  }
}
