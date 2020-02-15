package com.albatross.api.v1.flow.enums;

public enum ProcessStepStatusType {
    ACTIVE(1L),
    COMPLETE(2L),
    CANCELLED(3L);

    public final Long id;

    ProcessStepStatusType(Long id) {
        this.id = id;
    }

    public static ProcessStepStatusType get(String name) {
        name = name.toLowerCase();
        for (ProcessStepStatusType s : values()) {
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
