package com.albatross.api.chase_bank;

import com.albatross.api.chase_bank.Ap6DelimitedSingleLineRecord.*;
import com.albatross.api.utils.SqlCache;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.base.Joiner;
import com.google.common.collect.ImmutableMap;
import lombok.Data;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.io.StringWriter;
import java.io.Writer;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.function.Consumer;
import java.util.function.Function;

import static com.google.common.base.Preconditions.checkArgument;
import static org.apache.commons.lang3.StringUtils.isNotBlank;

@Service
@Slf4j
public class ChaseBankService {
    private final static String COURIER_CODE = "USPS",
                                FORM_CODE = "BPLUSAP6",
                                CHASE_ACCOUNT_NUM = "370263003";

    @Autowired
    private SqlCache sqlCache;

    public String generateCsv_Ap6DelimitedSingleLine(Long batchId) throws Exception {
        try {
            // this takes all approved payments and adds them to the CSV file
            List<RebatePayment> payments = getPayments(batchId);
            checkArgument(payments != null && payments.size() > 0,
                    "found no approved payments");
            List<Ap6DelimitedSingleLineRecord> records = new ArrayList<>();
            List<RebatePaymentValidationException> failures = new ArrayList<>();

            for (RebatePayment payment : payments) {
                try {
                    Integer checkNumber = payment.getCheckNumber();
                    if (checkNumber == null) {
                        checkNumber = getNextCheckNumber(payment.getId());

                        //need to save the check number to the payment so we have a record of it and can export it
                        Map<String, Object> params = ImmutableMap.of("checkNumber", checkNumber,
                                                                     "paymentId", payment.getId());
                        sqlCache.update("chasebank.saveCheckNumberToPayment", params);
                    }
                    records.add(paymentToAp6DelimitedSingleLine(payment, checkNumber));
                } catch (RebatePaymentValidationException failure) {
                    failures.add(failure);
                }
            }

            if (!failures.isEmpty())
                throw new BadDataException(failures);
            return Ap6DelimitedSingleLineRecord.exportAsCsvString(records);
        } catch (BadDataException e) {
            throw e;
        } catch (Exception ex) {
            log.error("CHASE: Failed to generate Ap6DelimitedSingleLine CSV file", ex);
            throw ex;
        }
    }

    private Ap6DelimitedSingleLineRecord paymentToAp6DelimitedSingleLine(RebatePayment payment, Integer checkNumber) {
        try {
            RebatePaymentValidationException failures = new RebatePaymentValidationException(payment.getProjectId());

            String memo = String.format("Rebate payment %d of %d",
                    payment.getPaymentNumber(), payment.getTotalNumPayments());

            Ap6DelimitedSingleLineRecordBuilder builder = Ap6DelimitedSingleLineRecord.builder();
            failures.validate(payment.getAmount(),       Amount::new,        builder::paymentAmount)
                    .validate(payment.getId(),           CheckNumber::new,   builder::checkNumber)
                    .validate(payment.getProjectId(),    VendorNumber::new,  builder::vendorNumber)
                    .validate(payment.getAmount(),       Amount::new,        builder::netAmount)
                    .validate(payment.getAmount(),       Amount::new,        builder::grossAmount)
                    .validate(payment.getCustomerName(), Name::new,          builder::firstPayeeName)
                    .validate(payment.getStreet1(),      AddressLine::new,   builder::payeeAddressLine1)
                    .validate(payment.getCity(),         City::new,          builder::payeeCity)
                    .validate(payment.getState(),        State::valueOf,     builder::payeeState)
                    .validate(payment.getPostalCode(),   USPostalCode::new,  builder::payeePostalCode)
                    .validate(COURIER_CODE,              CourierCode::new,   builder::courierCode)
                    .validate(FORM_CODE,                 FormCode::new,      builder::formCode)
                    .validate(CHASE_ACCOUNT_NUM,         AccountNumber::new, builder::acctNumber)
                    .validate(checkNumber,               CheckNumber::new,   builder::checkNumber)
                    .validate(memo,                      Description::new,   builder::description)
                    .validate(LocalDate.now(),           PaymentDate::new,   builder::paymentDate)
                    .validate(LocalDate.now(),           InvoiceDate::new,   builder::invoiceDate)
                    .validate(getInvoiceNumber(),        InvoiceNumber::new, builder::invoiceNumber)
                    .validate(payment.getAmount(),       Amount::new,        builder::netAmount);

            if (payment.getStreet2().isPresent())
                failures.validate(payment.getStreet2().get(), AddressLine::new, builder::payeeAddressLine2);

            if (failures.hasErrors())
                throw failures;
            return builder.build();
        } catch (RebatePaymentValidationException e) {
            throw e;
        } catch (RuntimeException e){
            log.error("CHASE: Failed to generate CSV entry for project with Project id " + payment.getProjectId() + "; " + e.getMessage(), e);
            throw e;
        }
    }

