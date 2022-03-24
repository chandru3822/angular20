package com.albatross.api.v1.flow.services;

import freemarker.cache.StringTemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.Template;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.Map;

@Slf4j
@Service
public class TemplatingEngineService {

  public void applyFreemarkerTemplate(
      String templateContent, Map<String, Object> contextMap, OutputStream output)
      throws Exception {
    Configuration config = new Configuration(Configuration.VERSION_2_3_25);
    StringTemplateLoader stringLoader = new StringTemplateLoader();
    stringLoader.putTemplate("template", templateContent);
    config.setTemplateLoader(stringLoader);

    Template template = config.getTemplate("template");
    template.process(contextMap, new OutputStreamWriter(output));
  }

  public String renderFreemarkerTemplate(String templateContent, Map<String, Object> context)
      throws Exception {
    try (ByteArrayOutputStream output = new ByteArrayOutputStream()) {
      applyFreemarkerTemplate(templateContent, context, output);

      return output.toString();
    } catch (Exception ex) {
      log.error("TEMPLATE_ERROR: unable to create output stream", ex);
    }

    return "fail fail fail";
  }
}
