package com.albatross.api.v1.company.blueraven.models.ahj.cycle_times;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class AhjPermitCycleTimeStats {
    private Stats approvedPermits, approvedAsBuilts, pendingPermits, pendingAsBuilts;

    public void add(Stats stats) {
        if (stats.getStatus() == Status.PENDING && stats.getType() == Type.PERMITS)
            pendingPermits = stats;
        else if (stats.getStatus() == Status.APPROVED && stats.getType() == Type.PERMITS)
            approvedPermits = stats;
        else if (stats.getStatus() == Status.PENDING && stats.getType() == Type.AS_BUILTS)
            pendingAsBuilts = stats;
        else if (stats.getStatus() == Status.APPROVED && stats.getType() == Type.AS_BUILTS)
            approvedAsBuilts = stats;
    };

    @Data
    public static class Stats {
        private Type type;
        private Status status;
        private float avg;
        private int median, max, count;
    }

    public enum Type {PERMITS,AS_BUILTS}
    public enum Status {PENDING, APPROVED}
}
