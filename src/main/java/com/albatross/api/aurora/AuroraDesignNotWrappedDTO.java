package com.albatross.api.aurora;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class AuroraDesignNotWrappedDTO {

    //i couldn't figure out a way to handle this wrapper stuff and we are getting pressured by BR to release asap so i am leaving it for now

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
