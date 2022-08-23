package com.albatross.api.v1.company.blueraven.controllers.proposal;

import lombok.Getter;
import lombok.Setter;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

@Getter
@Setter
public class ContentAwareByteArrayOutputStream extends ByteArrayOutputStream {
  private Long contentLength;
  private String contentType;

  public ContentAwareByteArrayOutputStream() {
  }

  public ByteArrayInputStream getInputStream() {
    final ByteArrayInputStream inputStream = new ByteArrayInputStream(this.buf, 0, this.count);
    // don't allow it to be altered
    this.buf = null;
    return inputStream;
  }
}
