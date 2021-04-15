package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.StringJoiner;

@Data
public class PandaDocProjectDetails {
    private String state, utilityCompany, financier;
    private Integer companyId;
    private Long projectId, proposalNbr;
    private String closerFirstName, closerLastName, closerEmail;
    private String customerFirstName, customerLastName, customerEmail;
    private String mailingState, city, phone, postalCode, mailingStreet1, mailingStreet2, country,
        projectName, totalCashDownPayment, systemSize, firstCashPaymentAmount, totalSystemPrice,
        loanTerm, interestRate, loanType;

    public String getTemplateName(Boolean isSpanish, String genericName) {
        StringJoiner sj = new StringJoiner("_");

        // If companyId is BRS
        if (companyId == 3) {
            sj.add("1");
        }
        else {
            sj.add(companyId.toString());
        }

        if (isSpanish) {
            sj.add("Spanish");
        }
        sj.add(state);

        if (utilityCompany.equals(genericName)) {
          sj.add(utilityCompany);
        }
        else {
          sj.add(mailingState + " - " + utilityCompany);
        }

        sj.add(financier);

        return sj.toString();
    }

    public JSONObject getBlueRavenInfo(String role) throws JSONException {
        return getInfo("BRS Support", "", "support@blueravensolar.com", role);
    }

    public JSONObject getCloserInfo(String role) throws JSONException {
        return getInfo(closerFirstName, closerLastName, closerEmail, role);
    }

    public JSONObject getCustomerInfo(String role) throws JSONException {
        return getInfo(customerFirstName, customerLastName, customerEmail, role);
    }

    private JSONObject getInfo(String first, String last, String email, String role) throws JSONException {
        JSONObject info = new JSONObject();
        info.put("first_name", first);
        info.put("last_name", last);
        info.put("email", email);
        info.put("role", role);

        return info;
    }
}
