package com.albatross.api.v1.flow.model;

import lombok.Data;

/**
 * Created by John Berns on 2021-08-06.
 */
@Data
public class VersusLeadEvent {
    private String id, channelWebsite, city, email, externalLeadId, firstName, lastName, leadComment, leadType, link,
      message, phone, postalCode, state, street, title, event, userId;
}
