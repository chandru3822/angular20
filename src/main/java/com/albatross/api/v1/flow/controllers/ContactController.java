package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.CompanyProcess;
import com.albatross.api.v1.flow.model.Project;
import com.albatross.api.v1.flow.services.ContactService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/contact")
public class ContactController {

    private final ContactService contactService;

    @Value("${app.home_url}")
    private String homeUrl;

    @GetMapping(value="/search", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Page<Contact>> searchContacts(@RequestParam String query, Pageable pageable) {
        return new ResponseEntity<>(contactService.searchContacts(query, pageable), HttpStatus.OK);
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
        return contactService.convertToContact(contactId, process);
    }

    @GetMapping(value = "/phone/{phoneNumber}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> getContactByPhone(@PathVariable String phoneNumber) {
        Contact contact = contactService.getContactByPhone(phoneNumber);
        if (contact != null) {
            String URL = homeUrl + "/contact/" + contact.getId();
            return new ResponseEntity<>(URL, HttpStatus.OK);
        }
        else {
            return ResponseEntity.badRequest().body("No contact found");
        }
    }
}
