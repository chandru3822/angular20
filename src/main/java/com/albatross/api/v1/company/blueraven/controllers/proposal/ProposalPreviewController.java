package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.exception.ApiException;
import io.micrometer.core.annotation.Timed;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import jakarta.servlet.http.HttpServletResponse;
import java.util.HashMap;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/proposal-preview")
@PreAuthorize("hasCompanyAccess(3) && hasFeatureAccess('PROPOSALS')")
@RequiredArgsConstructor
public class ProposalPreviewController {
  private final ProposalTemplateService proposalTemplateService;

  @Timed
  @PostMapping(value = "/{templateId}", produces = MediaType.APPLICATION_PDF_VALUE)
  public ResponseEntity<StreamingResponseBody> getProposalPreview(
    @PathVariable Long templateId,
    @RequestParam(defaultValue = "false") boolean inline,
    final HttpServletResponse response) {

    final String contentDisposition =
      "%s; filename=\"preview.pdf\"".formatted(inline ? "inline" : "attachment");

    response.addHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_PDF_VALUE);
    response.addHeader(HttpHeaders.CONTENT_DISPOSITION, contentDisposition);

    final StreamingResponseBody responseBody =
      outputStream -> {
        try {
          final var pdf = proposalTemplateService.generatePdf(templateId, new HashMap<>(), true);
          response.addHeader(HttpHeaders.CONTENT_LENGTH, String.valueOf(pdf.contentLength()));
          IOUtils.copy(pdf.getInputStream(), outputStream);
        } catch (Exception e) {
          log.error("[Proposal] Error generating preview PDF", e);
          throw new ApiException("Error generating preview");
        }
      };
    return ResponseEntity.ok(responseBody);
  }
}
