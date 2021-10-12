package com.albatross.api.v1.flow.services;

public record EmailMessage(
  String to,
  String from,
  String fromDisplayName,
  String subject,
  String content,
  Long sentByUserId) {
}
