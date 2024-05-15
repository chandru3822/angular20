package com.albatross.api.aurora;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class AuroraUser {

    //i couldn't figure out a way to handle this wrapper stuff and we are getting pressured by BR to release asap so i am leaving it for now

    //note: this is the aurora unique id
    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonProperty("id")
    private String id;

    //note: this is the aurora email
    @JsonProperty("email")
    private String email;


}
