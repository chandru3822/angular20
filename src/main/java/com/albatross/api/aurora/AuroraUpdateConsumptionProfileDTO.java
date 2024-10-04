package com.albatross.api.aurora;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.annotation.JsonTypeName;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
@JsonInclude(JsonInclude.Include.NON_ABSENT)
@JsonTypeInfo(include = JsonTypeInfo.As.WRAPPER_OBJECT, use = JsonTypeInfo.Id.NAME)
@JsonTypeName("consumption_profile")
public class AuroraUpdateConsumptionProfileDTO {

    //An array of the monthly energy in kWh. Null values allowed as "null".
    @JsonProperty("monthly_energy")
    private List<String> monthlyEnergy;

    public void setMonthlyEnergy(List<Double> monthlyEnergy) {
        List<String> temp = new ArrayList<>();
        for(int i= 0; i < monthlyEnergy.size(); i++){
            Double me = monthlyEnergy.get(i);
            if(me != null) {
                temp.add(me.toString());
            }
            else {
                temp.add("null");
            }
        }
        this.monthlyEnergy = temp;
    }
}
