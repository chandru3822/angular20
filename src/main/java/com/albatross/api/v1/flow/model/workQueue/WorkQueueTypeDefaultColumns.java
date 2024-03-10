package com.albatross.api.v1.flow.model.workQueue;

import lombok.Data;

/**
 * Created by Eric Thomson on 02/19/2024.
 * Each WorkQueue has x number of default columns that are currently hardcoded into the
 *  database(column name defaultColumnDisplay in flow.workQueueType)
 * The visibility of each of these columns can be controlled in the admin settings
 * Each needs a text, value, and show property to match up with the vuetify structure when creating the datatable
 */

@Data
public class WorkQueueTypeDefaultColumns {
  private String text, value;
  private boolean show;

  // converts the data to a string representation of a json object
  public String toString() {
    String builder = "{\"text\" :" +
      "\"" + text + "\"" +
      ", \"value\" :" +
      "\"" + value + "\"" +
      ", \"show\" :" + show + "}";
    return builder;
  }
}
