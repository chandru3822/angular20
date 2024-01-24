package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.Five9Query;
import com.albatross.api.v1.company.blueraven.services.queries.GenesysQuery;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.client.utils.URIBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;

import java.io.InputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class Five9Service {

  @Value(value = "${squeeze.api.host}")
  private String apiUrl;

  @Value(value = "${five9.api.token}")
  private String basicToken;

  private final SqlCache sqlCache;

  private final CustomFieldValueService customFieldValueService;
  private final GenesysService genesysService;

  private final SimpleDateFormat formatterDate = new SimpleDateFormat("yyyy-MM-dd");
  private final SimpleDateFormat formatterTime = new SimpleDateFormat("HH:mm:ss");

  private Boolean referralValueSet = false;
  private Boolean dncValueSet = false;

  public void handleContact(Long contactId, List<CustomFieldValue> values, boolean isUpdate, boolean isRetarget, Long leadLevel) {
    if (ObjectUtils.isEmpty(basicToken) || ObjectUtils.isEmpty(basicToken == null)) {
      return;
    }

    String url = "";
    String contactListName = "";
    try {
      GenesysService.CustomContact contact = genesysService.getContact(contactId, !false);
      String phone = contact.getPhone() != null ? contact.getPhone().replaceAll("[^0-9]", "") : "";
      if (phone.startsWith("1")) {
        phone = phone.substring(1);
      }

      URIBuilder b = new URIBuilder(apiUrl + "/AddToList");
      b.addParameter("F9domain", "BRSolar");
      b.addParameter("F9CallASAP", "true");
      b.addParameter("first_name", contact.getFirstName() != null ? contact.getFirstName() : "");
      b.addParameter("last_name", contact.getLastName() != null ? contact.getLastName() : "");
      b.addParameter("number1", phone);
      b.addParameter("id", contactId.toString());
      b.addParameter("contact_type_id", contact.getContactTypeId() != null ? contact.getContactTypeId().toString() : "");
      b.addParameter("street", contact.getStreet1() != null ? contact.getStreet1() : "");
      b.addParameter("city", contact.getCity() != null ? contact.getCity() : "");
      b.addParameter("state", contact.getState() != null ? contact.getState() : "");
      b.addParameter("zip", contact.getPostalCode() != null ? contact.getPostalCode() : "");
      b.addParameter("email", contact.getEmail() != null ? contact.getEmail() : "");

      getCfvValues(b, values);
      getAppointmentValues(contactId, b);

      // Only set the date/time created fields when Contact is created
      if (!isUpdate) {
        ZonedDateTime zonedDateTime = contact.getDateCreated().toInstant().atZone(ZoneId.of("US/Mountain"));
        b.addParameter("time_created_mst", formatterTime.format(Date.from(zonedDateTime.toInstant())));
        b.addParameter("date_created_mst", formatterDate.format(new Date()));

        if (!dncValueSet) {
          b.addParameter("DNC", "false");
        }

        if (!referralValueSet) {
          b.addParameter("referral", "false");
        }
      }

      if (leadLevel == 40L) {
        if (isRetarget) {
          contactListName = "digital_retarget";
        }
        else {
          contactListName = "digitalleads";
        }
      }
      else if (leadLevel >= 201L && leadLevel <= 209L) {
        if (isRetarget) {
          contactListName = "virtual_retarget";
        }
        else {
          contactListName = "virtualleads";
        }
      }
      b.addParameter("F9list", contactListName);

      url = b.build().toString().replaceAll("\\+", "%20");
      HttpResponse resp = POST(url, null);
      return;
    } catch (Exception e) {
      String msg = "FIVE9: Error in posting contactId="+ contactId + ", msg=" +e.getMessage() + ", url="+url;
      log.error(msg);
    }
  }

  private void getAppointmentValues(Long contactId, URIBuilder b) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    Optional<String> appointmentDate =
      sqlCache.getBySql(
        GenesysQuery.getContactAppointmentDate,
        params,
        new SingleColumnRowMapper<>(String.class));

    if (appointmentDate.isPresent()) {
      b.addParameter("appointment_date", appointmentDate.get());
    }
    else {
      b.addParameter("appointment_date", "");
    }

    Optional<String> appointmentOutcome =
      sqlCache.getBySql(
        GenesysQuery.getContactCloserAppointmentOutcome,
        params,
        new SingleColumnRowMapper<>(String.class));

    if (appointmentOutcome.isPresent()) {
      b.addParameter("appointment_outcome", appointmentOutcome.get());
    }
    else {
      b.addParameter("appointment_outcome", "");
    }

    Optional<String> pitchedDate =
      sqlCache.getBySql(
        Five9Query.getFirstAppointmentPitchedDate, params, new SingleColumnRowMapper<>(String.class));
    if (pitchedDate.isPresent()) {
      try {
        Date date = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(pitchedDate.get());
        b.addParameter("first_pitch_date", formatterDate.format(date));
      } catch (ParseException e) {
        log.warn("FIVE9: Invalid first appointment date format for contactId=" + contactId);
      }
    }

    Optional<String> bookingDate =
      sqlCache.getBySql(
        Five9Query.getBookingDate, params, new SingleColumnRowMapper<>(String.class));
    if (bookingDate.isPresent()) {
      b.addParameter("booking_date", bookingDate.get());
    }

    Optional<Boolean> retargetValue =
      sqlCache.getBySql(
        Five9Query.getRetargetValue, params, new SingleColumnRowMapper<>(Boolean.class));
    if (retargetValue.isPresent()) {
      b.addParameter("retarget", retargetValue.get().toString());
    }
    else {
      b.addParameter("retarget", "false");
    }
  }

  private void getCfvValues(URIBuilder b, List<CustomFieldValue> values) {
    for (CustomFieldValue cfv : values) {
      String value = "";
      if (cfv.getIntValue() != null) {
        // If Contact is from ContactLeadService, value for Lead Source & Lead Source Detail will be
        // in fieldValue
        if (cfv.getListOfValues() == null) {
          value = cfv.getFieldValue();
        } else {
          for (ListOfValue lov : cfv.getListOfValues()) {
            if (lov.getId().equals(cfv.getIntValue())) {
              value = lov.getName();
              break;
            }

          }
        }
      } else if (cfv.getIntArrayValue() != null && !cfv.getIntArrayValue().isEmpty()) {
        for (ListOfValue lov : cfv.getListOfValues()) {
          List<Integer> selectedValueIds = cfv.getIntArrayValue();
          if (selectedValueIds.contains(lov.getId().intValue())) {
            if (value.length() > 0) {
              value += ", ";
            }

            value += lov.getName();
          }
        }
      }

      if (cfv.getFieldName() != null) {
        if (cfv.getFieldName().equals("Lead Source")) {
          b.addParameter("lead_source", value);
        } else if (cfv.getFieldName().equals("Lead Source Detail")) {
          b.addParameter("lead_source_detail", value);
        } else if (cfv.getFieldName().equals("Lead Status")) {
          b.addParameter("lead_status", value);
        } else if (cfv.getFieldName().equals("Lead Level")) {
          b.addParameter("lead_level", cfv.getIntValue() == null ? "" : cfv.getIntValue().toString());
        } else if (cfv.getFieldName().equals("Referral")) {
          b.addParameter("referral", cfv.getBooleanValue() == null ? "false" : cfv.getBooleanValue().toString());
          referralValueSet = true;
        } else if (cfv.getFieldName().equals("Unqualified Reason")) {
          if (value.contains("Do Not Contact")) {
            b.addParameter("DNC", "true");
          }
          else {
            b.addParameter("DNC", "false");
          }
          dncValueSet = true;

          b.addParameter("unqualified_reason", value);
        } else if (cfv.getFieldName().equals("Lead Follow-up Date")) {
          b.addParameter("follow_up_date_time", cfv.getTimestampValue() == null ? "" : cfv.getTimestampValue().toString());
        }
      }
    }
  }

  public void processFive9Contacts() {
    // Get list of Contact IDs that need to be put into each Genesys Contact List
    List<Contact> contacts = sqlCache.queryBySql(Five9Query.getContactIdsSalDevRetargets, null, Contact.class);
    for (Contact contact : contacts) {
      List<CustomFieldGroup> customFieldGroups =
        customFieldValueService.getCustomFieldGroupsAndValues(
          ObjectType.CONTACT, contact.getId());
      List<CustomFieldValue> values = customFieldGroups.stream()
          .flatMap(group -> group.getCustomFieldValues().stream())
          .collect(Collectors.toList());

      try {
        final Long leadLevel = values.stream()
          .filter(cfv -> cfv.getFieldName() != null)
          .filter(cfv -> cfv.getFieldName().equals("Lead Level"))
          .map(CustomFieldValue::getIntValue)
          .findFirst()
          .orElse(null);

        handleContact(contact.getId(), values, false, true, leadLevel);
      } catch (Exception e) {
        log.error("FIVE9: Error during cron - adding contactId={}, msg={}", contact.getId(), e.getMessage());
      }
    }
  }

  private HttpResponse request(String method, String url, InputStream content) throws Exception {
    log.debug("FIVE9: sending to Five9 url: {}", url);
    Map<String, String> headers = new HashMap<>();

    headers.put("Authorization", "Basic %s".formatted(basicToken));
    return HttpUtils.call(method, url, headers, content);
  }

  private HttpResponse POST(String url, InputStream content) throws Exception {
    return request("POST", url, content);
  }
}
