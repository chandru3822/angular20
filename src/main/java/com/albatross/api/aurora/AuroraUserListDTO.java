package com.albatross.api.aurora;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

@Data
public class AuroraUserListDTO {

    @JsonProperty("users")
    private List<AuroraUser> users;

}
