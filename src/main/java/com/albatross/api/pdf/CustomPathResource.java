package com.albatross.api.pdf;

import org.springframework.core.io.PathResource;

import java.nio.file.Path;

public class CustomPathResource extends PathResource {
  private final Path path;
  private final String fileName;

  public CustomPathResource(Path path, String fileName) {
    super(path);
    this.path = path;
    this.fileName = fileName;
  }

  @Override
  public String getFilename() {
    return this.fileName;
  }
}
