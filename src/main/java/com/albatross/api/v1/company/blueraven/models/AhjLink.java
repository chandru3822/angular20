package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjLink {
    private Long id;
    private Long linkTypeId;
    private String name, link, username, password, notes;
}