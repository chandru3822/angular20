package com.albatross.api.v1.flow.enums;

public enum NotificationType {
    EMAIL(1L),
    SMS(2L);

    public final Long id;

    NotificationType(Long id) {
        this.id = id;
    }

    public static NotificationType get(String name) {
        name = name.toLowerCase();
        for (NotificationType s : values()) {
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
