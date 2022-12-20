package com.albatross.api.v1.flow.enums;

public enum AttachmentType {
    AHJ_PERMITTING(1L),
    AHJ_INSPECTION(2L),
    EMAIL_OR_TEXT(3L),
    EXPENSE_RECEIPTS(4L),
    AHJ_DESIGN(5L),
    UTILITY_SUBMISSION(6L),
    UTILITY_RATES(7L),
    APP_DOWNLOAD(8L),
    USER_IMAGE(9L),
    DESIGN_REQUIREMENT(10L),
    ELECTRICAL_REQUIREMENT(11L),
    STRUCTURAL_REQUIREMENT(12L),
    AHJ_STRUCTURAL_ULT(13L),
    AHJ_STRUCTURAL_ROOF_SNOW_LOAD_OVERRIDE(14L),
    AHJ_STRUCTURAL_SNOW_LOAD_REDUCTION(15L),
    AHJ_STRUCTURAL_WIND_EXPOSURE_OVERRIDE(16L),
    AHJ_ELECTRICAL_CODE(17L),
    AHJ_FIRE_SETBACKS(18L),
    AHJ_GROUND_ROD_REQ(19L),
    AHJ_AC_DISCONNECT(20L),
    AHJ_METER_CAN_TAPS(21L),
    AHJ_PV_PRODUCTION_METER(22L),
    AHJ_PV_AC_SWAP_LOCATIONS(23L),
    UTILITY_ADDITIONAL_REQS_DOCUMENT(24L),
    UTILITY_APPROVAL(25L),
    EPC_UTILITY_BILL(26L),
    EPC_INSTALLATION_AGREEMENT(27L),
    EPC_FINAL_DESIGN_SIGNED(28L),
    COMPANY_LOGO(29L),
    EPC_NON_CATEGORIZED(30L),
    DEAL_CALENDAR_EVENT_ATTACHMENT(31L),
    FILE_EXPORT(32L),
    FEEDBACK_ATTACHMENT(33L);

    public final Long id;

    AttachmentType(Long id) {
        this.id = id;
    }

    public static AttachmentType get(String name) {
        name = name.toLowerCase();
        for (AttachmentType s : values()) {
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
