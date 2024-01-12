package com.albatross.api.v1.flow.model.workQueue;

import lombok.Data;

/**
 * Created by John Berns on 2021-15-11.
 */

@Data
public class WorkQueueTypeSchedule {
  private String day, startTime, endTime;
  private boolean selected;

  public String toString() {
    String builder = "{\"day\" :" +
                     "\"" + day + "\"" +
                     ", \"startTime\" :" +
                     (startTime == null ? null : "\"" + startTime + "\"") +
                     ", \"endTime\" :" +
                     (endTime == null ? null : "\"" + endTime + "\"") +
                     ", \"selected\" :" +
                     selected +
                     "}";
    return builder;
  }
}
