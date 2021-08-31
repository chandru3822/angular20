package com.albatross.api.v1.company.blueraven.controllers.expenses;

import com.albatross.api.v1.company.blueraven.models.expenses.Expense;
import com.albatross.api.v1.company.blueraven.models.expenses.ExpenseBudget;
import com.albatross.api.v1.company.blueraven.models.expenses.ReimbursementRequest;
import com.albatross.api.v1.company.blueraven.models.expenses.ReimbursementUserSearch;
import com.albatross.api.v1.company.blueraven.services.expenses.ExpenseBudgetService;
import com.albatross.api.v1.company.blueraven.services.expenses.ExpenseService;
import com.albatross.api.v1.company.blueraven.services.expenses.ReimbursementService;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.AttachmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/company/blueraven/reimbursement")
public class ReimbursementController {

  private final ReimbursementService reimbursementService;
  private final ExpenseBudgetService expenseBudgetService;
  private final ExpenseService expenseService;
  private final AttachmentService attachmentService;

  @PostMapping(value = "/request", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity submitReimbursementRequest(@RequestBody ReimbursementRequest reimbursementRequest) {

    Optional<ExpenseBudget> expenseBudget = Optional.empty();
    //if there is a budget id get the balance of the budget
    if(null != reimbursementRequest.getExpenseBudgetId()){
      expenseBudget = expenseBudgetService.getBudgetRemainingById(reimbursementRequest.getExpenseBudgetId());
    }

    //dont save if it would go over budget
    if(expenseBudget.isPresent() && expenseBudget.get().getBalance() < reimbursementRequest.getAmount()){
      return new ResponseEntity(HttpStatus.NOT_ACCEPTABLE);
    }

    //save the request if no budget or balance >= amount
    if(null == reimbursementRequest.getExpenseBudgetId() || (expenseBudget.isPresent() && expenseBudget.get().getBalance() >= reimbursementRequest.getAmount())){

      //save the request first
      Long id = reimbursementService.updateRequest(reimbursementRequest);
      reimbursementRequest.setId(id);

      if(null != reimbursementRequest.getId()){

        Expense expense = new Expense();
        expense.setExpenseDate(reimbursementRequest.getExpenseDate());
        expense.setReimbursementRequestId(reimbursementRequest.getId());
        expense.setUserId(reimbursementRequest.getCreatedById());
        expense.setExpenseAmount(reimbursementRequest.getAmount());
        expense.setExpenseBudgetId(reimbursementRequest.getExpenseBudgetId());
        expenseService.addDefaultLineItem(expense);

        if(null != reimbursementRequest.getAttachmentId()){
          //add to the attachment join table
          //todo: @randa this
          attachmentService.addToJoinTable(reimbursementRequest.getAttachmentId(), reimbursementRequest.getId(), 4L, true);
        }
      }

    }

    return null;
  }

  @PutMapping(value = "/request", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateReimbursementRequest(@RequestBody ReimbursementRequest reimbursementRequest) {
    reimbursementService.updateRequest(reimbursementRequest);
  }

  @PostMapping(value = "/request/updateStatus", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateReimbursementRequestStatus(@RequestBody ReimbursementRequest reimbursementRequest) {
    reimbursementService.updateRequestStatus(reimbursementRequest);
  }

  @GetMapping(value = "/requests/pending", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ReimbursementRequest> getPendingReimbursementRequests() {
    return reimbursementService.getPendingReimbursementRequests();
  }

  @GetMapping(value = "/request/{id}/image", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getRequestAttachmentPresignedUrl(@PathVariable Long id) {
    return attachmentService.getAttachmentPresignedUrl(id, 4L);
  }

  @GetMapping(value = "/requests/byStatus", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ReimbursementRequest> getRequestsForUserByStatus(@RequestParam Long statusId,
                                                               @RequestParam String startDate,
                                                               @RequestParam String endDate) {
    return reimbursementService.getRequestsForUserByStatus(statusId, startDate, endDate);
  }


  @PostMapping(value = "/users", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<User> getAllReimbursementUsers(@RequestBody ReimbursementUserSearch usersSearch) {
    //this returns all users that can submit reimbursement requests, used for when admin adds line directly to expense table
    return reimbursementService.getAllReimbursementUsers(usersSearch);
  }

//  @RequestMapping(value = "/request/getSourceAttachments", method = RequestMethod.GET)
//  public List<Attachment> getAttachmentsBySourceIdAndType(@RequestParam Long sourceId,
//                                                          @RequestParam Long attachmentSourceTypeId) {
//    return attachmentService.getAttachmentsBySourceIdAndType(bucket, sourceId, attachmentSourceTypeId);
//  }

  @GetMapping(value = "/requests/supervisor/byStatus", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ReimbursementRequest> getRequestsForSupervisorByStatus(@RequestParam Long statusId) {
    return reimbursementService.getRequestsForSupervisorByStatus(statusId);
  }

  @GetMapping(value = "/getMonthlySubmittedReport", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getMonthlySubmittedReport(@RequestParam String startDate,
                                       @RequestParam String endDate) {
    return reimbursementService.getMonthlySubmittedReport(startDate, endDate);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteRequest(@PathVariable("id") Long id) {
    reimbursementService.deleteRequest(id);
  }
}
