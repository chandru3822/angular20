package com.albatross.api.v1.company.blueraven.models.birdeye;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.RandomStringUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.web.util.UriTemplate;

import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import static com.google.common.base.Preconditions.checkState;
import static org.apache.commons.lang3.StringUtils.isNotBlank;


@Service
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class BirdeyeService {
    @Value(value = "${birdeye.apiKey}")
    private String apiKey;

    @Value(value = "${birdeye.toplevelBusinessId}")
    private String toplevelBusinessId;

    @Value(value = "${birdeye.sendInvitesFoReals:false}")
    private Boolean sendInvitesFoReals;

    @Value(value = "${birdeye.serverDomain}")
    private Domain serverDomain;

    private final SqlCache sqlCache;
    private final ObjectMapper om;

    public List<BirdeyeLocation> getLocations() {
        checkState(isNotBlank(apiKey), "apiKey is missing. Perhaps the key is missing from Vault?");
        checkState(isNotBlank(toplevelBusinessId), "toplevelBusinessId is missing. Perhaps the value is missing from the config file?");

        try {
            URL url = getLocationsUrl(serverDomain, apiKey, toplevelBusinessId);
            HttpResponse resp = HttpUtils.call("GET", url,
                    ImmutableMap.of("Accept", "application/json"));
            if (resp.getResponseCode() == 200) {
                JSONArray json = resp.getJSONArray();
                return StreamSupport.stream(json.spliterator(), false)
                                    .map(o -> (JSONObject)o)
                                    .filter(l -> l.get("status").toString().equalsIgnoreCase("active"))
                                    .map(o -> new BirdeyeLocation(o.get("id").toString(),
                                                                  o.getString("alias")))
                                    .collect(Collectors.toList());
            } else {
                log.error("Encountered error while retrieving BirdEye locations: {}",
                        IOUtils.toString(resp.getErrorStream(), StandardCharsets.UTF_8));
                throw new Exception("Failed to retrieve locations from Birdeye");
            }
        } catch (Exception e) {
            log.error("Birdeye unavailable", e);
            throw new RuntimeException("Birdeye unavailable at this time.");
        }
    }

    public BirdeyeReviewInvitation sendInvitation(BirdeyeReviewInvitation invitation) {
        checkState(isNotBlank(apiKey), "apiKey is missing. Perhaps the key is missing from Vault?");
        checkState(isNotBlank(toplevelBusinessId), "toplevelBusinessId is missing. Perhaps the value is missing from the config file?");

        try {
            populateBusinessIdAndEmail(invitation);
            int invitationId = saveInvitation(invitation);

            URL url = getCheckInUrl(serverDomain, apiKey, invitation.getBirdeyeBusinessId());
            InputStream body = IOUtils.toInputStream(makeCheckInBody(invitation), StandardCharsets.UTF_8);
            String birdeyeCustomerId = null;

            if (sendInvitesFoReals) {
                log.info("Sending review invitation to customer on project {}", invitation.getProjectId());
                birdeyeCustomerId = sendInvitation(invitationId, url, body);
            }
            else {
                log.info("*Not* sending review invitation to customer on project {}; generating random Birdeye customerId for testing.",
                        invitation.getProjectId());
                birdeyeCustomerId = RandomStringUtils.randomAlphanumeric(16);
            }

            invitation.setBirdeyeCustomerId(birdeyeCustomerId);
            return invitation;
        } catch (Exception e) {
            log.error("Problem sending Birdeye review invitation", e);
            throw new RuntimeException("Problem sending Birdeye review invitation: " + e.getMessage());
        }
    }

    private String sendInvitation(int invitationId, URL url, InputStream body) throws Exception {
        HttpResponse resp = HttpUtils.call("POST", url,
                ImmutableMap.of("Accept", "application/json",
                                "Content-Type", "application/json"),
                body);
        if (resp.getResponseCode() == 200) {
            JSONObject json = resp.getJSON();
            String customerId = json.get("customerId").toString();
            saveBirdeyeCustomerId(invitationId, customerId);
            return customerId;
        } else {
            log.error("Encountered error while attempting to send BirdEye review invitation: {}",
                    IOUtils.toString(resp.getErrorStream()));
            throw new Exception("Failed to retrieve locations from Birdeye");
        }
    }

    public List<BirdeyeReview> getReviewsRaw(LocalDate reviewedStart) {
        checkState(isNotBlank(apiKey), "apiKey is missing. Perhaps the key is missing from Vault?");
        checkState(isNotBlank(toplevelBusinessId), "toplevelBusinessId is missing. Perhaps the value is missing from the config file?");

        try {
            URL url = getReviewsUrl(serverDomain, apiKey, toplevelBusinessId, reviewedStart);
            HttpResponse resp = HttpUtils.call("GET", url,
                    ImmutableMap.of("Accept", "application/json",
                            "Content-Type", "application/json"));
            if (resp.getResponseCode() == 200) {
                JsonNode root = om.readTree(resp.getBody());
                List<BirdeyeReview> reviews = new ArrayList<>();
                for (JsonNode review : root) {
                    BirdeyeReview r = om.treeToValue(review, BirdeyeReview.class);

                    // skip reviews that did not go through Birdeye
                    if(isNotBlank(r.getBirdeyeCustomerId()))
                        reviews.add(r);
                }
                return reviews;
            }

            log.error("Encountered error while attempting to send BirdEye review invitation: {}",
                    IOUtils.toString(resp.getErrorStream()));
            throw new Exception("Failed to retrieve locations from Birdeye");
        } catch (JsonProcessingException e) {
            log.error("Birdeye returned invalid JSON", e);
            throw new RuntimeException("Birdeye returned invalid data.");
        } catch (Exception e) {
            log.error("Birdeye unavailable", e);
            throw new RuntimeException("Birdeye unavailable at this time.");
        }
    }

    private int saveInvitation(BirdeyeReviewInvitation invitation) {
        String json = new JSONObject(invitation).toString();
        Map<String, Object> params = ImmutableMap.of("projectId", invitation.getProjectId(),
                                                     "birdeyeBusinessId", invitation.getBirdeyeBusinessId(),
                                                     "dateSent", OffsetDateTime.now(ZoneOffset.UTC),
                                                     "rawInvitation", json);
        return sqlCache.updateReturningId("birdeye.saveInvitation", params, "id").intValue();
    }

    private void populateBusinessIdAndEmail(BirdeyeReviewInvitation invitation) {
        Optional<String> businessId = sqlCache.get("birdeye.getBusinessId",
            ImmutableMap.of("projectId", invitation.getProjectId()),
            new SingleColumnRowMapper<>(String.class));

        if (businessId.isPresent()) {
            invitation.setBirdeyeBusinessId(businessId.get());
        }
        else {
            // TODO: comment out testing Business ID and throw error
            //throw new RuntimeException("No Birdeye Business ID found for this project.");
            invitation.setBirdeyeBusinessId("154083821523512");
        }

        Optional<String> email = sqlCache.get("birdeye.getEmail",
            ImmutableMap.of("projectId", invitation.getProjectId()),
            new SingleColumnRowMapper<>(String.class));

        if (email.isPresent()) {
            invitation.setRequestersEmails(Arrays.asList(email.get()));
        }
        else {
            invitation.setRequestersEmails(Arrays.asList("support@blueravensolar.com"));
        }
    }

    private void saveBirdeyeCustomerId(int invitationId, String custId) {
        Map<String, Object> params = ImmutableMap.of("id", invitationId,
                                                     "custId", custId);
        sqlCache.update("birdeye.addCustomerId", params);
    }

    private String makeCheckInBody(BirdeyeReviewInvitation invitation) {
        ArrayNode employeesArray = om.createArrayNode();
        for (String email : invitation.getRequestersEmails()) {
            ObjectNode employee = om.createObjectNode();
            employee.put("emailId", email);
            employeesArray.add(employee);
        }

        ObjectNode root = om.createObjectNode();
        root.put("name", invitation.getCustomerName());
        root.set("employees", employeesArray);

        if (invitation.getSendSms() != null && invitation.getSendSms()) {
            root.put("smsEnabled", 1);
            if (serverDomain == Domain.PROD)
                root.put("phone", invitation.getCustomerPhone());
            else // put dummy customer phone for non-prod testing
                root.put("phone", "385-269-9523");
        } else {
            root.put("smsEnabled", 0);
            if (serverDomain == Domain.PROD)
                root.put("emailId", invitation.getCustomerEmail());
            else // put dummy customer email for non-prod testing
                root.put("emailId", "blueraventest@gmail.com");
        }

        return root.toString();
    }


    static URL getLocationsUrl(Domain domain, String apiKey, String bid) throws MalformedURLException {
        return UriComponentsBuilder.fromPath(Resources.CHILD_BUSINESSNES.uriTemplate.toString())
                .host(domain.host)
                .scheme("https")
                .queryParam("api_key", apiKey)
                .queryParam("pid", bid)
                .build().toUri().toURL();
    }

    static URL getCheckInUrl(Domain domain, String apiKey, String bid) throws MalformedURLException {
        return UriComponentsBuilder.fromPath(Resources.CHECK_IN.uriTemplate.toString())
                .host(domain.host)
                .scheme("https")
                .queryParam("api_key", apiKey)
                .queryParam("bid", bid)
                .build().toUri().toURL();
    }

    static URL getReviewsUrl(Domain domain, String apiKey, String enterpriseBusinessId,
                             LocalDate reviewedStart) throws MalformedURLException {
        return getReviewsUrl(domain, apiKey, enterpriseBusinessId, reviewedStart, LocalDate.now());
    }

    static URL getReviewsUrl(Domain domain, String apiKey, String enterpriseBusinessId,
                             LocalDate reviewedStart, LocalDate reviewedEnd) throws MalformedURLException {
        Map<String, String> pathParams = ImmutableMap.of("businessId", enterpriseBusinessId);
        URI fragmentUri = Resources.REVIEWS.uriTemplate.expand(pathParams);
        DateTimeFormatter f = DateTimeFormatter.ofPattern("MM/dd/yyyy");

        return UriComponentsBuilder.fromUri(fragmentUri)
                .host(domain.host)
                .scheme("https")
                .queryParam("api_key", apiKey)
                .queryParam("fdate", reviewedStart.format(f))
                .build().toUri().toURL();
    }

    @RequiredArgsConstructor
    public static enum Domain {
        PROD("api.birdeye.com"),
        DEVO("private-anon-8e8990eaa7-birdeye.apiary-proxy.com"),
        MOCK("private-anon-8e8990eaa7-birdeye.apiary-mock.com");

        private final String host;
    }

    enum Resources {
        CHILD_BUSINESSNES("/resources/v1/business/child/all"),
        CHECK_IN         ("/resources/v1/customer/checkin"),
        REVIEWS          ("/resources/v1/review/businessid/{businessId}");

        private final UriTemplate uriTemplate;

        private Resources(String template) {
            uriTemplate = new UriTemplate(template);
        }
    }
}
