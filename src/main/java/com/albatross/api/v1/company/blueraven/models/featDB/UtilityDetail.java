package com.albatross.api.v1.company.blueraven.models.featDB;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-17.
 */
@Getter
@Setter
public class UtilityDetail extends Utility {
    private List<FeatDbLink> links;
    private List<FeatDbContact> contacts;
}
