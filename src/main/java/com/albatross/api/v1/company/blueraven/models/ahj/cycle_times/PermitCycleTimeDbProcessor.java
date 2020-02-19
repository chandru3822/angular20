package com.albatross.api.v1.company.blueraven.models.ahj.cycle_times;

import com.albatross.api.v1.company.blueraven.models.ahj.cycle_times.AhjPermitCycleTimeStats.Status;
import com.albatross.api.v1.company.blueraven.models.ahj.cycle_times.AhjPermitCycleTimeStats.Type;
import com.albatross.api.v1.company.blueraven.services.AhjPermitService;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.RowCallbackHandler;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import java.util.Optional;

/**
 * Bridges the gap between the SQL query results obtained in
 * {@link AhjPermitService#getPermitCycleTimeStats(Long, java.time.LocalDate, java.time.LocalDate)}
 * and the {@link AhjPermitCycleTimeStats} returned by the service layer.
 */
@Slf4j
public class PermitCycleTimeDbProcessor implements RowCallbackHandler {
    private AhjPermitCycleTimeStats allStats = null;

    private final Map<String, Type> dbTypeAliases = ImmutableMap.of("permits", Type.PERMITS,
                                                                    "as-builts", Type.AS_BUILTS);
    private final Map<String, Status> dbStatusAliases = ImmutableMap.of("pending", Status.PENDING,
                                                                        "approved", Status.APPROVED);
    @Override
    public void processRow(ResultSet rs) throws SQLException {
        allStats = new AhjPermitCycleTimeStats();

        do {
            AhjPermitCycleTimeStats.Stats stats = new AhjPermitCycleTimeStats.Stats();

            String type = rs.getString("type");
            if (dbTypeAliases.containsKey(type)) {
                stats.setType(dbTypeAliases.get(type));
            } else {
                log.warn("Row contains unknown type: {}", type);
            }

            String status = rs.getString("status");
            if (dbStatusAliases.containsKey(status)) {
                stats.setStatus(dbStatusAliases.get(status));
            } else {
                log.warn("Row contains unknown status: {}", status);
            }

            stats.setAvg(rs.getFloat("avg"));
            stats.setMedian(rs.getInt("median"));
            stats.setMax(rs.getInt("max"));
            stats.setCount(rs.getInt("count"));

            log.debug("Parsed row as: {}", stats);
            allStats.add(stats);
            log.debug("Stats accumulated so far: {}", allStats);
        } while (rs.next());
    }

    public Optional<AhjPermitCycleTimeStats> getStats() {
        return Optional.ofNullable(allStats);
    }
}
