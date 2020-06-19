package com.albatross.api.v1.company.blueraven.models.wellsfargo;

import lombok.Data;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Data
public class PaymentRecord implements com.albatross.api.v1.company.blueraven.models.wellsfargo.FlatFileRecord {
    private final RecordType recordId = RecordType.PAYMENT;

    // max length: 3; mandatory
    private final String paymentType = "CHK";

    // max length: 1; optional for CHK
    private final String creditDebitFlag = "C";

    // max length: 30; mandatory
    private String transactionNumber;

    // date printed on check; max length: 10; mandatory
    private Date transactionDate = new Date();

    // max length: 10; optional
    private Date effectiveDate;
    private Date processDate;

    // max length: 11; mandatory
    private Double paymentAmount = 0.0;

    // max length: 3; mandatory
    private String currency = "USD";

    // max length: 1; mandatory
    private AccountType originatingAccountType = AccountType.DEMAND_DEPOSIT;

    // max length: 35; mandatory
    private String originatingAccount;

    // max length: 3; optional
    private String originatingAccountCurrency;

    // max length: 3; mandatory
    private String originatingBankIDType = "ABA";

    // routing/transit number; max length: 11; mandatory
    private String originatingBankId;

    // max length: 1; optional for CHK
    private AccountType receivingPartyAccountType;

    // max length: 35; optional for CHK
    private String receivingPartyAccount;

    // max length: 3; optional for CHK
    private String receivingAccountCurrency;

    // max length: 3; optional for CHK
    private String receivingBankPrimaryIDType;

    // max length: 11; optional for CHK
    private String receivingBankPrimaryID;

    // max length: 35; optional for CHK
    private String receivingBankSecondaryID;

    // max length: 1; optional for CHK
    private String eddHandlingCode;

    // max length: 1; optional for CHK
    private String pdpHandlingCode;

    // max length: 60; optional for CHK
    private String eddBillerID;

    // max length: 1; optional for CHK
    private String invoiceManagerFlag;

    // max length: 15; optional for CHK
    private String ceoCompanyID;

    // max length: 35; optional for CHK
    private String chargeDescription;

    // max length: 19; optional for CHK
    private Double exchangeRate;

    // max length: 1; optional for CHK
    private String consumerPaymentIndicator;

    // max length: 1; optional for CHK
    private String filler;

    public PaymentRecord(String txNum, Double amount, String accountNum, String routingNum, String memo) {
        this.transactionNumber = txNum;
        this.paymentAmount = amount;
        this.originatingAccount = accountNum;
        this.originatingBankId = routingNum;
        this.chargeDescription = memo;
    }

    public List<Object> getFields() {
        return Arrays.asList(
                recordId,
                paymentType,
                creditDebitFlag,
                transactionNumber,
                transactionDate,
                effectiveDate,
                processDate,
                paymentAmount,
                currency,
                originatingAccountType,
                originatingAccount,
                originatingAccountCurrency,
                originatingBankIDType,
                originatingBankId,
                receivingPartyAccountType,
                receivingPartyAccount,
                receivingAccountCurrency,
                receivingBankPrimaryIDType,
                receivingBankPrimaryID,
                receivingBankSecondaryID,
                eddHandlingCode,
                pdpHandlingCode,
                eddBillerID,
                invoiceManagerFlag,
                ceoCompanyID,
                chargeDescription,
                "",
                consumerPaymentIndicator,
                filler);
    }
}
