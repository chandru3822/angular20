package com.albatross.api.security;

import com.albatross.api.security.jwt.JwtUtils;
import org.springframework.security.web.authentication.preauth.RequestHeaderAuthenticationFilter;

import javax.servlet.http.HttpServletRequest;

public class CustomRequestHeaderAuthenticationFilter extends RequestHeaderAuthenticationFilter {

  @Override
  protected Object getPreAuthenticatedPrincipal(HttpServletRequest request) {
    // First we check to see if it's included in the header
    final Object principal = super.getPreAuthenticatedPrincipal(request);

    // If it's not in the header check to see if we have it as a query param
    if (principal == null) {
      final String accessToken = request.getParameter("access_token");
      if (accessToken != null) {
        // format it so it's handled downstream correctly
        return String.format("%s %s", JwtUtils.TOKEN_PREFIX.trim(), accessToken.trim());
      }
    }

    return principal;
  }
}
