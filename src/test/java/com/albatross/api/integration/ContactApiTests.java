package com.albatross.api.integration;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import java.util.Collections;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@Slf4j
@ExtendWith(SpringExtension.class)
//@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles(profiles = "local")
public class ContactApiTests {

  @Autowired
  private WebApplicationContext webApplicationContext;

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private SecurityService securityService;

  @BeforeEach
  public void setup() {
    this.mockMvc = MockMvcBuilders.webAppContextSetup(this.webApplicationContext).build();

    //set the local security service user or most calls will fail
    User testUser = new User();
    testUser.setId(2417170L);
    testUser.setHighestCompanyId(1L);
    testUser.setCompanyId(3L);
    UserAccountDetails testUserDetails = new UserAccountDetails(testUser, Collections.emptyList());
    securityService.setCurrentUserDetails(testUserDetails);
  }

  @Test
  public void getContact() throws Exception {
    MvcResult mvcResult = this.mockMvc.perform(get("/api/v1/flow/contact/1646593"))
      .andDo(print()).andExpect(status().isOk())
      .andExpect(jsonPath("$.id").value("1646593"))
      .andExpect(jsonPath("$.id").isNotEmpty())
      .andReturn();

    assertEquals("application/json",
      mvcResult.getResponse().getContentType());
  }

  @Test
  public void postContact() throws Exception {
    String email = "randanunn@gmail2.com";
    String json =
      "{\"city\": \"Salt Lake City\"," +
        "\"companyCountryId\": 1," +
        "\"companyId\": 3," +
        "\"customFieldGroups\": []," +
        "\"email\": \"" + email + "\"," +
        "\"firstName\": \"Randa\"," +
        "\"lastName\": \"Nunn\"," +
        "\"mobile\": \"5412314081\"," +
        "\"phone\": \"5412314081\"," +
        "\"postalCode\": \"84115\"," +
        "\"street1\": \"493 E. Haven Ave\"}";

    System.out.println(json);

    MvcResult mvcResult = this.mockMvc.perform(post("/api/v1/flow/contact")
      .contentType(MediaType.APPLICATION_JSON)
      .content(json))

      .andDo(print()).andExpect(status().isOk())
      .andExpect(jsonPath("$.email").value(email))
      .andExpect(jsonPath("$.id").isNotEmpty())
      .andReturn();

    assertEquals("application/json",
      mvcResult.getResponse().getContentType());
  }
}
