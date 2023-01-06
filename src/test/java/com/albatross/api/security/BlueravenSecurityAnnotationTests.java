package com.albatross.api.security;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldService;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.services.CompanyService;
import com.albatross.api.v1.flow.services.SqlArrayService;
import com.albatross.api.v1.flow.services.SystemListService;
import com.albatross.api.v1.flow.services.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.test.context.support.WithAnonymousUser;
import org.springframework.security.test.context.support.WithUserDetails;
import org.springframework.test.context.ContextConfiguration;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.Mockito.when;

@Import(SpringSecurityTestConfig.class)
@SpringBootTest(classes = {BlueravenCustomFieldService.class})
@ContextConfiguration
class BlueravenSecurityAnnotationTests {

  // these are required for the Spring ApplicationContext
  @MockBean private ObjectMapper om;
  @MockBean private SqlCache sqlCache;
  @MockBean private UserService userService;
  @MockBean private CompanyService companyService;
  @MockBean private PasswordEncoder passwordEncoder;
  @MockBean private SqlArrayService sqlArrayService;
  @MockBean private SystemListService systemListService;

  @Autowired private SecurityService securityService;
  @Autowired private BlueravenCustomFieldService blueravenCustomFieldService;

  @Test
  public void should_throw_exception_with_no_user() {
    assertThrows(
        AuthenticationCredentialsNotFoundException.class,
        () -> blueravenCustomFieldService.getAllCustomFields());
  }

  @Test
  @WithAnonymousUser
  public void should_throw_access_denied_with_anonymous_user() {
    assertThrows(
        AccessDeniedException.class, () -> blueravenCustomFieldService.getAllCustomFields());
  }

  @Test
  @WithUserDetails("blueraven")
  public void should_return_with_correct_user_company() {

    when(sqlCache.queryBySql(any(String.class), anyMap(), any(RowMapper.class)))
        .thenReturn(List.of(new CustomField()));

    final List<CustomField> customFields = blueravenCustomFieldService.getAllCustomFields();
    assertNotNull(customFields);
    assertEquals(1, customFields.size());
  }

  @Test
  @WithUserDetails("other")
  public void should_throw_access_denied_with_incorrect_user_company() {
    assertThrows(
        AccessDeniedException.class, () -> blueravenCustomFieldService.getAllCustomFields());
  }
}
