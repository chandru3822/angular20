package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.InteractionTimer;
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

  @GetMapping(value = "/getProjectProcessStepWorkQueueNotes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Note> getProjectProcessStepWorkQueueNotes(@RequestParam Long projectProcessStepId,
                                                        @RequestParam Long processStepWorkQueueTypeId) {
    return noteService.getProjectProcessStepWorkQueueNotes(projectProcessStepId, processStepWorkQueueTypeId);
  }

  @PostMapping(value = "/saveProjectProcessStepWorkQueueNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Note> saveProjectProcessStepWorkQueueNote(@RequestBody Note note) {
    return new ResponseEntity<>(noteService.saveNote(null, note, true, false,false), HttpStatus.OK);
  }

  @PostMapping(value = "/saveProjectProcessStepEventWorkQueueNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Note> saveProjectProcessStepEventWorkQueueNote(@RequestBody Note note) {
    return new ResponseEntity<>(noteService.saveNote(null, note, false, true, false), HttpStatus.OK);
  }

  @PostMapping(value = "/saveProjectProdStatsNote", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Note> saveProjectProdStatsNote(@RequestBody Note note) {
    return new ResponseEntity<>(noteService.saveNote(null, note, false, false,true), HttpStatus.OK);
  }

  @PostMapping(value = "/saveProjectNoteTimer", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveProjectNoteTimer(@RequestBody InteractionTimer noteTimer) {
    noteService.saveNoteTimer(noteTimer);
  }

  @DeleteMapping(value = "/processStepWorkQueue/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deletePsWqNote(@PathVariable Long id) {
    noteService.deleteNote(id, "project_process_step_process_step_work_queue_type_note");
  }

  @DeleteMapping(value = "/eventWorkQueue/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteEventWqNote(@PathVariable Long id) {
    noteService.deleteNote(id, "pps_event_process_step_event_work_queue_type_note");
  }

  @DeleteMapping(value = "/prodStat/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteProdStatNote(@PathVariable Long id) {
    noteService.deleteNote(id, "project_prod_stats_note");
  }
}
