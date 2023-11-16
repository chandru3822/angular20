package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.queries.customFieldValues.CustomFieldValueQuery;
import com.stripe.Stripe;
import com.stripe.model.checkout.Session;
import com.stripe.exception.StripeException;
import com.stripe.param.checkout.SessionCreateParams;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class StripeService {

    //this is BR's main stripe account
    @Value(value = "${stripe.api.token}")
    private String stripeApiToken;

    @Value(value = "${stripe.down.payment.product.key}")
    private String stripeDownPaymentProductKey;

    @Value(value = "${app.home_url}")
    private String frontEndHostUrl;

    private final SqlCache sqlCache;
    private final Environment environment;

    //language=PostgreSQL
    public final static String getDownPaymentAmount = """
                select (int_value * 100)::int
                from flow.project_process_step_custom_field_value ppscfv
                         inner join flow.project_process_step pps on ppscfv.project_process_step_id = pps.id
                         inner join flow.project p on pps.project_id = p.id
                where pps.id = :ppsId
                  and case when p.company_process_id = 20 then custom_field_group_assignment_id = 26157
                           when p.company_process_id = 18 then custom_field_group_assignment_id = 26158
                           else custom_field_group_assignment_id = 26156 end
            """;

    public String chargeProject(Long projectId, Long ppsId) throws Exception {
        try {
            Stripe.apiKey = stripeApiToken;

            Map<String, Object> cfvParams = new HashMap<>();
            cfvParams.put("ppsId", ppsId);

            Optional<Long> downPaymentAmount = sqlCache.queryForObjectOptionalBySql(getDownPaymentAmount, cfvParams, Long.class);

            if (downPaymentAmount.isPresent() && downPaymentAmount.get() > 0) {
                Map<String, String> metadataMap = new HashMap<>();
                metadataMap.put("project_id", projectId.toString());

                //create the price data
                SessionCreateParams.LineItem.PriceData priceData = SessionCreateParams.LineItem.PriceData.builder()
                        .setCurrency("usd")
                        .setProduct(stripeDownPaymentProductKey)
                        .setUnitAmount(downPaymentAmount.get())
                        .build();

                //create the line item
                SessionCreateParams.LineItem lineItem = SessionCreateParams.LineItem.builder()
                        .setPriceData(priceData)
                        .setQuantity(1L)
                        .build();

                //add metadata to payment intent, shows in different section in Stripe
                SessionCreateParams.PaymentIntentData paymentIntentData = SessionCreateParams.PaymentIntentData.builder()
                        .putAllMetadata(metadataMap)
                        .build();

                //set success url
                String successUrl = frontEndHostUrl + "/stripeSuccess?projectId=" + projectId + "&sessionId={CHECKOUT_SESSION_ID}";

                //populate the session
                SessionCreateParams sessionParams = SessionCreateParams.builder()
                        .setSuccessUrl(successUrl)
                        .addLineItem(lineItem)
                        .addPaymentMethodType(SessionCreateParams.PaymentMethodType.CARD)
                        .setMode(SessionCreateParams.Mode.PAYMENT)
                        .putAllMetadata(metadataMap)
                        .setPaymentIntentData(paymentIntentData)
                        .build();

                //create the session
                Session sessionSdk = Session.create(sessionParams);
                String url = sessionSdk.getUrl();

                return url;
            } else {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No Down Payment Amount Found.");
            }
        } catch (StripeException e) {
            e.printStackTrace();
        }

        return null;
    }

    public void setStripePaymentId(String stripeSessionId, Long projectId) {
        //the checkout success page can only return the session id.
        //with that id we need to get the payment id then set that in a custom field on the project (pps?)
        try {
            Stripe.apiKey = stripeApiToken;

            Session session = Session.retrieve(stripeSessionId);
            if (null != session.getPaymentIntent() && null != projectId) {
                //if there is a payment id then save it to the process step it came from
                final Map<String, Object> params = Map.of("projectId", projectId, "userId", 99999999,
                        "cfgaId", 26191, "value", session.getPaymentIntent());
                sqlCache.queryBySql(CustomFieldValueQuery.updateValueUsingFunction, params, String.class);
            }
        } catch (StripeException e) {
            e.printStackTrace();
        }
    }

    public Map<String, String> createEmbeddedCheckoutSession(String partnerKeyPrefix, String customerEmail) {
        try {
            String stripeApiKey = environment.getProperty(partnerKeyPrefix + ".stripe.api.token");
            String priceKey = environment.getProperty(partnerKeyPrefix + ".stripe.down.payment.price.key");;

            if(stripeApiKey != null && priceKey != null) {

                Stripe.apiKey = stripeApiKey;
                
                SessionCreateParams params =
                        SessionCreateParams.builder()
                                .setUiMode(SessionCreateParams.UiMode.EMBEDDED)
                                .setMode(SessionCreateParams.Mode.PAYMENT)
                                .setReturnUrl(frontEndHostUrl + "/success?session_id={CHECKOUT_SESSION_ID}")
                                .setCustomerEmail(customerEmail) //this is ok to be null
//                                .setAutomaticTax(
//                                        SessionCreateParams.AutomaticTax.builder()
//                                                .setEnabled(true)
//                                                .build())
                                .addLineItem(
                                        SessionCreateParams.LineItem.builder()
                                                .setQuantity(1L)
                                                // Provide the exact Price ID (for example, pr_1234) of the product you want to sell
                                                .setPrice(priceKey)
                                                .build())
                                .build();

                Session session = Session.create(params);

                Map<String, String> map = new HashMap();
                map.put("clientSecret", session.getRawJsonObject().getAsJsonPrimitive("client_secret").getAsString());

                return map;
            } else {
                throw new ResponseStatusException(
                        HttpStatus.NOT_ACCEPTABLE, "STRIPE: Invalid Request", new Exception());
            }

        } catch (StripeException ex) {
            throw new RuntimeException("Stripe Failed: {}", ex);
        }
    }

}
