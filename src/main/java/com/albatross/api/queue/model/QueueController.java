package com.albatross.api.queue.model;


import com.albatross.api.queue.QueueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * todo: Potentially temporary (using for testing, restricted to admins), for message queue manipulation via endpoint
 */

@RestController
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasRootLevelAccess()")
@RequestMapping(value = "/api/v1/flow/queue", produces = MediaType.APPLICATION_JSON_VALUE)
public class QueueController {

  private final QueueService queueService;

  @PostMapping(value = "/enqueue")
  public ResponseEntity<Message> enqueueMessage(@RequestBody Message message) {
    return new ResponseEntity<>(queueService.Enqueue(message), HttpStatus.OK);
  }

  @GetMapping(value = "/dequeue")
  public ResponseEntity<Message> dequeueMessage(@RequestBody Message m) {
    var message = queueService.Dequeue(m.getTopic());
    return message.map(val -> new ResponseEntity<>(val, HttpStatus.OK))
                  .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
  }
}
