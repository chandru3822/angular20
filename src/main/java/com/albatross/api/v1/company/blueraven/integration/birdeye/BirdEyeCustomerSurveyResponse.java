package com.albatross.api.v1.company.blueraven.integration.birdeye;

import com.albatross.api.convert.JsonObjectDeserializer;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;

import java.util.List;

@Data
public class BirdEyeCustomerSurveyResponse {
  private Long projectId, responseId, surveyId;
  private String surveyName, locationName, customerName, locale;
  private String requestDate, responseDate;
  private boolean completed;
  private List<Answer> answers;

  @Data
  public static class Answer {
    private String title, answer;
    private Integer order;
  }

  public static class Mapper extends BeanPropertyRowMapper<BirdEyeCustomerSurveyResponse> {
    private final ObjectMapper objectMapper;

    public Mapper(ObjectMapper objectMapper) {
      super(BirdEyeCustomerSurveyResponse.class);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Answer>> answerRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class, "answers", new JsonObjectDeserializer<>(answerRef, objectMapper));
    }
  }
}
