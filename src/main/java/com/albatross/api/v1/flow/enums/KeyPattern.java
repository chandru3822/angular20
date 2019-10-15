package com.albatross.api.v1.flow.enums;

public enum KeyPattern {
    UPLOADS(9L);

    public final Long id;

    KeyPattern(Long id) {
        this.id = id;
    }

    public static KeyPattern get(String name) {
        name = name.toLowerCase();
        for (KeyPattern s : values()) {
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
