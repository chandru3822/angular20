package com.albatross.api.v1.flow.enums;

public enum UserStatusType {
    ACTIVE(1L),
    PENDING(2L),
    TERMINATED(3L),
    NEW_REQUEST(5L),
    EXPIRED(6L),
    PENDING_TERMINATION(7L),
    INACTIVE(8L);

    public final Long id;

    UserStatusType(Long id) {
        this.id = id;
    }

    public static UserStatusType get(String name) {
        name = name.toLowerCase();
        for (UserStatusType s : values()) {
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
