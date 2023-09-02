package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.stripe.Stripe;
import com.stripe.model.LineItem;
import com.stripe.model.Price;
import com.stripe.model.Product;
import com.stripe.model.checkout.Session;
import com.stripe.exception.StripeException;
import com.stripe.param.checkout.SessionCreateParams;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class StripeService {

    @Value(value = "${stripe.api.token}")
    private String stripeApiToken;

    @Value(value = "${stripe.down.payment.product.key}")
    private String stripeDownPaymentProductKey;

    @Value(value = "${app.home_url}")
    private String frontEndHostUrl;

    private final SqlCache sqlCache;

    //language=PostgreSQL
    public final static String getDownPaymentAmount = """
        select (int_value * 100)::int
        from flow.project_process_step_event_custom_field_value ppsecfv
            inner join flow.project_process_step_event ppse on ppsecfv.project_process_step_event_id = ppse.id
            inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
            inner join flow.project p on pps.project_id = p.id
        where project_process_step_event_id = :ppsEventId
            and case when p.company_process_id = 20 then custom_field_group_assignment_id = 26154
            else custom_field_group_assignment_id = 26138 end
    """;

    public String chargeProject(Long projectId, Long ppsEventId) throws Exception {
        try {
            Stripe.apiKey = stripeApiToken;

            Map<String, Object> cfvParams = new HashMap<>();
            cfvParams.put("ppsEventId", ppsEventId);

            Optional<Long> downPaymentAmount = sqlCache.queryForObjectOptionalBySql(getDownPaymentAmount, cfvParams, Long.class);

            if(downPaymentAmount.isPresent() && downPaymentAmount.get() > 0) {
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

                //populate the session
                SessionCreateParams sessionParams = SessionCreateParams.builder()
                        .setSuccessUrl(frontEndHostUrl + "/stripeSuccess")
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
}
