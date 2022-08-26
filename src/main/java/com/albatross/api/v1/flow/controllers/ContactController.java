package com.albatross.api.v1.flow.controllers;


import com.albatross.api.exception.NotFoundException;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.CompanyProcess;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.services.ContactService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/contact", produces = MediaType.APPLICATION_JSON_VALUE)
public class ContactController {

    private final ContactService contactService;

    @GetMapping(value="/search")
    public ResponseEntity<Page<Contact>> searchContacts(@RequestParam String query,
                                                        @RequestParam(required = false) String overrideType,
                                                        Pageable pageable) {
        return new ResponseEntity<>(contactService.searchContacts(query, overrideType, pageable), HttpStatus.OK);
    }

    @GetMapping(value = "/{contactId}")
    public ResponseEntity<Contact> getContact(@PathVariable Long contactId) {
      Contact newContact = contactService.getContact(contactId);
      if (newContact != null) {
        return new ResponseEntity<>(newContact, HttpStatus.OK);
      }
      else {
        throw new NotFoundException("FAIL_TO_NOT_FOUND_SCREEN");
      }
    }

    @PostMapping(value = "")
    public Contact updateContact(@RequestBody Contact contact) throws Exception {
        return contactService.updateContact(contact);
    }

    //temporary
    @PostMapping(value = "/updateLatLong")
    public void updateContactLatLong(@RequestParam(required = false) Integer limit) throws Exception {
      contactService.updateContactLatLong(limit);
    }


  @DeleteMapping(value = "/{id}")
    public void deleteContact(@PathVariable Long id) {
        contactService.deleteContact(id);
    }

    @PutMapping(value = "/{contactId}/updateOwner")
    public void updateOwner(@PathVariable Long contactId,
                            @RequestBody Owner owner) {
        contactService.updateOwner(contactId, owner);
    }

  @PutMapping(value = "/updateMailingAddress")
  public void updateMailingAddress(@RequestBody Contact contact) {
    contactService.updateMailingAddress(contact);
  }

    @GetMapping(value = "/{contactId}/project")
    public ResponseEntity<Project> getContactProjects(@PathVariable Long contactId) {
        return new ResponseEntity<>(new Project(), HttpStatus.OK);
    }

    @GetMapping(value = "/project/{projectId}")
    public ResponseEntity<Contact> getContactByProjectId(@PathVariable Long projectId) {
      return new ResponseEntity<>(contactService.getContactByProjectId(projectId), HttpStatus.OK);
    }

    @GetMapping(value = "/owners")
    public List<Owner> getOwners(@RequestParam(required = false) Long contactId) {
      return contactService.getOwnersForContact(contactId);
    }

    @PutMapping(value = "/{contactId}/convert")
    public Project convertToContact(@PathVariable Long contactId,
                                  @RequestBody CompanyProcess process) {
        // need to return the project so the frontend can navigate to /project/{id}
        try {
          return contactService.convertToContact(contactId, process);
        } catch (Exception e) {
          throw new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
        }
    }

  @GetMapping(value = "/{contactId}/attachments")
  public ResponseEntity<List<Attachment>> getContactAttachments(@PathVariable Long contactId,
                                                                @RequestParam(required = false) Boolean isMobile,
                                                                @RequestParam(required = false) Boolean linked) {
    return new ResponseEntity<>(contactService.getContactAttachments(contactId, isMobile, linked), HttpStatus.OK);
  }

  @PostMapping(value = "/{contactId}/linkAttachment/{attachmentId}")
  public void linkAttachment(@PathVariable Long contactId,
                             @PathVariable Long attachmentId,
                             @RequestParam Boolean doLink) {
    contactService.linkAttachment(contactId, attachmentId, doLink);
  }

  @PostMapping(value = "/{contactId}/attachment")
  public ResponseEntity<Attachment> uploadContactAttachment(@PathVariable Long contactId,
                                                            @RequestParam Long attachmentTypeId,
                                                            @RequestParam String displayName,
                                                            @RequestParam("file") MultipartFile file) throws IOException {
    return new ResponseEntity<>(contactService.addAttachment(file, contactId, attachmentTypeId, displayName), HttpStatus.OK);
  }
}
