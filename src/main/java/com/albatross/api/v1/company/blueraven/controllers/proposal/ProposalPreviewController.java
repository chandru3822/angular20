package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.exception.ApiException;
import freemarker.template.TemplateException;
import io.micrometer.core.annotation.Timed;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/proposal-preview")
@RequiredArgsConstructor
public class ProposalPreviewController {
  private final ProposalTemplateService proposalTemplateService;

  @Timed
  @PostMapping(value = "/{templateId}", produces = MediaType.APPLICATION_PDF_VALUE)
  public ResponseEntity<StreamingResponseBody> getProposalPreview(
    @PathVariable Long templateId,
      @RequestParam(value = "inline", defaultValue = "false") boolean inline,
      final HttpServletResponse response) {

    final String contentDisposition =
        String.format("%s; filename=\"preview.pdf\"", inline ? "inline" : "attachment");

    response.addHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_PDF_VALUE);
    response.addHeader(HttpHeaders.CONTENT_DISPOSITION, contentDisposition);

    final StreamingResponseBody responseBody =
        outputStream -> {
          try {
            final var pdf = proposalTemplateService.generatePdf(templateId, new HashMap<>(), true);
            response.addHeader(HttpHeaders.CONTENT_LENGTH, pdf.getContentLength().toString());
            IOUtils.copy(pdf.getInputStream(), outputStream);
          } catch (TemplateException e) {
            log.error("[Proposal] Error generating preview PDF", e);
            throw new ApiException("Error generating preview");
          }
        };
    return ResponseEntity.ok(responseBody);
  }
}
