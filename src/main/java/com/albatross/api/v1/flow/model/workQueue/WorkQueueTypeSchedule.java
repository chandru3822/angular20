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
      StringBuilder builder = new StringBuilder();
      builder.append("{\"day\" :");
      builder.append("\""+day+"\"");
      builder.append(", \"startTime\" :");
      builder.append(startTime == null ? null : "\""+startTime+"\"");
      builder.append(", \"endTime\" :");
      builder.append(endTime == null ? null : "\""+endTime+"\"");
      builder.append(", \"selected\" :");
      builder.append(selected);
      builder.append("}");
      return builder.toString();
    }
}
