package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Data
public class TopRep {
    private Long userId, pitches;
    private String name, rank, userImageUrl, userImageAltText;
    private Boolean showFirst;
}
