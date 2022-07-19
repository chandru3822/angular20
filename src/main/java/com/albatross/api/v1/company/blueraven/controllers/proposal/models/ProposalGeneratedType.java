package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import org.springframework.util.LinkedMultiValueMap;

public enum ProposalGeneratedType {
  MOBILE,
  WEB,
  PRINT;

//  TODO: pull these values dynamically?
  public static LinkedMultiValueMap<String, String> getOptions(ProposalGeneratedType proposalGeneratedType){
    final var params = new LinkedMultiValueMap<String, String>();

    //NOTE: completely arbitrary settings
    switch (proposalGeneratedType){
      case WEB, MOBILE ->{
        params.add("q", "80");
        params.add("w", "1080");
      }
      case PRINT -> {
        params.add("q", "100");
        params.add("dpr", "2");
        params.add("w", "1080");
      }
    }
    return params;
  }
}
