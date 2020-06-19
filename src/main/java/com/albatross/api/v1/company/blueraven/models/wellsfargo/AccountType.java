package com.albatross.api.v1.company.blueraven.models.wellsfargo;

public enum AccountType {
    DEFAULT(""),
    DEMAND_DEPOSIT("D"),
    GENERAL_LEDGER("G"),
    SAVINGS("S");

    private final String abbr;

    AccountType(final String abbr) {
        this.abbr = abbr;
    }

    @Override
    public String toString() {
        return this.abbr;
    }
}
