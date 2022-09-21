package com.albatross.api.v1.company.blueraven.models.ahj;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Getter
@Setter
public class AhjPermitDetail extends AhjPermit {
    private List<AhjLink> submissionLinks, followUpLinks;
    private List<AhjContact> submissionContacts, followUpContacts;
}
