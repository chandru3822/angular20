package com.albatross.api.v1.flow.enums;

public enum RequirementType {
    CUSTOM_FIELD(1L),
    FUNCTION(2L);

    public final Long id;

    RequirementType(Long id) {
        this.id = id;
    }

    public static RequirementType get(String name) {
        name = name.toLowerCase();
        for (RequirementType s : values()) {
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
