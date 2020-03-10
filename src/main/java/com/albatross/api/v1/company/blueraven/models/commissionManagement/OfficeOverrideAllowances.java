package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateDeserializer;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OfficeOverrideAllowances {
    private static final ObjectMapper om = new ObjectMapper();

    private Long officeId;
    private String officeName;
    private List<AllowanceEntry> allowances;

    @SneakyThrows
    public void setAllowances(String json) {
        if (json == null || json.isEmpty())
            return;
        this.allowances = om.readValue(json, new TypeReference<List<AllowanceEntry>>(){});
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class AllowanceEntry {
        private Long id;
        @JsonDeserialize(using = LocalDateDeserializer.class)
        private LocalDate startDate;

        @JsonDeserialize(using = LocalDateDeserializer.class)
        private LocalDate endDate;
        private BigDecimal allowance;
        private Boolean archived;
    }
}
