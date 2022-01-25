package com.albatross.api.v1.flow.enums;

public enum ProcessStepRequirementType {
    PROCESS_STEP_CUSTOM_FIELD(1L),
    FUNCTION(2L),
    PROJECT_CUSTOM_FIELD(3L),
    CONTACT_CUSTOM_FIELD(4L),
    PROCESS_STEP_STATUS(7L),
    PROCESS_STEP_STATUS_CATEGORY(8L),
    PROJECT_STATUS(9L),
    PROJECT_STATUS_CATEGORY(10L);

    public final Long id;

    ProcessStepRequirementType(Long id) {
        this.id = id;
    }

}
