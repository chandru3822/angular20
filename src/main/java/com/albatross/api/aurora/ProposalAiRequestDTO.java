package com.albatross.api.aurora;

import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

@Data
public class ProposalAiRequestDTO {
    @JsonProperty("customFieldValuesList")
    private List<CustomFieldValue> customFieldValuesList;

    @JsonProperty("monthlyInputs")
    private List<Double> monthlyInputs;

}
