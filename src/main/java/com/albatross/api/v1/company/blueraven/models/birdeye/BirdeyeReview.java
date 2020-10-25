package com.albatross.api.v1.company.blueraven.models.birdeye;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Map;

@Data
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class BirdeyeReview {
    private static DateTimeFormatter reviewDateFormat = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    private static DateTimeFormatter responseDateFormat = DateTimeFormatter.ofPattern("MMM dd, yyyy hh:mm a");

    @JsonProperty("businessId")
    private String birdeyeBusinessId;

    @JsonProperty("reviewId")
    private String birdeyeReviewId;

    private String birdeyeCustomerId;
    private LocalDate reviewDate;
    private LocalDate brsResponseDate;
    private BigDecimal reviewScore;

    @JsonProperty("comments")
    private String reviewText;

    @JsonProperty("reviewer")
    private void unpackReviewerInfo(Map<String, String> reviewer) {
        birdeyeCustomerId = reviewer.get("customerId");
    }

    @JsonProperty("reviewDate")
    private void parseReviewDate(String s) {
        reviewDate = LocalDate.parse(s, reviewDateFormat);
    }

    @JsonProperty("responseDate")
    private void parseRespondedDate(String s) {
        if (s == null)
            brsResponseDate = null;
        else
            brsResponseDate = LocalDate.parse(s, responseDateFormat);
    }

    @JsonProperty("rating")
    private void parseReviewScore(String s) {
        reviewScore = new BigDecimal(s);
    }
}
