package com.albatross.api.security;

import com.albatross.api.utils.Params;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

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

    String json = objectMapper.writeValueAsString(new Params("user", details).buildNullable());

    response.getWriter().write(json);
  }
}
