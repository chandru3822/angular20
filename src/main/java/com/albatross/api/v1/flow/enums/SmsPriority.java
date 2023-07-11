package com.albatross.api.v1.flow.enums;

public enum SmsPriority {
    PROJECT(1),
    CONTACT(1),
    USER(2),
    NOTE_MENTION(3),
    SMALL_GROUP(4),
    LARGE_GROUP(5);

    public final Integer level;

    SmsPriority(Integer level) {
        this.level = level;
    }

}
