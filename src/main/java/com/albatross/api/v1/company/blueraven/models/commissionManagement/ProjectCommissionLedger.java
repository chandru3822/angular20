package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import lombok.Getter;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

import static com.google.common.base.Preconditions.checkArgument;

public class ProjectCommissionLedger {
    private final List<Entry> entries;

    public ProjectCommissionLedger() {
        entries = new ArrayList<>();
    }

    public ProjectCommissionLedger(Instant timestamp, BigDecimal totalProjectValue) {
        entries = new ArrayList<>();
        entries.add(Entry.totalValue(timestamp, totalProjectValue));
    }

    public ProjectCommissionLedger recordAdjustment(Instant timestamp, BigDecimal adjustment) {
        BigDecimal remainingValue = getRemainingValue();
        checkArgument(adjustment.signum() >= 0,
                "Adjustment (%s) must be positive or zero.",
                NumberFormat.getCurrencyInstance().format(adjustment));
        checkArgument(remainingValue.compareTo(adjustment) >= 0,
                "Adjustment (%s) cannot exceed project remaining value (%s)",
                NumberFormat.getCurrencyInstance().format(adjustment),
                NumberFormat.getCurrencyInstance().format(remainingValue));
        entries.add(new Entry(timestamp, adjustment.negate(), BigDecimal.ZERO, adjustment));
        return this;
    }

    public ProjectCommissionLedger recordCommission(Instant timestamp, BigDecimal commission) {
        BigDecimal remainingValue = getRemainingValue();
        BigDecimal outstandingAdjustments = getOutstandingAdjustments();

        checkArgument(commission.signum() >= 0,
                "Commission (%s) must be positive or zero.",
                NumberFormat.getCurrencyInstance().format(commission));
        checkArgument(remainingValue.add(outstandingAdjustments)
                        .compareTo(commission) >= 0,
                "Commission (%s) cannot exceed project remaining value (%s) plus outstanding adjustments (%s)",
                NumberFormat.getCurrencyInstance().format(commission),
                NumberFormat.getCurrencyInstance().format(remainingValue),
                NumberFormat.getCurrencyInstance().format(outstandingAdjustments));

        BigDecimal adjustmentsOutstanding = getOutstandingAdjustments();

        if (adjustmentsOutstanding.compareTo(commission) >= 0) {
            // adjustments outstanding exceeds commission amount; commission goes to repay adjustment
            entries.add(new Entry(timestamp, BigDecimal.ZERO, commission, commission.negate()));
        } else {
            // commission exceeds adjustment; it pays off what adjustments remain, and then decreases remaining value
            BigDecimal remainingValueDiff = commission.subtract(adjustmentsOutstanding)
                                                        .negate();
            BigDecimal adjustmentDiff = adjustmentsOutstanding.negate();
            entries.add(new Entry(timestamp, remainingValueDiff, commission, adjustmentDiff));
        }

        return this;
    }

    public ProjectCommissionLedger recordEntry(Instant timestamp, BigDecimal commission, BigDecimal adjustment) {
        BigDecimal remainingValue = getRemainingValue();
        checkArgument(commission.signum() >= 0,
                "Commission (%s) must be positive or zero.",
                NumberFormat.getCurrencyInstance().format(commission));
        checkArgument(adjustment.signum() >= 0,
                "Adjustment (%s) must be positive or zero.",
                NumberFormat.getCurrencyInstance().format(adjustment));
        checkArgument(remainingValue.compareTo(adjustment.add(commission)) >= 0,
                "Commission (%s) plus adjustment (%s) cannot exceed project remaining value (%s)",
                NumberFormat.getCurrencyInstance().format(commission),
                NumberFormat.getCurrencyInstance().format(adjustment),
                NumberFormat.getCurrencyInstance().format(remainingValue));

        entries.add(new Entry(timestamp, commission.add(adjustment).negate(), commission, adjustment));
        return this;
    }

    public BigDecimal getRemainingValue() {
        return sum(Entry::getRemainingValue);
    }

    public BigDecimal getOutstandingAdjustments() {
        return sum(Entry::getAdjustmentsOutstanding);
    }

    public BigDecimal getCommissionsEarned() {
        return sum(Entry::getCommissionsEarned);
    }

    private BigDecimal sum(Function<Entry, BigDecimal> f) {
        return entries.stream()
                .map(f)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }


    @Getter
    private static class Entry {
        private final Instant timestamp;
        private final BigDecimal remainingValue, commissionsEarned, adjustmentsOutstanding;

        public static Entry totalValue(Instant timestamp, BigDecimal totalValue) {
            return new Entry(timestamp, totalValue);
        }

        private Entry(Instant timestamp, BigDecimal totalValue) {
            checkArgument(totalValue.signum() >= 0,
                    "Project total value must be positive or zero.");

            this.timestamp = timestamp;
            this.remainingValue = totalValue;
            this.commissionsEarned = BigDecimal.ZERO;
            this.adjustmentsOutstanding = BigDecimal.ZERO;
        }

        public Entry(Instant timestamp, BigDecimal remainingValue, BigDecimal commissionsEarned, BigDecimal adjustmentsOutstanding) {
            BigDecimal rowTotal = remainingValue.add(commissionsEarned.add(adjustmentsOutstanding));
            checkArgument(rowTotal.compareTo(BigDecimal.ZERO) == 0,
                    "Row values must sum to zero; remaining value Δ: %s; commissions Δ: %s; adjustments Δ: %s",
                    NumberFormat.getCurrencyInstance().format(remainingValue),
                    NumberFormat.getCurrencyInstance().format(commissionsEarned),
                    NumberFormat.getCurrencyInstance().format(adjustmentsOutstanding));
            checkArgument(remainingValue.signum() <= 0,
                    "Changes to remaining value must always be zero or negative (i.e., decreasing remaining value).");
            checkArgument(commissionsEarned.signum() >= 0,
                    "Changes to commissions earned must always be zero or positive (i.e., increasing commissions earned).");
            this.timestamp = timestamp;
            this.remainingValue = remainingValue;
            this.commissionsEarned = commissionsEarned;
            this.adjustmentsOutstanding = adjustmentsOutstanding;
        }
    }
}
