package com.albatross.api.aurora;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

@Data
public class AuroraConsumptionProfile {

    //An array of the monthly bills in USD. Null values allowed as "null".
    @JsonProperty("monthly_bill")
    private List<Double> monthlyBill;

    //An array of the monthly energy in kWh. Null values allowed as "null".
    @JsonProperty("monthly_energy")
    private List<Double> monthlyEnergy;
}
