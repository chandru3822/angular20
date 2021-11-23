package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.config.PandaDocConfiguration;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.PandaDocProjectDetails;
import com.albatross.api.v1.company.blueraven.repository.InstallAgreementRepository;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.TemplatingEngineService;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Slf4j
@Service
public class PandaDocService {
  @Autowired
  private PandaDocConfiguration pandaDoc;

  @Autowired
  private SqlCache sqlCache;

  @Autowired
  private NamedParameterJdbcTemplate jdbc;

  @Autowired
  private SecurityService securityService;

  @Autowired
  private TemplatingEngineService templateService;

  @Autowired
  @Lazy
  private InstallAgreementRepository installAgreementRepository;

  /**
   * Get the necessary information about a project to determine which PandaDoc
   * template to use when generating the document.
   *
   * @param projectId
   * @param proposalNbr
   * @return
   */
  private PandaDocProjectDetails getProjectDetails(Long projectId, Long proposalNbr) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);

    Optional<PandaDocProjectDetails> obj = sqlCache.get(
      "pandaDoc.getProjectDetails",
      params,
      PandaDocProjectDetails.class
    );

    return obj.get();
  }

  /**
   * Determine the ID of the PandaDoc template that will be used when
   * generating the document. Supports falling back to a generic template.
   *
   * @param deets
   * @param isSpanish
   * @return
   * @throws Exception
   */
  private String findTemplateId(PandaDocProjectDetails deets, Boolean isSpanish) throws Exception {
    String name = deets.getTemplateName(isSpanish, pandaDoc.getGenericName());
    String tplId = findTemplateIdByName(name);

    log.debug("PANDADOC: Template Name we are looking for: name={}, found templateId=", name, tplId);
    // attempt to find a generic template for the state and financier
    if (tplId == null) {
      log.warn("PANDADOC: falling back to generic utility company");
      deets.setUtilityCompany(pandaDoc.getGenericName());
      name = deets.getTemplateName(isSpanish, pandaDoc.getGenericName());
      tplId = findTemplateIdByName(name);
    }

    // if we're still not finding a match, abort
    if (tplId == null) {
      String err = String.format("no PandaDoc template matching '%s'", name);
      throw new Exception(err);
    }

    return tplId;
  }

  /**
   * Determine the ID of the PandaDoc template that will be used when
   * generating the document, based on the name of the template.
   *
   * @param name
   * @return
   * @throws Exception
   */
  private String findTemplateIdByName(String name) throws Exception {
    log.debug("PANDADOC: looking for template name='{}'", name);
    String tplId = null;
    String url = "/templates?q=" + URLEncoder.encode(name, "UTF-8");
    HttpResponse resp = GET(url);
    JSONObject out = resp.getJSON();

    JSONArray templates = out.getJSONArray("results");
    if (templates.length() > 0) {
      log.warn("PANDADOC: found multiple templates matching tag={}: {}", name, templates);
      for (int i = 0; i < templates.length(); i++) {
        JSONObject tpl = templates.getJSONObject(i);
        String tplName = tpl.getString("name");
        String version = tpl.getString("version");
        if (name.equals(tplName) && version.equals("2")) {
          tplId = tpl.getString("id");
          log.debug("PANDADOC: selected template named {}", tplName);
          break;
        }
      }
    }

    return tplId;
  }

  public JSONArray findTemplatesByName(String name) throws Exception {
    log.debug("PANDADOC: looking for template name='{}'", name);
    String url = "/templates?q=" + URLEncoder.encode(name, "UTF-8");
    HttpResponse resp = GET(url);
    JSONObject out = resp.getJSON();
    return out.getJSONArray("results");
  }

  /**
   * Retrieve the details about the specified PandaDoc template.
   *
   * @param templateId
   * @return
   * @throws Exception
   */
  private JSONObject getTemplateDetails(String templateId) throws Exception {
    HttpResponse resp = GET("/templates/" + templateId + "/details");
    return resp.getJSON();
  }

  /**
   * Create a new document in PandaDoc using a specific template.
   *
   * @param projectId
   * @param proposalNbr
   * @param isSpanish
   * @return
   * @throws Exception
   */
  public String createDocument(Long projectId, Long proposalNbr, Boolean isSpanish) throws Exception {
    PandaDocProjectDetails deets = getProjectDetails(projectId, proposalNbr);
    deets.setFinancier(installAgreementRepository.getFinancierFromProposalLog(projectId, proposalNbr));
    deets.setUtilityCompany(installAgreementRepository.getUtilityFromProposalLog(projectId, proposalNbr));

    String templateId = findTemplateId(deets, isSpanish);
    if (!pandaDoc.getEnabled()) {
      log.warn("PANDADOC: not creating document: pandadoc service is disabled");
      return "";
    }

    log.debug("PANDADOC: creating document for project {} using template {}", projectId, templateId);
    JSONObject template = getTemplateDetails(templateId);
    log.debug("PANDADOC: template: {}", template);

    List<String> templateFields = getExpectedFields(template);
    JSONObject tokens = getProjectTokens(deets);

    // validate fields
    try {
      validate(projectId, deets.getFinancier(), tokens);
    } catch (Exception ex) {
      log.warn("PANDADOC: validation failed: {}", ex.getMessage());
      throw ex;
    }

    JSONObject body = getDocumentBody(templateId, templateFields, tokens);
    body = setRecipientInfo(body, deets);

    log.debug("PANDADOC_BODY: {}", body.toString());

    HttpResponse resp = POST("/documents", body.toString());
    JSONObject respBody = resp.getJSON();

    // le sigh... takes a bit on PandaDoc's end for the doc to be available for sending
    String documentId = respBody.getString("id");
    log.debug("PANDADOC: created document id={} projectId={} templateId={}",
      documentId, projectId, templateId);
    delayedSendDocument(projectId, documentId, tokens);

    // Set as request sent

    return respBody.toString();
  }

  public String generateElectronicDocument (Long projectId, String templateId) throws Exception {
    log.debug("PANDADOC: creating document for project {} using template {}", projectId, templateId);
    JSONObject template = getTemplateDetails(templateId);
    log.debug("PANDADOC: template: {}", template);

    List<String> templateFields = getExpectedFields(template);
    JSONObject tokens = getProjectTokens(projectId);
    JSONObject body = getDocumentBody(templateId, templateFields, tokens);

    setRecipientInfoElecDocs(template, tokens, body);
    HttpResponse resp = POST("/documents", body.toString());
    JSONObject respBody = resp.getJSON();
    return String.format("https://app.pandadoc.com/a/#/document/v1/editor/%s/widgets", respBody.get("id"));
  }

  /**
   * Validate the project.
   *
   * @param projectId
   * @param financier
   * @param tokens
   * @throws Exception
   */
  public void validate(Long projectId, String financier, JSONObject tokens) throws Exception {
    if (installAgreementRepository.isCashProject(financier)) {
      validateCashProject(projectId, tokens);
    } else if (installAgreementRepository.isLoanPalProject(financier)) {
      validateLoanPalProject(projectId, tokens);
    } else if (!installAgreementRepository.isSunlightProject(financier)) {
      throw new Exception(String.format(
        "unexpected financier for project %d: %s",
          projectId, financier
      ));
    }
  }

  /**
   * Validate a cash project.
   *
   * @param projectId
   * @param tokens
   * @throws Exception
   */
  public void validateCashProject(Long projectId, JSONObject tokens) throws Exception {
    log.debug("PANDADOC: validating cash project {}", projectId);
    validateFields(tokens,
      "Deal.Total Cash Down Payment",
      "Deal.System Size",
      "Deal.First Cash Payment Amount");
  }

  /**
   * Validate a LoanPal project.
   *
   * @param projectId
   * @param tokens
   * @throws Exception
   */
  public void validateLoanPalProject(Long projectId, JSONObject tokens) throws Exception {
    log.debug("PANDADOC: validating loanpal project {}", projectId);
    validateFields(tokens, "Deal.Total System Price");
  }

  /**
   * Check that all of the specified fields are non-null and greater than zero.
   *
   * @param tokens
   * @param keys
   * @throws Exception
   */
  public void validateFields(JSONObject tokens, String... keys) throws Exception {
    List<String> errors = new ArrayList<>();

    for (String key : keys) {
      errors.addAll(isNonNullNonZero(key, tokens));
    }

    if (!errors.isEmpty()) {
      String errs = errors.stream()
        .collect(Collectors.joining("; "));
      throw new Exception("Project validation failed: " + errs);
    }
  }

  /**
   * Check to see whether the specified key is non-null and greater than zero.
   *
   * @param key
   * @param tokens
   * @return
   */
  public List<String> isNonNullNonZero(String key, JSONObject tokens) {
    List<String> errors = new ArrayList<>();

    try {
      Double value = tokens.getDouble(key);
      log.debug("PANDADOC: field {}: {}", key, value);
      if (value == null) {
        errors.add(String.format("%s is undefined", key));
      } else if (value.doubleValue() <= 0) {
        errors.add(String.format("%s must be greater than 0", key));
      }
    } catch (JSONException ex) {
      Object obj = tokens.opt(key);
      errors.add(String.format("%s is an invalid field ({})", key, obj));
    }

    return errors;
  }

  /**
   * Get information about the document recipients.
   *
   * @param body
   * @param deets
   * @return
   * @throws JSONException
   */
  public JSONObject setRecipientInfo(JSONObject body, PandaDocProjectDetails deets) throws JSONException {
    User user = securityService.getCurrentUser();
    JSONObject customer = deets.getCustomerInfo(pandaDoc.getCustomerRole());
    JSONObject brs = deets.getBlueRavenInfo(pandaDoc.getSupportRole());

    if (isBlank(deets.getCloserEmail())) {
        deets.setCloserEmail(user.getEmail());
        deets.setCloserFirstName(user.getFirstName());
        deets.setCloserLastName(user.getLastName());
    }

    JSONObject closer = deets.getCloserInfo(pandaDoc.getCloserRole());

    // allow the recipient email addresses to be overridden FOR TESTING
    String email = pandaDoc.getNotificationEmail();
    if (!isBlank(email)) {
      customer.put("email", deets.getCustomerEmail());
      brs.put("email", "support@blueravensolar.com");
      closer.put("email",deets.getCloserEmail());
    }

    body.append("recipients", customer);
    body.append("recipients", brs);
    body.append("recipients", closer);

    return body;
  }

  private void setRecipientInfoElecDocs(JSONObject template, JSONObject tokens, JSONObject body) {
    JSONArray roles = template.getJSONArray("roles");
    boolean hasCustomerRole = false;
    boolean hasBRSRole = false;

    if (!roles.isEmpty()) {
        for (int i = 0; i < roles.length(); i++) {
            JSONObject role = roles.getJSONObject(i);
            if (role.get("name").equals("Customer")) {
                hasCustomerRole = true;
            }
            else if (role.get("name").equals("Blue Raven Solar")) {
                hasBRSRole = true;
            }
        }
    }

    /*
    **  Support role is no longer used, leaving here in case needed in the future **
    JSONObject brs = new JSONObject();
    User user = securityService.getCurrentUser();
    brs.put("first_name", user.getFirstName());
    brs.put("last_name", user.getLastName());
    brs.put("email", user.getEmail());
    if (hasBRSRole) {
        brs.put("role", pandaDoc.getSupportRole());
    }
    body.append("recipients", brs);
    * */

    JSONObject customer = new JSONObject();
    customer.put("first_name", tokens.get("Deal.Contact.FirstName"));
    customer.put("last_name", tokens.get("Deal.Contact.LastName"));
    customer.put("email", tokens.isNull("Deal.Contact.Email") ? "jberns03@gmail.com" : tokens.get("Deal.Contact.Email"));
    if (hasCustomerRole) {
        customer.put("role", pandaDoc.getCustomerRole());
    }
    body.append("recipients", customer);
  }

  /**
   * Pull together all of the different bits of information required to
   * create a new PandaDoc document.
   *
   * @param templateId
   * @param templateFields
   * @param tokens
   * @return
   * @throws JSONException
   */
  public JSONObject getDocumentBody(String templateId, List<String> templateFields, JSONObject tokens) throws JSONException {
    JSONObject body = new JSONObject();
    JSONObject fields = new JSONObject();

    body.put("name", joinIfPresent(
      " ",
      pandaDoc.getDocumentPrefix(),
      tokens.getString("Deal.Contact.Name"),
      tokens.optString("Deal.Proposal Number"),
      "Installation Agreement"
    ));
    body.put("template_uuid", templateId);

    // organize tokens and fields the way PandaDoc requires
    Iterator<String> keys = tokens.keys();
    for (Iterator<String> it = keys; it.hasNext(); ) {
      String key = it.next();
      JSONObject token = new JSONObject();
      token.put("name", key);
      token.put("value", tokens.get(key));
      body.append("tokens", token);

      // PandaDoc will only allow fields that are actually used in the
      // template, so we must filter out everything else
      if (!templateFields.contains(key)) {
        log.debug("PANDADOC: skipping field {}", key);
        continue;
      }

      JSONObject field = new JSONObject();
      field.put("value", tokens.get(key));
      fields.put(key, field);
    }

    body.put("fields", fields);
    log.debug("PANDADOC: body {}", body);

    return body;
  }


  /**
   * Render and return the notification that will be sent to the customer
   * through PandaDoc.
   *
   * @param tokens
   * @return
   * @throws Exception
   */
  private String getNotification(JSONObject tokens) throws Exception {
    String template = loadEmailTemplate();

    HashMap<String, Object> ctx = new HashMap<>();
    ctx.put("customerFirstName", tokens.getString("Deal.Name").split(" ")[0]);

    return templateService.renderFreemarkerTemplate(template, ctx);
  }

  /**
   * Retrieve the template for the document notification that PandaDoc will
   * send.
   *
   * @return
   * @throws IOException
   */
  private String loadEmailTemplate() throws IOException {
    try (InputStream in = PandaDocService.class.getResourceAsStream("/communication/templates/pandadoc-email.ftl.txt")) {
      return new Scanner(in, "UTF-8").useDelimiter("\\A").next();
    }
  }

  /**
   * Queue up a task to send the customer the specified PandaDoc after a
   * configurable amount of time. PandaDoc documents are not available
   * for sending immediately after sending the request to create them,
   * so we need a bit of a delay.
   *
   * @param projectId
   * @param documentId
   * @param tokens
   */
  public void delayedSendDocument(Long projectId, String documentId, JSONObject tokens) {
    if (!pandaDoc.getNotificationEnabled()) {
      log.warn("PANDADOC: not sending document {}: notification disabled", documentId);
      return;
    }

    new Timer().schedule(
      new TimerTask() {
        @Override
        public void run() {
          try {
            sendDocument(projectId, documentId, tokens);
          } catch (Exception ex) {
            log.error("PANDADOC: failed to send document: {}", ex.getMessage());
            ex.printStackTrace();
          }
        }
      },
      pandaDoc.getNotificationDelay()
    );
  }

  /**
   * Issue the request to send a customer the specified PandaDoc document.
   *
   * @param projectId
   * @param documentId
   * @param tokens
   * @return
   * @throws Exception
   */
  public String sendDocument(Long projectId, String documentId, JSONObject tokens) throws Exception {
    log.debug("PANDADOC: sending projectId {} document {}", projectId, documentId);
    JSONObject body = new JSONObject();
    body.put("message", getNotification(tokens));

    HttpResponse resp = POST("/documents/" + documentId + "/send", body.toString());
    String respBody = resp.getBody();
    log.debug("PANDADOC: document sent for projectId {}: {}", projectId, respBody);

    return respBody;
  }

  /**
   * Inspect the PandaDoc template details to determine which fields are
   * permitted in the call to create a document from said template.
   *
   * @param template
   * @return
   * @throws JSONException
   */
  private List<String> getExpectedFields(JSONObject template) throws JSONException {
    JSONArray fields = template.getJSONArray("fields");
    List<String> fieldNames = new ArrayList<>();

    for (int i = 0; i < fields.length(); i++) {
      JSONObject field = fields.getJSONObject(i);
      fieldNames.add(field.getString("name"));
    }

    return fieldNames;
  }

  /**
   * Collect data about a project that will be useful in populating a PandaDoc
   * document.
   *
   * @param deets
   * @return
   * @throws JSONException
   */
  public JSONObject getProjectTokens(PandaDocProjectDetails deets) throws JSONException {
    JSONObject tokens = new JSONObject();

    try {
        MapSqlParameterSource parameters = new MapSqlParameterSource();
        parameters.addValue("projectId", deets.getProjectId().intValue());
        parameters.addValue("proposalNumber", deets.getProposalNbr().intValue());
        String sql = "SELECT to_json(get_data_from_proposal) FROM brs.get_data_from_proposal(:projectId, :proposalNumber)";
        Map<String, Object> result = jdbc.queryForObject(sql, parameters, new ColumnMapRowMapper());
        result = new Gson().fromJson(result.get("to_json").toString(), new TypeToken<Map<String, Object>>() {
        }.getType());

        tokens.put("Deal.1st Year Production Estimate (kWh)", result.get("custom_fields.1st Year Production Estimate (kWh)"));
        tokens.put("Deal.Estimated ITC", result.get("custom_fields.Estimated ITC"));
        tokens.put("Deal.Estimated State Tax Credit", result.get("custom_fields.Estimated State Tax Credit"));
        tokens.put("Deal.Referral Promotion Amount", result.get("custom_fields.Referral Promotion Amount"));
        tokens.put("Deal.Panel Brand", result.get("custom_fields.Panel Brand"));
        tokens.put("Deal.Inverter Brand", result.get("custom_fields.Inverter Brand"));
        tokens.put("Deal.Notice of Cancellation Deadline", result.get("custom_fields.Notice of Cancellation Deadline"));
        tokens.put("Deal.Total Cash Down Payment", result.get("custom_fields.Total Cash Down Payment"));
        tokens.put("Deal.System Size", result.get("custom_fields.System Size"));
        tokens.put("Deal.First Cash Payment Amount", result.get("custom_fields.First Cash Payment Amount"));

        Double totalCost = Double.parseDouble(result.get("custom_fields.Total Cost") == null ? "0" : result.get("custom_fields.Total Cost").toString());
        Double referralPromotionAmount = Double.parseDouble(result.get("custom_fields.Referral Promotion Amount") == null ? "0" : result.get("custom_fields.Referral Promotion Amount").toString());
        tokens.put("Deal.Total System Price", totalCost - referralPromotionAmount);
    } catch (EmptyResultDataAccessException e) {
        log.warn("PANDADOC Error getting proposal log values: {}", e.getMessage());
        e.printStackTrace();
    }

    tokens.put("Deal.Id", deets.getProjectId());
    tokens.put("Deal.Name", deets.getProjectName());
    tokens.put("Deal.Contact.Address", getContactAddress(deets));
    tokens.put("Deal.Contact.Name", deets.getCustomerFirstName() + " " + deets.getCustomerLastName());
    tokens.put("Deal.Contact.Email", deets.getCustomerEmail());

    // use the customer's mobile phone if their landline is not present
    tokens.put("Deal.Contact.MobilePhone", deets.getPhone());

    // make bits of the customer's address usable individually
    tokens.put("Deal.Address.State", deets.getState());
    String street = joinIfPresent(" ",
        deets.getMailingStreet1(),
        deets.getMailingStreet2());
    tokens.put("Deal.Address.Street", street);
    tokens.put("Deal.Address.City", deets.getCity());
    tokens.put("Deal.Address.StateAbbr", deets.getMailingState());
    tokens.put("Deal.Address.PostalCode", deets.getPostalCode());

    if (!tokens.has("Deal.Proposal Number")) {
      tokens.put("Deal.Proposal Number", deets.getProposalNbr());
    }

    // include the current date for use in the template
    String today = ZonedDateTime.now(ZoneId.of("US/Mountain"))
      .format(DateTimeFormatter.ofPattern("MM/dd/yyyy"));
    tokens.put("Date", today);

    return tokens;
  }

  /**
   * Collect data about a project that will be useful in populating a PandaDoc for Electronic Documents
   * document.
   *
   * @param projectId
   * @return
   * @throws JSONException
   */
  public JSONObject getProjectTokens(Long projectId) throws JSONException {
    JSONObject tokens = new JSONObject();

    try {
        MapSqlParameterSource parameters = new MapSqlParameterSource();
        parameters.addValue("projectId", projectId);
        Map<String, Object> result = jdbc.queryForObject(sqlCache.getByKey("electronicDocument.getProjectsDetails"), parameters, new ColumnMapRowMapper());

        tokens.put("Deal.Id", result.get("id"));
        tokens.put("Deal.Name", result.get("project_name"));
        tokens.put("Deal.Contact.Address", joinIfPresent(", ",
            result.get("street1"),
            result.get("street2"),
            result.get("city"),
            result.get("state"),
            result.get("postal_code")));
        tokens.put("Deal.Contact.FirstName", result.get("first_name"));
        tokens.put("Deal.Contact.LastName", result.get("last_name"));
        tokens.put("Deal.Contact.Name", result.get("first_name") + " " + result.get("last_name"));
        tokens.put("Deal.Contact.Email", result.get("email"));

        // use the customer's mobile phone if their landline is not present
        tokens.put("Deal.Contact.MobilePhone", result.get("phone"));
        tokens.put("Deal.Contact.Phone", result.get("phone"));

        // make bits of the customer's address usable individually
        tokens.put("Deal.Address.State", result.get("state"));
        String street = joinIfPresent(" ",
            result.get("street1"),
            result.get("street2"));
        tokens.put("Deal.Address.Street", street);
        tokens.put("Deal.Address.City", result.get("city"));
        tokens.put("Deal.Address.StateAbbr", result.get("abbreviation"));
        tokens.put("Deal.Address.PostalCode", result.get("postal_code"));
        tokens.put("Deal.1st Year Production Estimate (kWh)", result.get("year_1_kwh_output"));
        tokens.put("Deal.Referral Promotion Amount", result.get("referral_promotion_amount"));
        tokens.put("Deal.Total Cash Down Payment", result.get("total_cash_down_payment"));
        tokens.put("Deal.System Size", result.get("system_size"));

        Double totalSystemPrice = Double.parseDouble(result.get("total_system_price") == null ? "0" : result.get("total_system_price").toString());
        Double referralPromotionAmount = Double.parseDouble(result.get("referral_promotion_amount") == null ? "0" : result.get("referral_promotion_amount").toString());
        tokens.put("Deal.Total System Price", totalSystemPrice - referralPromotionAmount);
        tokens.put("Deal.Installation Agreement Signed", result.get("installation_agreement_signed_date"));

        // include the current date for use in the template
        String today = ZonedDateTime.now(ZoneId.of("US/Mountain"))
            .format(DateTimeFormatter.ofPattern("MM/dd/yyyy"));
        tokens.put("Date", today);

    } catch (EmptyResultDataAccessException e) {
        log.warn("PANDADOC Error getting proposal log values: {}", e.getMessage());
        e.printStackTrace();
    }

    return tokens;
  }

  /**
   * Put available information about the customer's address on a single line.
   *
   * @param deets
   * @return
   */
  private String getContactAddress(PandaDocProjectDetails deets) {
    return joinIfPresent(", ",
      deets.getMailingStreet1(),
      deets.getMailingStreet2(),
      deets.getCity(),
      deets.getState(),
      deets.getPostalCode());
  }

  /**
   * Join the stringified objects together using the specified separator,
   * but only for stringified objects that are not "blank"
   *
   * @param sep
   * @param args
   * @return
   */
  private String joinIfPresent(String sep, Object... args) {
    return Stream.of(args)
      .filter(s -> !isBlank(s))
      .map(s -> s.toString())
      .collect(Collectors.joining(sep))
      .trim();
  }

  /**
   * Determine whether the specified object appears to have a "blank" string
   * value. Blank meaning null, empty, or the string "null".
   *
   * @param value
   * @return
   */
  private Boolean isBlank(Object value) {
    if (value == null) {
      return true;
    }

    String strValue = value.toString();
    return strValue.isEmpty() || strValue.equals("null");
  }

  private HttpResponse GET(String url) throws Exception {
    return request("GET", url, null);
  }

  private HttpResponse POST(String url, String body) throws Exception {
    return request("POST", url, IOUtils.toInputStream(body, "UTF-8"));
  }

  private Boolean isErrorCode(Integer code) {
    return code >= 400;
  }

  private HttpResponse request(String method, String url, InputStream body) throws Exception {
    Map<String, String> headers = new HashMap<>();
    headers.put("Authorization", String.format("Bearer %s", pandaDoc.getAccessToken()));
    headers.put("Content-Type", "application/json");

    url = "https://api.pandadoc.com/public/v1" + url;
    HttpResponse resp = HttpUtils.call(method, url, headers, body);
    if (isErrorCode(resp.getResponseCode())) {
      log.warn("PANDADOC: error fetching url {}", url);
      log.warn("PANDADOC: unexpected response code: {}", resp.getResponseCode());

      String error = "Unknown 500 Error";
      if(resp.getResponseCode() != 500) {
        JSONObject respBody = resp.getJSON();
        error = respBody.toString();
      }

      log.warn("PANDADOC: {}", error);
      throw new Exception(error);
    }

    return resp;
  }
}
