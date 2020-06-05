package com.albatross.api.v1.company.blueraven.models.wellsfargo;

public enum AddressIndicator {
    ORIGINATING_PARTY("PR"),
    ORIGINATING_BANK("O1"),
    RECEIVING_PARTY("PE"),
    RECEIVING_BANK("RB"),
    FIRST_INTERMEDIARY_BANK("I1"),
    SECOND_INTERMEDIARY_BANK("I2"),
    ORDERING_PARTY("OB"),
    ORDERING_BANK("O5"),
    OVERNIGHT_DELIVERY_PARTY("DA");

    private final String abbr;

    AddressIndicator(final String abbr) {
        this.abbr = abbr;
    }

    @Override
    public String toString() {
        return this.abbr;
    }
}
