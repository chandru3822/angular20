package com.albatross.api.v1.flow.model;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class DurationType {
    private Long id;
    private String durationType;
    private Boolean archived, inverseExpectation;
}
