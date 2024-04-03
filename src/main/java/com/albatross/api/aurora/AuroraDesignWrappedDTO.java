package com.albatross.api.aurora;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.annotation.JsonTypeName;
import lombok.Data;

@Data
@JsonTypeInfo(include = JsonTypeInfo.As.WRAPPER_OBJECT, use = JsonTypeInfo.Id.NAME)
@JsonTypeName("design")
public class AuroraDesignWrappedDTO {

    //note: this is the aurora unique id
    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("id")
    private String id;

    //note: this is the aurora project_id
    @JsonProperty("project_id")
    private String projectId;

    //name of the design
    @JsonProperty("name")
    private String name;

}
