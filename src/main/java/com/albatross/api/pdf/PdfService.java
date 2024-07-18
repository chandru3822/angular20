package com.albatross.api.pdf;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.PathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.Instant;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class PdfService {

  private final WebClient pdfWebClient;

  public Resource convert(String fileContent) {

    Path path = null;
    try {
      log.debug("Creating temp file with provided contents");
      path = Files.writeString(Files.createTempFile("index.", ".html"), fileContent);

      // api endpoint is expecting a file named "index.html" as the "root"
      PathResource resource = new CustomPathResource(path, "index.html");
      log.debug("Starting convert HTML to PDF");
      Instant startTime = Instant.now();
      Resource htmlToPdf = convertHtmlToPdf(List.of(resource));
      Duration duration = Duration.between(startTime, Instant.now());
      log.debug("Generated PDF in {}", duration);
      return htmlToPdf;
    } catch (IOException e) {
      throw new RuntimeException(e);
    } finally {
      try {
        if (path != null && Files.exists(path)) {
          Files.delete(path);
        }
      } catch (IOException e) {
        log.warn("Unable to remove temp file");
      }
    }
  }


  private Resource convertHtmlToPdf(List<Resource> resources) {

    MultipartBodyBuilder builder = new MultipartBodyBuilder();
    for (Resource resource : resources) {
      builder.part("files", resource);
    }

   return pdfWebClient
      .post()
      .uri("/forms/chromium/convert/html")
      .contentType(MediaType.APPLICATION_FORM_URLENCODED)
      .accept(MediaType.APPLICATION_PDF)
      .body(BodyInserters.fromMultipartData(builder.build()))
      .retrieve()
      .bodyToMono(Resource.class)
      .doOnError((e) -> log.error("[PDF] Error processing PDF, error={}", e.getMessage()))
      .block();
  }
}
