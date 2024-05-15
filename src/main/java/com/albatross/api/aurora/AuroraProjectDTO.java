package com.albatross.api.aurora;

import com.fasterxml.jackson.annotation.*;
import lombok.Data;

@Data
@JsonTypeInfo(include = JsonTypeInfo.As.WRAPPER_OBJECT, use = JsonTypeInfo.Id.NAME)
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonTypeName("project")
public class AuroraProjectDTO {

    //note: this is the aurora unique id, not our project id
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

    @JsonProperty("owner_id")
    private String ownerId;
}
