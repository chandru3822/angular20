package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.services.MessageTypeService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;


@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/messageType")
@RequiredArgsConstructor
public class MessageTypeController {

  private final MessageTypeService messageTypeService;

  @GetMapping(value = "")
  public List<MessageType> getMessageTypes() {
    return messageTypeService.getMessageTypes();
  }

  @PostMapping(value = "")
  public Optional<MessageType> saveMessageTypes(@RequestBody MessageType mt) {
    return messageTypeService.saveMessageType(mt);
  }

  @DeleteMapping(value = "/{id}")
  public void deleteMessageTypes(@PathVariable Long id) {
    messageTypeService.deleteMessageType(id);
  }

  @Data
  public static class MessageType {
    private Long id;
    private String title, content, description;
    private Boolean archived, includeManager;
  }
}
