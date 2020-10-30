package com.albatross.api.v1.flow.model;

import lombok.Data;

/**
 * Created by Joseph Canto on 2020-10-23.
 */
@Data
public class RicochetLead {
    private Long uniqueIdentifier, hubspotId;
    private Customer customer;
    private String lead_source, status, leadOwner, lead_source_detail;

    @Data
    public static class Customer {
        private Address address;
        private String firstName, lastName, phone1, email;
    }

    @Data
    public static class Address {
        private String address1, city, zip, state;
    }
}
