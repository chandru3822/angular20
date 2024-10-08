package com.albatross.api.queue.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.sql.Timestamp;
import java.util.Map;
import java.util.UUID;

@Data
public class Message {

  @JsonIgnore
  private Long id;

  private Long
    attempt,
    createdBy;

  private UUID messageId;

  private String
    topic,
    status;

  private Timestamp dateCreated;

  private Map<String, Object> payload;
}
