package com.albatross.api.aurora;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.annotation.JsonTypeName;
import lombok.Data;

@Data
@JsonTypeInfo(include = JsonTypeInfo.As.WRAPPER_OBJECT, use = JsonTypeInfo.Id.NAME)
@JsonTypeName("project")
public class AuroraProjectDTO {

    //note: this is the aurora unique id, not our project id
    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("id")
    private String id;

    //this should be our project_id
    @JsonProperty("external_provider_id")
    private String externalProviderId;

    @JsonProperty("name")
    private String name;

    @JsonProperty("customer_first_name")
    private String customerFirstName;

    @JsonProperty("customer_last_name")
    private String customerLastName;

    @JsonProperty("customer_phone")
    private String customerPhone;

    @JsonProperty("address")
    private String address;
}
