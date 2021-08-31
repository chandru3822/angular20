package com.albatross.api.v1.company.blueraven.services.expenses;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.expenses.Expense;
import com.albatross.api.v1.company.blueraven.models.expenses.ReimbursementRequest;
import com.albatross.api.v1.company.blueraven.models.expenses.ReimbursementUserSearch;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
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
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ReimbursementService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;


  public Long updateRequest(ReimbursementRequest reimbursementRequest) {
    User currentUser = securityService.getCurrentUser();

    Long statusId = 3L;

    //add the sales area
    HashMap<String, Object> params = new HashMap<>();
    params.put("amount", reimbursementRequest.getAmount());
    params.put("details", reimbursementRequest.getDetails());
    params.put("attachmentId", reimbursementRequest.getAttachmentId());
    params.put("expenseBudgetId", reimbursementRequest.getExpenseBudgetId());
    params.put("createdById", currentUser.trueUserId());
    params.put("expenseDate", reimbursementRequest.getExpenseDate());
    Long id;
    if(reimbursementRequest.getId() != null && reimbursementRequest.getReimbursementRequestStatusId() == null){
      params.put("id", reimbursementRequest.getId());
      params.put("statusId", statusId);
      id = sqlCache.updateReturningId("reimbursement.update", params, "id").longValue();
    }else if(reimbursementRequest.getId() != null
      && reimbursementRequest.getReimbursementRequestStatusId() != null
      && reimbursementRequest.getReimbursementRequestStatusId() == 1L) {
      //use this if they are approving the request to go to the finance screen
      params.put("id", reimbursementRequest.getId());
      params.put("statusId", reimbursementRequest.getReimbursementRequestStatusId());
      id = sqlCache.updateReturningId("reimbursement.update", params, "id").longValue();
    }else{
      //if this is a new request and the user making request is not the same as the budget user, mark it as pending supervisor approval
      //unless it is Austin Thompson submitting to Dane's budget
      Long userId = currentUser.trueUserId();

      if(reimbursementRequest.getExpenseBudgetUserId() != null
        && !userId.equals(reimbursementRequest.getExpenseBudgetUserId())
        && !(userId.equals(2354046L) && reimbursementRequest.getExpenseBudgetUserId().equals(2353912L))){
        statusId = 6L;
      }
      params.put("statusId", statusId);

      if(reimbursementRequest.getId() != null){
        params.put("id", reimbursementRequest.getId());
        id = sqlCache.updateReturningId("reimbursement.update", params, "id").longValue();
      }else {
        id = sqlCache.updateReturningId("reimbursement.insert", params, "id").longValue();
      }
    }
    return id;
  }

  public void updateRequestStatus(ReimbursementRequest reimbursementRequest) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("reimbursementRequestStatusId", reimbursementRequest.getReimbursementRequestStatusId());
    params.put("id", reimbursementRequest.getId());
    params.put("userId", currentUser.trueUserId());
    sqlCache.update("reimbursement.updateStatus", params);

    if(null != reimbursementRequest.getNotes()){
      params.put("notes", reimbursementRequest.getNotes());
      sqlCache.update("reimbursement.saveReimbursementNote", params);
    }

    //if they reject the request then we need to also reject the expenses associated with the request
    if(reimbursementRequest.getReimbursementRequestStatusId() == 2){
      sqlCache.update("expense.rejectExpensesWhenRequestIsRejected", params);
    }
  }

  public List<ReimbursementRequest> getPendingReimbursementRequests() {
    List<ReimbursementRequest> results = sqlCache.query("reimbursement.getPendingRequests", Collections.emptyMap(), new ReimbursementRequestMapper<>(ReimbursementRequest.class, om));
    return results;
  }

  public List<ReimbursementRequest> getRequestsForUserByStatus(Long statusId, String startDate, String endDate) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("statusId", statusId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    List<ReimbursementRequest> results = sqlCache.query("reimbursement.getRequestsForUserByStatus", params, ReimbursementRequest.class);
    return results;
  }

  public List<User> getAllReimbursementUsers(ReimbursementUserSearch usersSearch) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("searchText", usersSearch.getQuery());
//        leaving this here in case they change their minds. this line only show those who can submit a request, the new one just shows all active users
//        List<User> results = sqlCache.query("reimbursement.getAllReimbursementUsers", params, User.class);
    List<User> results = sqlCache.query("reimbursement.getAllActiveUsers", params, User.class);
    return results;
  }

  public List<ReimbursementRequest> getRequestsForSupervisorByStatus(Long statusId){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("supervisorId", currentUser.getId());
    params.put("statusId", statusId);

    List<ReimbursementRequest> results = sqlCache.query("reimbursement.getRequestsForSupervisorByStatus", params, ReimbursementRequest.class);
    return results;
  }

  public String getMonthlySubmittedReport(String startDate, String endDate){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    Optional<String> result = sqlCache.get("reimbursement.getMonthlySubmittedReport", params, new SingleColumnRowMapper<>(String.class));
    return result.orElse("{}");
  }

  public String getMonthlySubmittedReportDrilldown(Long userId, String startDate, String endDate, String status){
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("status", status);

    Optional<String> result = sqlCache.get("reimbursement.getMonthlySubmittedReportDrilldown", params, new SingleColumnRowMapper<>(String.class));
    return result.orElse("{}");
  }

  public void deleteRequest(Long id){
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    //mark the request as deleted
    sqlCache.update("reimbursement.deleteRequest", params);

    //delete any expenses with the same request
    sqlCache.update("reimbursement.deleteExpensesForRequest", params);
  }

  public static class ReimbursementRequestMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ReimbursementRequestMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Expense>> expensesTypeRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "expenses",
        new JsonCollectionDeserializer(expensesTypeRef, objectMapper));
    }
  }

}
