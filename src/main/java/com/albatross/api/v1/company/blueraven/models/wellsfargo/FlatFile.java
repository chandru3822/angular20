package com.albatross.api.v1.company.blueraven.models.wellsfargo;

import lombok.Data;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.StringJoiner;

@Data
public class FlatFile {
    private final DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    // max length: 15
    private String controlNumber;

    // max length: 10
    private Date date = new Date();

    private List<FlatFileRecord> records = new ArrayList<>();

    private Integer paymentCount = 0;

    // max length: 21
    private Double paymentAmount = 0.0;

    public FlatFile(String controlNumber) {
        this.controlNumber = controlNumber;
    }

    public FlatFile(String controlNumber, Date date) {
        this.controlNumber = controlNumber;
        this.date = date;
    }

    public void addCheck(PaymentRecord pr, Party payer, Party payerBank, Party payee, SupplementalCheckRecord check) {
        records.add(pr);
        records.add(payer);
        records.add(payerBank);
        records.add(payee);
        records.add(check);
    }

    public void addCheck(PaymentRecord pr, Party payer, Party payerBank, Party payee, SupplementalCheckRecord check, InvoiceRecord invoice) {
        addCheck(pr, payer, payerBank, payee, check);
        records.add(invoice);
    }

    public void addRecord(FlatFileRecord rec) {
        records.add(rec);
    }

    public String toString() {
        StringJoiner rendered = new StringJoiner("\n");

        for (FlatFileRecord rec : records) {
            rendered.add(renderRecord(rec));
        }

        return String.format("HD|%s|%s\n%s\nTR|%s|%.2f\n",
                controlNumber,
                dateFormat.format(date),
                rendered.toString(),
                paymentCount,
                paymentAmount);
    }

    private String renderRecord(FlatFileRecord rec) {
        StringJoiner sj = new StringJoiner("|");

        if (rec.getRecordId() == RecordType.PAYMENT) {
            paymentAmount += ((PaymentRecord) rec).getPaymentAmount();
            paymentCount++;
        }

        for (Object field : rec.getFields()) {
            if (field instanceof Date) {
                field = dateFormat.format(field);
            } else if (field instanceof Double) {
                field = String.format("%.2f", field);
            }

            sj.add(field != null ? field.toString() : "");
        }

        return sj.toString();
    }
}
