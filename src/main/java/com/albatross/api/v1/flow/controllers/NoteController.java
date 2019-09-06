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

  @RequestMapping(value = "/getCustomerNotes", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getCustomerNotes(@RequestParam Long primaryId) {
    return noteService.getByPrimaryAndType(ObjectType.CUSTOMER.id, primaryId);
  }

  @RequestMapping(value = "/getProjectNotes", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getProjectNotes(@RequestParam Long primaryId) {
    return noteService.getByPrimaryAndType(ObjectType.PROJECT.id, primaryId);
  }

  @RequestMapping(value = "/getProjectProcessStepNote", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getProjectProcessStepNote(@RequestParam Long primaryId) {
    return noteService.getByPrimaryAndType(ObjectType.PROCESS_STEP.id, primaryId);
  }

  @RequestMapping(value = "/saveCustomerNote", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public Note saveNote(@RequestBody Note note) {
    return noteService.saveNote(ObjectType.CUSTOMER.id, note);
  }


}