    public List<RebatePayment> getPayments(Long batchId) {
        ImmutableMap<String, Object> params = ImmutableMap.of("batchId", batchId);
        return sqlCache.query("chasebank.getPaymentsInBatch", params, RebatePayment.class);
    }

    public Integer getInvoiceNumber() {
      return sqlCache.get("chasebank.getInvoiceNumber", new HashMap<>(), new SingleColumnRowMapper<>(Integer.class)).get();
    }

    public Integer getNextCheckNumber(Integer paymentId) {
        ImmutableMap<String, Object> params = ImmutableMap.of("paymentId", paymentId);
        return sqlCache.get("rebate.getCheckNumber", params, new SingleColumnRowMapper<>(Integer.class)).get();
    }

    @Setter
    private static class RebatePayment {
        @Getter
        private Integer id, paymentNumber, totalNumPayments, projectId, checkNumber;
        @Getter
        private BigDecimal amount;
        @Getter
        private String customerName;
                private String customerStreet1, customerStreet2, customerCity, customerState, customerPostalCode;
                private String mailingStreet1,  mailingStreet2,  mailingCity, mailingState, mailingPostalCode;

        private boolean useMailingAddress() {
            return isNotBlank(mailingStreet1)
                && isNotBlank(mailingCity)
                && isNotBlank(mailingState)
                && isNotBlank(mailingPostalCode);
        }

        public String getStreet1    () { return useMailingAddress() ? mailingStreet1    : (customerStreet1 == null ? "" : customerStreet1); }
        public String getCity       () { return useMailingAddress() ? mailingCity       : (customerCity == null ? "" : customerCity); }
        public String getState      () { return useMailingAddress() ? mailingState      : (customerState == null ? "" : customerState); }
        public String getPostalCode () { return useMailingAddress() ? mailingPostalCode : (customerPostalCode == null ? "" : customerPostalCode); }

        public Optional<String> getStreet2 () {
            return useMailingAddress() ? Optional.ofNullable(StringUtils.trimToNull(mailingStreet2))
                                       : Optional.ofNullable(StringUtils.trimToNull(customerStreet2));
        }
    }

    @Data
    public class RebatePaymentValidationException extends RuntimeException {
        private final Integer projectId;
        private final Map<String, String> errors = new HashMap<>();

        private RebatePaymentValidationException(Integer projectId) {
            this.projectId = projectId;
        }

        @Override
        public String getMessage() {
            return String.format("Project with Project id %s failed validation; errors are: %s",
              projectId, Joiner.on("; ").withKeyValueSeparator(":").join(errors));
        }

        private boolean hasErrors() {
            return !errors.isEmpty();
        }

        private <T, U> RebatePaymentValidationException validate(T val, Function<T, U> transform, Consumer<U> store) {
            try {
                store.accept(transform.apply(val));
                // only failures are recorded
            } catch (Exception e) {
                errors.put(val.toString(), e.getMessage());
            }

            return this;
        }
    }

    @RequiredArgsConstructor
    @Getter
    public class BadDataException extends Exception {
        private final List<RebatePaymentValidationException> failures;

        public String toCsv() {
            try {
                Writer writer = new StringWriter();
                CsvMapper csvMapper = new CsvMapper();

                // define CSV headers
                CsvSchema schema = CsvSchema.builder()
                        .addColumn("Project Id")
                        .addColumn("Failed Value")
                        .addColumn("Failure Reason")
                        .setUseHeader(true)
                        .build();

                // write to CSV
                SequenceWriter out = csvMapper.writer(schema).writeValues(writer);
                for (RebatePaymentValidationException failure : failures) {
                    for (Map.Entry<String, String> entry : failure.getErrors().entrySet()) {
                        Map<String, Object> m = ImmutableMap.of("Project Id", failure.getProjectId(),
                                "Failed Value", entry.getKey(),
                                "Failure Reason", entry.getValue());
                        out.write(m);
                    }
                }

                return writer.toString();
            } catch (Exception e) {
                String msg = "CHASE: Failed to generate CSV of validation failures";
                log.error(msg, e);
                throw new RuntimeException(msg, e);
            }
        }
    }
}
