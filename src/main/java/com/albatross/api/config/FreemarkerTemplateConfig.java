package com.albatross.api.config;

import freemarker.template.TemplateExceptionHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Locale;

@Configuration
public class FreemarkerTemplateConfig {

  @Bean(name = "freemarkerConfiguration")
  public freemarker.template.Configuration freemarkerConfiguration() {
    final freemarker.template.Configuration cfg =
        new freemarker.template.Configuration(freemarker.template.Configuration.VERSION_2_3_31);
    cfg.setClassForTemplateLoading(this.getClass(), "/templates/ftl/");
    cfg.setDefaultEncoding("UTF-8");
    cfg.setLocale(Locale.US);
    cfg.setTemplateExceptionHandler(TemplateExceptionHandler.HTML_DEBUG_HANDLER);
    return cfg;
  }
}
