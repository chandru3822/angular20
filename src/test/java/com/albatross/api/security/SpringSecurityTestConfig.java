package com.albatross.api.security;

import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.security.access.expression.method.MethodSecurityExpressionHandler;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.method.configuration.GlobalMethodSecurityConfiguration;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import java.util.List;
import java.util.Map;

@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
class SpringSecurityTestConfig extends GlobalMethodSecurityConfiguration {

  @Override
  protected MethodSecurityExpressionHandler createExpressionHandler() {
    return new CustomMethodSecurityExpressionHandler();
  }

  @Bean
  @Primary
  public SecurityService securityService() {
    return new SecurityService() {
      private static final Map<String, UserAccountDetails> USER_ACCOUNTS =
          Map.of(
              "blueraven",
              createUserAccountDetails("blueraven", 3L, Map.of()),
              "other",
              createUserAccountDetails("other", 4L, Map.of()));

      private UserAccountDetails currentUser;

      private static UserAccountDetails createUserAccountDetails(
          String username, Long companyId, Map<String, List<String>> features) {
        final User user = new User();
        user.setUsername(username);
        user.setCompanyId(companyId);
        return new UserAccountDetails(user, List.of());
      }

      @Override
      public User getCurrentUser() {
        final User user = new User();
        user.setCompanyId(this.currentUser.getCompanyId());
        return user;
      }

      @Override
      public UserAccountDetails loadUserByUsername(String username)
          throws UsernameNotFoundException {

        if (!USER_ACCOUNTS.containsKey(username)) {
          throw new UsernameNotFoundException(username);
        }

        this.currentUser = USER_ACCOUNTS.get(username);
        return this.currentUser;
      }
    };
  }
}
