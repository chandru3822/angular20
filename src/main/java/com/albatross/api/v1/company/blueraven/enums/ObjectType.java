package com.albatross.api.v1.company.blueraven.enums;

public enum ObjectType {
  AHJ_DESIGN(1L, "ahj_design_id"),
  AHJ_UTILITY(2L, "ahj_utility_id"),
  AHJ_INSPECTION(3L, "ahj_inspection_id"),
  AHJ_PERMIT(4L, "ahj_permit_id"),
  COMMISSION_OVERRIDE(9L, "override_plan_id"),
  PROPOSAL(10L, "proposal_id");

  public final Long id;
  public final String primaryKeyColumn;

  ObjectType(Long id, String primaryKeyColumn) {
    this.id = id;
    this.primaryKeyColumn = primaryKeyColumn;
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
