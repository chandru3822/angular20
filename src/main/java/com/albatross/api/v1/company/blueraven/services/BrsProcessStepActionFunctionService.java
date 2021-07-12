package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.v1.flow.model.ProcessStepActionChildFunction;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class BrsProcessStepActionFunctionService {

  private final LoanPalService loanPalServiceAutowire;

  private static LoanPalService loanPalService;

  @PostConstruct
  public void init() {
    BrsProcessStepActionFunctionService.loanPalService = loanPalServiceAutowire;
  }

  public static void updateLoanDocumentStatus(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {

    try {
      JSONObject application = loanPalService.getApplicationByProjectId(systemValues.get("projectId").toString());
    } catch (Exception e) {
      // @TODO: implement this sucker
    }
  }
}
