package com.albatross.api.disclosureForm;

import com.albatross.api.utils.SqlCache;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.http.HttpTimeoutException;
import java.time.Duration;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.TimeoutException;

@Service
@RequiredArgsConstructor
@Slf4j
public class DisclosureFormService {
    private final SqlCache sqlCache;

    @Value("${app.srec.host}")
    private String srecHost;

    @Value("${app.srec.token}")
    private String srecToken;

    public Srec getSrec(@NotNull Long projectId, @NotNull Long proposalNumber) {
        Map<String, Object> params = Map.of("projectId", projectId, "proposalNumber", proposalNumber);
        return sqlCache.getBySql(DisclosureFormQuery.getSrec, params, Srec.class).orElse(null);
    }

    public boolean send(@NotNull Long projectId, @NotNull Long proposalNumber) {
        Map<String, Object> params = Map.of("projectId", projectId, "proposalNumber", proposalNumber);
        Srec srec = sqlCache.getBySql(DisclosureFormQuery.getSrec, params, Srec.class)
                            .orElse(null);

        // create disclosure doc only if all the following are met:
        // - there is a proposal
        // - a disclosure form wasn't already created
        // - proposal is IL SREC
        // - project is in Illinois
        if (
            srec == null ||
                srec.getIlSrecDisclosureFormId() != null ||
                srec.getSrecValue() == null ||
                !Objects.equals(srec.getProjectStateAbbreviation(), "IL")) {
            return true;
        }

        boolean successfullySent = false;
        boolean isFinanced = !srec.getLoanType().toLowerCase().contains("cash");

        var body = new SrecDTO();
        body.setFormName(srec.getProposalNumber() + " " + srec.getContactName() + " " + srec.getProjectId());
        body.setCustomerName(srec.getProjectName());
        body.setCustomerAddressEmail(srec.getContactEmail());
        body.setCustomerAddressPhone(srec.getContactPhone());
        body.setCustomerAddress1(srec.getProjectStreet1());
        body.setCustomerAddressZip(srec.getProjectPostalCode());
        body.setCustomerAddressCity(srec.getProjectCity());
        body.setCustomerAddressState(srec.getProjectStateAbbreviation());

        body.setElectricUtility(srec.getUtilityCompanyName());

        //Naperville users qualify as municipal utility but 3rd part is picky and needs this exact naming
        if (body.getElectricUtility().equalsIgnoreCase("Naperville Electric Utility")) {
            body.setElectricUtility("Municipal Utility");
            body.setMuniCOOPName("City of Naperville");
        }

        body.setDepositOwed(srec.getTotalCost());
        body.setReferenceNumber(srec.getProjectId().toString());

        var systemSizeKw = new BigDecimal(srec.getSystemSize()).divide(new BigDecimal(1000));
        var systemSizeAcKw = new BigDecimal(srec.getSystemSizeAc()).divide(new BigDecimal(1000));

        body.setProjectSizeKwDc(systemSizeKw.toString());
        body.setProjectSizeKwAc(systemSizeAcKw.toString());
        body.setGrossElectricProduction(srec.getYearOneKwhOutput());

        var srecValue = new BigDecimal(srec.getSrecValue().toString()).divide(new BigDecimal("0.9"), 2, RoundingMode.HALF_UP);

        body.setExpectedRecValue(srecValue.toString());
        body.setRecCustomerPayment(srec.getSrecValue().toString());

        if (isFinanced) {
            body.setFinalAmountOwed("0");
            body.setFinalPaymentDue("N/A");
            body.setInstallationOwed("0");
            body.setInitialDepositOwed(srec.getTotalCost());
        } else {
            Long halfTotalCost = Long.parseLong(srec.getTotalCost()) / 2;

            body.setFinalAmountOwed(halfTotalCost.toString());
            body.setFinalPaymentDue("Upon Substantial Completion");
            body.setInstallationOwed(halfTotalCost.toString());
            body.setInitialDepositOwed("0");
        }

        try {
            WebClient client = WebClient.create(srecHost);
            ResponseEntity<String> res = client
                .post()
                .uri("/create_disclosure_dg/")
                .header("Authorization", "Token " + srecToken)
                .body(Mono.just(body), SrecDTO.class)
                .retrieve()
                .toEntity(String.class)
                .timeout(Duration.ofSeconds(30))
                .onErrorMap(TimeoutException.class, e -> new HttpTimeoutException("HIC (SREC): Timeout issue: " + e.getMessage()))
                .block();

            JSONObject resultBody = new JSONObject(res.getBody());
            saveFormID(projectId, proposalNumber, resultBody.getString("FormID"));

            successfullySent = true;
        } catch (WebClientResponseException e) {
            log.error("HIC (SREC): Error generating disclosure doc (" + projectId + ", " + proposalNumber + "): " + e.getMessage() + ": " + e.getResponseBodyAsString());
        } catch (Exception e) {
            log.error("HIC (SREC) (" + projectId + ", " + proposalNumber + "): " + e.getMessage());
        }

        return successfullySent;
    }

    public Long getProposalNumber(@NotNull Long cfgaID, @NotNull Long ppsID) {
        Map<String, Object> params = Map.of("cfgaID", cfgaID, "ppsID", ppsID);
        return sqlCache.queryForObjectBySql(DisclosureFormQuery.getProposalNumber, params, Long.class);
    }

    private void saveFormID(@NotNull Long projectID, @NotNull Long propNbr, @NotNull String formID) {
        Map<String, Object> params = new HashMap<>();
        params.put("projectID", projectID);
        params.put("propNbr", propNbr);
        params.put("formID", formID);
        sqlCache.updateBySql(DisclosureFormQuery.setDisclosureID, params);
    }
}
