package com.albatross.api.aurora;

import com.fasterxml.jackson.annotation.*;
import lombok.Data;

import java.util.List;


@Data
@JsonTypeInfo(include = JsonTypeInfo.As.WRAPPER_OBJECT, use = JsonTypeInfo.Id.NAME)
@JsonTypeName("consumption_profile")
public class AuroraConsumptionProfileDTO {

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("id")
    private String id;

    //note: this is the aurora project_id
    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("project_id")
    private String projectId;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("location")
    private String location;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("utility")
    private String utility;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("utility_id")
    private String utilityId;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("utility_rate")
    private String utilityRate;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("utility_rate_id")
    private String utilityRateId;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("utility_rate_version")
    private String utilityRateVersion;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("utility_rate_version_id")
    private String utilityRateVersionId;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("input_mode")
    private String inputMode;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("input_values")
    private List<Double> inputValues;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("monthly_bill")
    private List<Double> monthlyBill;

    @JsonSetter(contentNulls = Nulls.SET)
    @JsonProperty("monthly_energy")
    private List<Double> monthlyEnergy;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("hourly_energy")
    private List<Double> hourlyEnergy;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("efficiency_packages")
    private List<Object> efficiencyPackages;
}
