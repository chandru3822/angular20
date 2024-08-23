package com.albatross.api.v1.flow.model;

import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class SendTextsRequest {
  @Size(min = 1, message = "Must specify at least one user to send text to")
  List<Long> userIDs;
  @Size(max = 1600, message = "Message must be less than 1600 characters")
  String message = "";
  List<URI> mediaURLs = new ArrayList<>();
}
