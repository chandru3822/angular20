package com.albatross.api.v1.flow.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Getter
@Setter
@AllArgsConstructor
public class SmartlistResult {

    List<SmartlistFieldAssignment> headers;

    List<Map<String, Object>> data;
}
