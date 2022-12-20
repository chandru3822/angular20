package com.albatross.api.v1.company.blueraven.models.featDB;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class FeatDbContact {
    private Long id;
    private String name, title, email, phoneNumber, address, notes, hours;
    private Long contactTypeId;
}
