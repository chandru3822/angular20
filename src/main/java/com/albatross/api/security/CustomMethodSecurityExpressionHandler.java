package com.albatross.api.security;

import org.aopalliance.intercept.MethodInvocation;
import org.springframework.expression.EvaluationContext;
import org.springframework.expression.spel.support.StandardEvaluationContext;
import org.springframework.security.access.expression.method.DefaultMethodSecurityExpressionHandler;
import org.springframework.security.access.expression.method.MethodSecurityExpressionOperations;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import java.util.function.Supplier;

@Component
public class CustomMethodSecurityExpressionHandler extends DefaultMethodSecurityExpressionHandler {

  @Override
  public EvaluationContext createEvaluationContext(Supplier<Authentication> authentication, MethodInvocation mi) {
    StandardEvaluationContext context = (StandardEvaluationContext) super.createEvaluationContext(authentication, mi);
    MethodSecurityExpressionOperations delegate = (MethodSecurityExpressionOperations) context.getRootObject().getValue();
    if (delegate != null && delegate.getAuthentication() != null) {
      final var root = new CustomSecurityExpressionRoot(delegate.getAuthentication());
      context.setRootObject(root);
    }
    return context;
  }
}
