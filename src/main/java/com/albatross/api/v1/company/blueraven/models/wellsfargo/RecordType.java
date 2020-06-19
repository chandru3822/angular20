package com.albatross.api.v1.company.blueraven.models.wellsfargo;

public enum RecordType {
    HEADER("HD"),
    PAYMENT("PY"),
    PARTY("PA"),
    SUPPLEMENTAL_CHECK("CK"),
    INVOICE("IN"),
    TRAILER("TR");

    private final String abbr;

    RecordType(final String abbr) {
        this.abbr = abbr;
    }

    @Override
    public String toString() {
        return this.abbr;
    }
}
