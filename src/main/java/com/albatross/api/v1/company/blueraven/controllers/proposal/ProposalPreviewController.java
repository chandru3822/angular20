package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplateBlock;
import com.google.common.net.HttpHeaders;
import freemarker.template.TemplateException;
import io.micrometer.core.annotation.Timed;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/proposal-preview")
@RequiredArgsConstructor
public class ProposalPreviewController {
  private final ProposalTemplateService proposalTemplateService;

  @Timed
  @PostMapping(value = "", produces = MediaType.APPLICATION_PDF_VALUE)
  public void getProposalPreview(
      @RequestBody PreviewPayload payload,
      @RequestParam(value = "inline", defaultValue = "false") boolean inline,
      HttpServletResponse response)
      throws IOException, TemplateException {

    response.addHeader(
        HttpHeaders.CONTENT_DISPOSITION,
        String.format("%s; filename=\"preview.pdf\"", inline ? "inline" : "attachment"));

    proposalTemplateService.generatePdf(
        payload.template, payload.theme, response.getOutputStream());
  }

  public record PreviewPayload(List<ProposalTemplateBlock> template, Map<String, Object> theme) {}
}
