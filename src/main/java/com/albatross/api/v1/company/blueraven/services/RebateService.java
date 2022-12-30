package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.RebateBatchDetail;
import com.albatross.api.v1.company.blueraven.models.RebatePayment;
import com.albatross.api.v1.company.blueraven.models.RebatePaymentState;
import com.albatross.api.v1.company.blueraven.services.queries.RebateQuery;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by John Berns on 2020-04-21.
 */
@Service
@PreAuthorize("(hasCompanyAccess(3) || hasCompanyAccess(18)) && hasFeatureAccessLevel('REBATES')")
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
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("createdBy", user.trueUserId());
    return sqlCache.queryBySql(RebateQuery.getPaymentsPending, params, RebatePayment.class);
  }

  public List<RebatePayment> getUnbalancedPayments() {
    return sqlCache.queryBySql(RebateQuery.getPaymentsUnbalanced, new HashMap<>(), RebatePayment.class);
  }

  public List<RebatePayment> getNeedsApproval() {
    return sqlCache.queryBySql(RebateQuery.getPaymentsNeedApproval, new HashMap<>(), RebatePayment.class);
  }

  public String getRebateDetails(Long projectId) {
    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("projectId", projectId.intValue());

    return jdbc.queryForObject(RebateQuery.getRebateDetails, parameters, String.class);
  }

  public Optional<RebateBatchDetail> getBatchDetails(Long batchId){
    HashMap<String, Object> params = new HashMap<>();
    params.put("batchId", batchId);

    return sqlCache.getBySql(RebateQuery.getBatchDetails, params, new RebateMapper<>(RebateBatchDetail.class, om));
  }

  public List<RebateBatchDetail> getAllBatches(){
    return sqlCache.queryBySql(RebateQuery.getAllBatches, Collections.emptyMap(), RebateBatchDetail.class);
  }

  public Optional<RebateBatchDetail> voidBatch(Long batchId){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("batchId", batchId);
    params.put("userId", currentUser.trueUserId());

    //set the batch as void
    sqlCache.updateBySql(RebateQuery.voidBatch, params);

    //clear the batch id from related payments and reset status to needs approval
    sqlCache.updateBySql(RebateQuery.voidBatchPayments, params);

    return getBatchDetails(batchId);
  }

  public void voidSinglePayment(RebatePayment rebatePayment) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("paymentId", rebatePayment.getPaymentId());
    params.put("userId", currentUser.trueUserId());
    params.put("note", rebatePayment.getVoidNote());

    //set the payment as void
    sqlCache.updateBySql(RebateQuery.voidSinglePayment, params);
  }

  public void unvoidSinglePayment(RebatePayment rebatePayment) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("paymentId", rebatePayment.getPaymentId());
    params.put("userId", currentUser.trueUserId());

    //set the payment as void
    sqlCache.updateBySql(RebateQuery.unvoidSinglePayment, params);
  }

  public void updatePaymentNote(RebatePayment rebatePayment){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("paymentId", rebatePayment.getPaymentId());
    params.put("userId", currentUser.trueUserId());
    params.put("note", rebatePayment.getVoidNote());

    sqlCache.updateBySql(RebateQuery.updatePaymentNote, params);
  }

  public List<RebatePaymentState> getPaymentStates(){
    List<RebatePaymentState> results = sqlCache.queryBySql(RebateQuery.getPaymentStates, Collections.emptyMap(), RebatePaymentState.class);
    return results;
  }

  public void createRecurringPayment(RebatePayment rebatePayment){
    User currentUser = securityService.getCurrentUser();
    String sqlQuery = "select brs.create_rebate_payments(:projectId::bigint, :createdById::bigint, :totalAmount::numeric , :promotionPayments::bigint)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("projectId", rebatePayment.getProjectId());
    parameters.addValue("createdById", currentUser.trueUserId());
    parameters.addValue("totalAmount", rebatePayment.getTotalPromotionAmount());
    parameters.addValue("promotionPayments", rebatePayment.getNumberOfPromotionPayments());

    jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public void addExtraPayment(RebatePayment rebatePayment){

    User currentUser = securityService.getCurrentUser();

    String sqlQuery = "select brs.project_rebate_payments_add_extra_payment(:projectId::bigint, :userId::bigint, :paymentAmount::NUMERIC)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("projectId", rebatePayment.getProjectId());
    parameters.addValue("userId", currentUser.trueUserId());
    parameters.addValue("paymentAmount", rebatePayment.getPaymentAmount());

    jdbc.queryForObject(sqlQuery, parameters, String.class);
  }


  public void approvePayments(RebatePayment rebatePayment){
    HashMap<String, Object> params = new HashMap<>();
    params.put("paymentIds", rebatePayment.getPaymentIds());
    params.put("userId", rebatePayment.getApprovedByUserId());

    sqlCache.updateBySql(RebateQuery.approvePayments, params);
  }

  public void assignPaymentsToBatch(RebatePayment rebatePayment){
    User user = securityService.getCurrentUser();
    //create batch
    HashMap<String, Object> batchParams = new HashMap<>();
    batchParams.put("paymentIds", rebatePayment.getPaymentIds());
    batchParams.put("userId", user.trueUserId());
    Long batchId = sqlCache.updateBySqlReturningId(RebateQuery.createBatch, batchParams, "id").longValue();

    //assign payments to batch id and set status to processed
    HashMap<String, Object> params = new HashMap<>();
    params.put("paymentIds", rebatePayment.getPaymentIds());
    params.put("userId", rebatePayment.getApprovedByUserId());
    params.put("batchId", batchId);
    sqlCache.updateBySql(RebateQuery.assignPaymentsToBatch, params);
  }

  public void updateTotalPromotionAmount(RebatePayment rebatePayment){
    HashMap<String, Object> params = new HashMap<>();
    params.put("newTotal", rebatePayment.getTotalPromotionAmount());
    params.put("projectId", rebatePayment.getProjectId());

    sqlCache.updateBySql(RebateQuery.updateTotalPromotionAmount, params);
  }

  public void updatePayment(RebatePayment rebatePayment){

    User currentUser = securityService.getCurrentUser();

    String sqlQuery = "select brs.update_rebate_payment(:paymentId::bigint, :userId::bigint, :paymentAmount::NUMERIC)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("paymentId", rebatePayment.getPaymentId());
    parameters.addValue("userId", currentUser.trueUserId());
    parameters.addValue("paymentAmount", rebatePayment.getPaymentAmount());

    jdbc.queryForObject(sqlQuery, parameters, String.class);

  }

  public void deletePayment(Long paymentId){

    User currentUser = securityService.getCurrentUser();

    String sqlQuery = "select brs.delete_rebate_payment(:paymentId::bigint, :userId::bigint)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("paymentId", paymentId);
    parameters.addValue("userId", currentUser.trueUserId());

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
