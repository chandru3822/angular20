package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import lombok.Data;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Data
public class UserDateRange {
    private Long userId;
    private LocalDate startDate, endDate;

    public Set<LocalDate> getDateRange() {
        return Stream.iterate(startDate, d -> d.plusDays(1))
                .limit(getNumDaysInRange())
                .collect(Collectors.toSet());
    }

    public long getNumDaysInRange() {
        LocalDate end = endDate != null ? endDate : LocalDate.now();

        if (startDate == null || end.isBefore(startDate))
            return 0;

        return ChronoUnit.DAYS.between(startDate, end.plusDays(1));
    }
}
