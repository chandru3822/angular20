package com.albatross.api.v1.company.blueraven.models.featDB;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class FeatDbLink {
    private Long id;
    private Long linkTypeId;
    private String name, link, username, password, notes;
}
