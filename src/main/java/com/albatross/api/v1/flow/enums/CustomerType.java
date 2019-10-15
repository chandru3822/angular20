package com.albatross.api.v1.flow.enums;

public enum CustomerType {
    CUSTOMER(1L),
    LEAD(2L);

    public final Long id;

    CustomerType(Long id) {
        this.id = id;
    }

    public static CustomerType get(String name) {
        name = name.toLowerCase();
        for (CustomerType s : values()) {
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
