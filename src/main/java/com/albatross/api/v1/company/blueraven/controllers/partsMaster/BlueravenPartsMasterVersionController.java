package com.albatross.api.v1.company.blueraven.controllers.partsMaster;

import com.albatross.api.v1.company.blueraven.controllers.partsMaster.models.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;
import java.util.Optional;
import java.util.UUID;


@Slf4j
@Validated
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/partsMaster/versions")
@RequiredArgsConstructor
@PreAuthorize("hasCompanyAccess(3)")
public class BlueravenPartsMasterVersionController {
  private final PartsMasterVersionService partsMasterVersionService;

  @PostMapping
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public ResponseEntity<PartsMasterVersion> createPartsMasterVersion() {
    return ResponseEntity.of(partsMasterVersionService.createPartsMasterVersion());
  }

  @GetMapping
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN', 'PARTS_MASTER_MANAGE')")
  public Page<PartsMasterVersion> getPartsMasterVersions(
    @RequestParam(name = "published", defaultValue = "false") Boolean publishedOnly,
    Pageable pageable) {
    return partsMasterVersionService.getPartsMasterVersions(pageable, publishedOnly);
  }

  @GetMapping(value = "/{id}")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public Optional<PartsMasterVersion> getPartsMasterVersion(@PathVariable Long id) {
    return partsMasterVersionService.getPartsMasterVersion(id);
  }

  @PostMapping(value = "/{id}/publish")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public Optional<PartsMasterVersion> publishPartsMasterVersion(@PathVariable Long id, @Valid @RequestBody PartsMasterPublishRequest request) {
    return partsMasterVersionService.publishPartsMasterVersion(id, request.message());
  }

  @GetMapping(value="/{id}/history")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public PartsMasterVersionHistoryChangeSet getPartsMasterVersionHistory(@PathVariable Long id){
    return partsMasterVersionService.getChangeHistory(id);
  }

  public record PartsMasterPublishRequest(@NotEmpty String message) {
  }

  @GetMapping(value = "/{id}/values/{objectCode}")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public List<PartsMasterCustomValuesRow> getPartsMasterCustomFieldsByObjectCode(
    @PathVariable Long id, @PathVariable String objectCode) {
    return partsMasterVersionService.getPartsMasterCustomFieldValues(id, objectCode);
  }

  @PostMapping(value = "/{id}/values/{objectCode}")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public Optional<PartsMasterCustomValuesRow> updatePartsMasterCustomFieldsByObjectCode(
    @PathVariable Long id,
    @PathVariable String objectCode,
    @Valid @RequestBody final PartsMasterCustomGroup group) {
    return partsMasterVersionService.updateCustomFieldValue(id, objectCode, group);
  }

  @PostMapping(value = "/{id}/values/{objectCode}/reset")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public List<PartsMasterCustomValuesRow> undoChangesToPartsMasterObject(
    @PathVariable Long id, @PathVariable String objectCode) {
    return partsMasterVersionService.resetPartsMasterVersionByCustomFieldByObjectCode(id, objectCode);
  }

  @DeleteMapping(value = "/{id}/values/{objectCode}/{groupUUID}")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public ResponseEntity<?> deleteCustomFieldGroup(
    @PathVariable Long id, @PathVariable String objectCode, @PathVariable UUID groupUUID) {
    Optional<PartsMasterCustomValuesRow> partsMasterCustomValuesRow = partsMasterVersionService.deleteCustomFieldGroup(id, objectCode, groupUUID);
    if (partsMasterCustomValuesRow.isPresent()) {
      return ResponseEntity.of(partsMasterCustomValuesRow);
    }
    return ResponseEntity.noContent().build();

  }
  @PostMapping(value = "/{id}/values/{objectCode}/{groupUUID}/archive")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public Optional<PartsMasterCustomValuesRow> archiveCustomFieldGroup(
    @PathVariable Long id, @PathVariable String objectCode, @PathVariable UUID groupUUID) {
    return partsMasterVersionService.archiveCustomFieldGroup(id, objectCode, groupUUID);
  }

  @GetMapping(value = "/types")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public List<PartsMasterObjectType> getPartsMasterObjectTypes() {
    return partsMasterVersionService.getPartsMasterTypes();
  }

  @GetMapping(value = "/fields/{objectCode}")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public List<PartsMasterFieldObjectType> getPartsMasterCustomFieldsByObjectCode(
    @PathVariable String objectCode) {
    return partsMasterVersionService.getPartsMasterFieldsByObjectCode(objectCode);
  }
}
