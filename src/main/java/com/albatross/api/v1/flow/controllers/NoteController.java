package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.Note;
import com.albatross.api.v1.flow.services.NoteService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/note")
public class NoteController {

  @Autowired
  private NoteService noteService;

  @GetMapping(value = "/getCustomerNotes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getCustomerNotes(@RequestParam Long primaryId) {
    return noteService.getByPrimaryAndType(ObjectType.CUSTOMER.id, primaryId);
  }

  @GetMapping(value = "/getUserNotes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getUserNotes(@RequestParam Long primaryId) {
    return noteService.getByPrimaryAndType(ObjectType.USER.id, primaryId);
  }

  @GetMapping(value = "/getProjectNotes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getProjectNotes(@RequestParam Long primaryId) {
    return noteService.getByPrimaryAndType(ObjectType.PROJECT.id, primaryId);
  }

  @GetMapping(value = "/getProjectProcessStepNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getProjectProcessStepNote(@RequestParam Long primaryId) {
    return noteService.getByPrimaryAndType(ObjectType.PROCESS_STEP.id, primaryId);
  }

  @PostMapping(value = "/saveCustomerNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public Note saveCustomerNote(@RequestBody Note note) {
    return noteService.saveNote(ObjectType.CUSTOMER.id, note);
  }

  @PostMapping(value = "/saveUserNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public Note saveUserNote(@RequestBody Note note) {
    return noteService.saveNote(ObjectType.USER.id, note);
  }


}
