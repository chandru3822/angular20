package com.albatross.api.v1.company.blueraven.services.expenses;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.expenses.Expense;
import com.albatross.api.v1.company.blueraven.models.expenses.ReimbursementRequest;
import com.albatross.api.v1.company.blueraven.services.expenses.queries.ReimbursementQuery;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Randa Nunn
 */
@Service
@RequiredArgsConstructor
public class ReimbursementService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;


  public Long updateRequest(ReimbursementRequest reimbursementRequest) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("amount", reimbursementRequest.getAmount());
    params.put("details", reimbursementRequest.getDetails());
    params.put("attachmentId", reimbursementRequest.getAttachmentId());
    params.put("expenseBudgetId", reimbursementRequest.getExpenseBudgetId());
    params.put("budgetTypeId", reimbursementRequest.getBudgetTypeId());
    params.put("glCodeId", reimbursementRequest.getGlCodeId());
    params.put("createdById", currentUser.trueUserId());
    params.put("expenseDate", reimbursementRequest.getExpenseDate());
    //null id with a status_id = 1 means an admin submitted it and it should be marked approved
    params.put("statusId", reimbursementRequest.getReimbursementRequestStatusId() != null ? reimbursementRequest.getReimbursementRequestStatusId() : 3L); //3 = pending
    Long id;

    if (reimbursementRequest.getId() != null) {
      id = reimbursementRequest.getId();
      params.put("id", reimbursementRequest.getId());
      sqlCache.updateBySql(ReimbursementQuery.update, params);
    } else {
      id = sqlCache.updateBySqlReturningId(ReimbursementQuery.insert, params, "id").longValue();
    }
    return id;
  }

  public void updateRequestStatus(ReimbursementRequest reimbursementRequest) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("reimbursementRequestStatusId", reimbursementRequest.getReimbursementRequestStatusId());
    params.put("id", reimbursementRequest.getId());
    params.put("userId", currentUser.trueUserId());
    sqlCache.updateBySql(ReimbursementQuery.updateStatus, params);

    if (null != reimbursementRequest.getNotes()) {
      params.put("notes", reimbursementRequest.getNotes());
      sqlCache.updateBySql(ReimbursementQuery.saveReimbursementNote, params);
    }
  }

  public List<ReimbursementRequest> getPendingReimbursementRequests() {
    return sqlCache.queryBySql(ReimbursementQuery.getPendingRequests, Collections.emptyMap(), ReimbursementRequest.class);
  }

  public List<ReimbursementRequest> getRequestsForUserByStatus(Long statusId, String startDate, String endDate) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("statusId", statusId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    return sqlCache.queryBySql(ReimbursementQuery.getRequestsForUserByStatus, params, ReimbursementRequest.class);
  }

  public void deleteRequest(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    //mark the request as deleted
    sqlCache.updateBySql(ReimbursementQuery.deleteRequest, params);
  }

  public List<ReimbursementRequest> getUnpaidRequests(String startDate, String endDate) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    return sqlCache.queryBySql(ReimbursementQuery.getUnpaidRequests, params, ReimbursementRequest.class);
  }


}
