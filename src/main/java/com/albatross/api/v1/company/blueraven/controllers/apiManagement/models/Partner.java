package com.albatross.api.v1.company.blueraven.controllers.apiManagement.models;

import lombok.Data;

import java.util.List;

@Data
public class Partner {
    private Long id;

    private String code, name;

    private List<Key> keys;
}
