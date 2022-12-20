package com.albatross.api.v1.company.blueraven.enums;

public enum ObjectType {
  AHJ_DESIGN(1L, "ahj_design_id", "feat_db_ahj_design_custom_field_value"),
  UTILITY(2L, "utility_id", "feat_db_utility_custom_field_value"),
  AHJ_INSPECTION(3L, "ahj_inspection_id", "feat_db_ahj_inspection_custom_field_value"),
  AHJ_PERMIT(4L, "ahj_permit_id", "feat_db_ahj_permit_custom_field_value"),
  HOA(24L, "hoa_id", "feat_db_hoa_custom_field_value"),
  COMMISSION_OVERRIDE(9L, "override_plan_id", "commission_override_custom_field_value"),
  PROPOSAL(10L, "proposal_id", "proposal_custom_field_value");

  public final Long id;
  public final String primaryKeyColumn;
  public final String tableName;

  ObjectType(Long id, String primaryKeyColumn, String tableName) {
    this.id = id;
    this.primaryKeyColumn = primaryKeyColumn;
    this.tableName = tableName;
  }

  public static ObjectType get(String name) {
    name = name.toLowerCase();
    for (ObjectType s : values()) {
      if (s.toString().equals(name) || s.textValue().equals(name)) {
        return s;
      }
    }
    throw new IllegalArgumentException();
  }

  public static ObjectType getById(Long id) {
    for (ObjectType s : values()) {
      if (s.id.equals(id)) {
        return s;
      }
    }
    throw new IllegalArgumentException();
  }

  public String toString() {
    return name().toLowerCase().replaceAll("_", " ");
  }

  public String textValue() {
    return name().toLowerCase();
  }
}
