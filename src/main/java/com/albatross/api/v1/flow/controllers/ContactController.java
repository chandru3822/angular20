package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.ContactService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
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
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/contact")
public class ContactController {

    private final ContactService contactService;

    @GetMapping(value="/search", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Page<Contact>> searchContacts(@RequestParam String query,
                                                        @RequestParam(required = false) String overrideType,
                                                        Pageable pageable) {
        return new ResponseEntity<>(contactService.searchContacts(query, overrideType, pageable), HttpStatus.OK);
    }

    @GetMapping(value = "/{contactId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Contact> getContact(@PathVariable Long contactId) {
      Contact newContact = contactService.getContact(contactId);
      if (newContact != null) {
        return new ResponseEntity<>(newContact, HttpStatus.OK);
      }
      else {
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Contact Not Found", new Exception());
      }
    }

    @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
    public Contact updateContact(@RequestBody Contact contact) {
        return contactService.updateContact(contact);
    }

    @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public void deleteContact(@PathVariable Long id) {
        contactService.deleteContact(id);
    }

    @PutMapping(value = "/{contactId}/updateOwner", produces = MediaType.APPLICATION_JSON_VALUE)
    public void updateOwner(@PathVariable Long contactId,
                            @RequestBody Owner owner) {
        contactService.updateOwner(contactId, owner);
    }

  @PutMapping(value = "/updateMailingAddress", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateMailingAddress(@RequestBody Contact contact) {
    contactService.updateMailingAddress(contact);
  }

    @GetMapping(value = "/{contactId}/project", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Project> getContactProjects(@PathVariable Long contactId) {
        return new ResponseEntity<>(new Project(), HttpStatus.OK);
    }

    @GetMapping(value = "/project/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Contact> getContactByProjectId(@PathVariable Long projectId) {
      return new ResponseEntity<>(contactService.getContactByProjectId(projectId), HttpStatus.OK);
    }

    @GetMapping(value = "/owners", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<Owner> getOwners(@RequestParam(required = false) Long contactId) {
      return contactService.getOwnersForContact(contactId);
    }

    @PutMapping(value = "/{contactId}/convert", produces = MediaType.APPLICATION_JSON_VALUE)
    public Project convertToContact(@PathVariable Long contactId,
                                  @RequestBody CompanyProcess process) {
        // need to return the project so the frontend can navigate to /project/{id}
        try {
          return contactService.convertToContact(contactId, process);
        } catch (Exception e) {
          throw new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
        }
    }

  @GetMapping(value = "/{contactId}/attachments", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Attachment>> getContactAttachments(@PathVariable Long contactId,
                                                                @PathVariable(required = false) Boolean isMobile) {
    return new ResponseEntity<>(contactService.getContactAttachments(contactId, isMobile), HttpStatus.OK);
  }

  @PostMapping(value = "/{contactId}/attachment", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Attachment> uploadContactAttachment(@PathVariable Long contactId,
                                                            @RequestParam Long attachmentTypeId,
                                                             @RequestParam("file") MultipartFile file) throws IOException {
    return new ResponseEntity<>(contactService.addAttachment(file, contactId, attachmentTypeId), HttpStatus.OK);
  }
}
