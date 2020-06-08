package com.albatross.api.v1.company.blueraven.models.wellsfargo;

import lombok.Data;

import java.util.Arrays;
import java.util.List;

@Data
public class Party implements com.albatross.api.v1.company.blueraven.models.wellsfargo.FlatFileRecord {
    private final RecordType recordId = RecordType.PARTY;

    // max length: 2; mandatory
    private com.albatross.api.v1.company.blueraven.models.wellsfargo.AddressIndicator addressIndicator;

    // max length: 60; mandatory
    private String name;

    // max length: 60; optional
    private String additionalName;

    // max length: 20; optional
    private String identificationNumber;

    // max length: 55; only include if the originating party's address will be used as the return address
    private String address1;

    // max length: 55; only include if the originating party's address will be used as the return address
    private String address2;

    // max length: 55; only include if the originating party's address will be used as the return address
    private String address3;

    // max length: 30; only include if the originating party's address will be used as the return address
    private String city;

    // max length: 3; only include if the originating party's address will be used as the return address
    private String state;

    // max length: 9; only include if the originating party's address will be used as the return address
    private String postalCode;

    // max length: 2; only include if the originating party's address will be used as the return address
    private String countryCode = "US";

    // max length: 30; only include if the originating party's address will be used as the return address
    private String countryName = "United States";

    // max length: 80; optional
    private String emailAddress;

    // max length: 10; optional
    private String phoneNumber;

    public List<Object> getFields() {
        return Arrays.asList(
                recordId,
                addressIndicator,
                name,
                additionalName,
                identificationNumber,
                address1,
                address2,
                address3,
                city,
                state,
                postalCode,
                countryCode,
                countryName,
                emailAddress,
                phoneNumber);
    }
}
