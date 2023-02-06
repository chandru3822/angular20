package com.albatross.api.v1.flow.enums;

public enum DenyListType {
    PROCESS_LIMIT_ADD_PROJECT(1L);

    public final Long id;

    DenyListType(Long id) {
        this.id = id;
    }

    public static DenyListType get(String name) {
        name = name.toLowerCase();
        for (DenyListType d : values()) {
            if (d.toString().equals(name)) {
                return d;
            }
        }
        throw new IllegalArgumentException();
    }

    public String toString() {
        return name().toLowerCase().replaceAll("_", " ");
    }
}
