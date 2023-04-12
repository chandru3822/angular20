package com.albatross.api.v1.flow.enums;

public enum AppAttachmentEnvironment {
    PROD(1L),
    UAT(2L),
    STAGE(3L),
    DEV(4L),
    FLUX(5L),
    LOCAL(3L); //NOTE you have to change this value to match the apps you want to see in local

    public final Long id;

    AppAttachmentEnvironment(Long id) {
        this.id = id;
    }

    public static AppAttachmentEnvironment get(String name) {
        name = name.toLowerCase();
        for (AppAttachmentEnvironment s : values()) {
            if (s.toString().toLowerCase().equals(name)) {
                return s;
            }
        }
        throw new IllegalArgumentException();
    }

    public String toString() {
        return name().toLowerCase().replaceAll("_", " ");
    }
}
