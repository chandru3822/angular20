package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.Note;
import com.albatross.api.v1.flow.services.NoteService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
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

  @GetMapping(value = "/getContactNotes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getContactNotes(@RequestParam Long primaryId) {
    return noteService.getByPrimaryAndType(ObjectType.CONTACT.id, primaryId);
  }

  @GetMapping(value = "/getUserNotes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getUserNotes(@RequestParam Long primaryId) {
    return noteService.getByPrimaryAndType(ObjectType.USER.id, primaryId);
  }

  @GetMapping(value = "/getProjectNotes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getProjectNotes(@RequestParam Long primaryId) {
    return noteService.getByPrimaryAndType(ObjectType.PROJECT.id, primaryId);
  }

  @GetMapping(value = "/getProjectProcessStepNotes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getProjectProcessStepNotes(@RequestParam Long primaryId) {
    return noteService.getByPrimaryAndType(ObjectType.PROCESS_STEP.id, primaryId);
  }

  @GetMapping(value = "/getProjectProcessStepWorkQueueNotes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getProjectProcessStepWorkQueueNotes(@RequestParam Long projectProcessStepId,
                                                        @RequestParam Long processStepWorkQueueTypeId) {
    return noteService.getProjectProcessStepWorkQueueNotes(projectProcessStepId, processStepWorkQueueTypeId);
  }

  @PostMapping(value = "/saveContactNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public Note saveContactNote(@RequestBody Note note) {
    return noteService.saveNote(ObjectType.CONTACT.id, note);
  }

  @PostMapping(value = "/saveUserNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public Note saveUserNote(@RequestBody Note note) {
    return noteService.saveNote(ObjectType.USER.id, note);
  }

  @PostMapping(value = "/saveProjectNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Note> saveProjectNote(@RequestBody Note note) {
    return new ResponseEntity<>(noteService.saveNote(ObjectType.PROJECT.id, note), HttpStatus.OK);
  }

  @PostMapping(value = "/saveProjectProcessStepNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Note> saveProjectProcessStepNote(@RequestBody Note note) {
    return new ResponseEntity<>(noteService.saveNote(ObjectType.PROCESS_STEP.id, note), HttpStatus.OK);
  }

  @PostMapping(value = "/saveProjectProcessStepWorkQueueNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Note> saveProjectProcessStepWorkQueueNote(@RequestBody Note note) {
    return new ResponseEntity<>(noteService.saveNote(null, note, true, false), HttpStatus.OK);
  }

  @PostMapping(value = "/saveProjectProdStatsNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Note> saveProjectProdStatsNote(@RequestBody Note note) {
    return new ResponseEntity<>(noteService.saveNote(null, note, false, true), HttpStatus.OK);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteNote(@PathVariable Long id) {
    noteService.deleteNote(id);
  }
}
