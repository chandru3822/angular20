package com.albatross.api.v1.flow.model.workQueue;

import lombok.Data;

@Data
public class WorkQueueTypeSortingOrder {
  private String columnSortingOrder, value;
  private boolean sortDesc;

  // converts the data to a string representation of a json object
  public String toString() {
    String builder = "{\"columnSortingOrder\" :" +
      "\"" + columnSortingOrder + "\"" +
      ", \"value\" :" +
      "\"" + value + "\"" +
      ", \"sortDesc\" :" + sortDesc + "}";
    return builder;
  }
}
