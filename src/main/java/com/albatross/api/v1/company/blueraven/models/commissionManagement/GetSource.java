package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;

/**
 * Created by randa on 4/13/17.
 * !Describe Purpose!
 */
@Getter
@Setter
public class GetSource {

    @Id
    private Long sourceId;
    private String sourceName;

}
