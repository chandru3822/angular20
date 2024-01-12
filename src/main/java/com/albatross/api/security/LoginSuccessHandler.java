package com.albatross.api.security;

import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

//TODO: This is never invoked on login, should we remove it?
public class LoginSuccessHandler implements AuthenticationSuccessHandler {

  @Autowired private ObjectMapper objectMapper;

  @Autowired private SecurityService securityService;

  @Override
  public void onAuthenticationSuccess(
      HttpServletRequest request, HttpServletResponse response, Authentication authentication)
      throws IOException, ServletException {
    // setting the status as ok and PLEASE avoid redirects.
    response.setStatus(HttpServletResponse.SC_OK);
    response.setHeader("Content-Type", "application/json");

    UserAccountDetails details = securityService.getCurrentUserDetails();

    String json = objectMapper.writeValueAsString(Map.of("user", details));

    response.getWriter().write(json);
  }
}
