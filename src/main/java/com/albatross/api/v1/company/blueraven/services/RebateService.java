package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.RebateBatchDetail;
import com.albatross.api.v1.company.blueraven.models.RebatePayment;
import com.albatross.api.v1.company.blueraven.models.RebatePaymentState;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * Created by John Berns on 2020-04-21.
 */
@Service
public class RebateService {
  @Autowired
  private SqlCache sqlCache;

  @Autowired
  private SecurityService securityService;

  @Autowired
  private NamedParameterJdbcTemplate jdbc;

  @Autowired
  CustomFieldValueService customFieldValueService;

  @Autowired
  ObjectMapper om;

  public List<RebatePayment> getPending() {
    return sqlCache.query("rebate.getPaymentsPending", new HashMap<>(), RebatePayment.class);
  }

  public List<RebatePayment> getUnbalancedPayments() {
    return sqlCache.query("rebate.getPaymentsUnbalanced", new HashMap<>(), RebatePayment.class);
  }

  public List<RebatePayment> getNeedsApproval() {
    return sqlCache.query("rebate.getPaymentsNeedApproval", new HashMap<>(), RebatePayment.class);
  }

  public String getRebateDetails(Long projectId) {
    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("projectId", projectId.intValue());

    return jdbc.queryForObject(sqlCache.getByKey("rebate.getRebateDetails"), parameters, String.class);
  }

  public Optional<RebateBatchDetail> getBatchDetails(Long batchId){
    HashMap<String, Object> params = new HashMap<>();
    params.put("batchId", batchId);

    return sqlCache.get("rebate.getBatchDetails", params, new RebateMapper<>(RebateBatchDetail.class, om));
  }

  public List<RebateBatchDetail> getAllBatches(){
    return sqlCache.query("rebate.getAllBatches", Collections.emptyMap(), RebateBatchDetail.class);
  }

  public Optional<RebateBatchDetail> voidBatch(Long batchId){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("batchId", batchId);
    params.put("userId", currentUser.getId());

    //set the batch as void
    sqlCache.update("rebate.voidBatch", params);

    //clear the batch id from related payments and reset status to needs approval
    sqlCache.update("rebate.voidBatchPayments", params);

    return getBatchDetails(batchId);
  }

  public void voidSinglePayment(RebatePayment rebatePayment){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("paymentId", rebatePayment.getPaymentId());
    params.put("userId", currentUser.getId());
    params.put("note", rebatePayment.getVoidNote());

    //set the payment as void
    sqlCache.update("rebate.voidSinglePayment", params);
  }

  public void updatePaymentNote(RebatePayment rebatePayment){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("paymentId", rebatePayment.getPaymentId());
    params.put("userId", currentUser.getId());
    params.put("note", rebatePayment.getVoidNote());

    sqlCache.update("rebate.updatePaymentNote", params);
  }

  public List<RebatePaymentState> getPaymentStates(){
    List<RebatePaymentState> results = sqlCache.query("rebate.getPaymentStates", Collections.emptyMap(), RebatePaymentState.class);
    return results;
  }

  public void createRecurringPayment(RebatePayment rebatePayment){
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", rebatePayment.getProjectId());

    Calendar calendar = Calendar.getInstance();
    java.util.Date now = calendar.getTime();
    java.sql.Timestamp currentTimestamp = new java.sql.Timestamp(now.getTime());

    params.put("dateValue", currentTimestamp);
    sqlCache.update("rebate.updateEnteredIntoSystemDate", params);

    String sqlQuery = "select brs.create_rebate_payments(:projectId::integer, :createdById::integer, :totalAmount::numeric , :promotionPayments::integer)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("projectId", rebatePayment.getProjectId());
    parameters.addValue("createdById", currentUser.getId());
    parameters.addValue("totalAmount", rebatePayment.getTotalPromotionAmount());
    parameters.addValue("promotionPayments", rebatePayment.getNumberOfPromotionPayments());

    jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public void addExtraPayment(RebatePayment rebatePayment){

    User currentUser = securityService.getCurrentUser();

    String sqlQuery = "select brs.project_rebate_payments_add_extra_payment(:projectId::integer, :userId::integer, :paymentAmount::NUMERIC)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("projectId", rebatePayment.getProjectId());
    parameters.addValue("userId", currentUser.getId());
    parameters.addValue("paymentAmount", rebatePayment.getPaymentAmount());

    jdbc.queryForObject(sqlQuery, parameters, String.class);
  }


  public void approvePayments(RebatePayment rebatePayment){
    HashMap<String, Object> params = new HashMap<>();
    params.put("paymentIds", rebatePayment.getPaymentIds());
    params.put("userId", rebatePayment.getApprovedByUserId());

    sqlCache.update("rebate.approvePayments", params);
  }

  public void assignPaymentsToBatch(RebatePayment rebatePayment){
    User user = securityService.getCurrentUser();
    //create batch
    HashMap<String, Object> batchParams = new HashMap<>();
    batchParams.put("paymentIds", rebatePayment.getPaymentIds());
    batchParams.put("userId", user.getId());
    Long batchId = sqlCache.updateReturningId("rebate.createBatch", batchParams, "id").longValue();

    //assign payments to batch id and set status to processed
    HashMap<String, Object> params = new HashMap<>();
    params.put("paymentIds", rebatePayment.getPaymentIds());
    params.put("userId", rebatePayment.getApprovedByUserId());
    params.put("batchId", batchId);
    sqlCache.update("rebate.assignPaymentsToBatch", params);
  }

  public void updateTotalPromotionAmount(RebatePayment rebatePayment){
    HashMap<String, Object> params = new HashMap<>();
    params.put("newTotal", rebatePayment.getTotalPromotionAmount());
    params.put("projectId", rebatePayment.getProjectId());

    sqlCache.update("rebate.updateTotalPromotionAmount", params);
  }

  public void updatePayment(RebatePayment rebatePayment){

    User currentUser = securityService.getCurrentUser();

    String sqlQuery = "select brs.update_rebate_payment(:paymentId::integer, :userId::integer, :paymentAmount::NUMERIC)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("paymentId", rebatePayment.getPaymentId());
    parameters.addValue("userId", currentUser.getId());
    parameters.addValue("paymentAmount", rebatePayment.getPaymentAmount());

    jdbc.queryForObject(sqlQuery, parameters, String.class);

  }

  public void deletePayment(Long paymentId){

    User currentUser = securityService.getCurrentUser();

    String sqlQuery = "select brs.delete_rebate_payment(:paymentId::integer, :userId::integer)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("paymentId", paymentId);
    parameters.addValue("userId", currentUser.getId());

    jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public static class RebateMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public RebateMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<RebatePayment>> rebatePaymentRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "rebatePayments",
        new JsonCollectionDeserializer(rebatePaymentRef, objectMapper));
    }
  }
}
