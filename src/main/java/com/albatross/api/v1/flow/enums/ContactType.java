package com.albatross.api.v1.flow.enums;

public enum ContactType {
    CUSTOMER(1L),
    LEAD(2L);

    public final Long id;

    ContactType(Long id) {
        this.id = id;
    }

    public static ContactType get(String name) {
        name = name.toLowerCase();
        for (ContactType s : values()) {
            if (s.toString().equals(name)) {
                return s;
            }
        }
        throw new IllegalArgumentException();
    }

    public String toString() {
        return name().toLowerCase().replaceAll("_", " ");
    }
}
