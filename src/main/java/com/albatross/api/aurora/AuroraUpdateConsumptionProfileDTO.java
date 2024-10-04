package com.albatross.api.aurora;

import com.fasterxml.jackson.annotation.*;
import lombok.Data;

import java.util.List;

@Data
@JsonInclude(JsonInclude.Include.NON_ABSENT)
@JsonTypeInfo(include = JsonTypeInfo.As.WRAPPER_OBJECT, use = JsonTypeInfo.Id.NAME)
@JsonTypeName("consumption_profile")
public class AuroraUpdateConsumptionProfileDTO {

    //An array of the monthly energy in kWh. Null values allowed as "null".
    @JsonProperty("monthly_energy")
    private List<Double> monthlyEnergy;
}
