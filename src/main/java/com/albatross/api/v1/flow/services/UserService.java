package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.collect.Collections2;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
public class UserService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public Page<User> searchUsers(UserSearch search, Pageable pageable) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", search.getSearch());
    params.put("firstName", search.getFirstName());
    params.put("lastName", search.getLastName());
    params.put("email", search.getEmail());
    params.put("phone", search.getPhone());
    params.put("statuses", search.getStatuses());
    params.put("positions", search.getPositions());
    params.put("orgs", search.getOrgs());
    params.put("primaryFlag", search.getPrimaryFlag());
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<User> results = sqlCache.query("user.searchUsers", params, new UserMapper<>(User.class, om));
    Integer count = sqlCache.queryForObject("user.searchUserCount", params, Integer.class);

    Page<User> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
  }

  public ResponseEntity exportUsers(UserSearch search) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", search.getSearch());
    params.put("firstName", search.getFirstName());
    params.put("lastName", search.getLastName());
    params.put("email", search.getEmail());
    params.put("phone", search.getPhone());
    params.put("statuses", search.getStatuses());
    params.put("positions", search.getPositions());

    List<User> results = sqlCache.query("user.exportUsers", params, User.class);

    // set up CSV writing
    CsvMapper mapper = new CsvMapper();
    CsvSchema schema = mapper.typedSchemaFor(UserExportTemplate.class).withHeader();
    ObjectWriter writer = mapper.writer(schema);
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    // get user deets and write to CSV
    try (SequenceWriter outToBuffer = writer.writeValues(buffer)) {
      // first, get deets
      Collection<UserExportTemplate> details = Collections2.transform(
          results,
          UserExportTemplate::from);

      // next, write them to a buffer so we can identify errors before writing across the network
      outToBuffer.writeAll(details);
      outToBuffer.flush();

      // finally, write to network because no errors were encountered
      return ResponseEntity.ok(buffer.toString(StandardCharsets.UTF_8));
    } catch (IOException e) {
      log.error("Encountered error while writing user export to CSV", e);
      return ResponseEntity.status(500)
          .body("Encountered error while writing user export to CSV");
    }
  }

  public User saveUser(User user) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("firstName", user.getFirstName());
    params.put("lastName", user.getLastName());
    params.put("phone", user.getPhoneNumber());
    params.put("email", user.getEmail());
    params.put("schedulable", user.getSchedulable());
    params.put("companyId", currentUser.getCompanyId());

    Long id;
    if(null != user.getId()) {
      id = user.getId();
      params.put("modifiedById", currentUser.getId());
      params.put("id", id);
      sqlCache.update("user.updateUser", params);
    } else {
      params.put("createdById", currentUser.getId());
      id = sqlCache.updateReturningId("user.insertUser", params, "id").longValue();
    }

    handleSavingCustomFieldValues(user.getCustomFieldGroups(), id);

    return getUser(id);
  }

  public User getUser(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<User> result = sqlCache.get("user.getOne", params, User.class);
    return result.orElse(null);
  }

  public List<User> getSchedulingUsers(Long stateId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("stateId", stateId);
    params.put("companyId", currentUser.getCompanyId());
    List<User> results = sqlCache.query("user.getSchedulingUsers", params, User.class);
    return results;
  }


  public Boolean fieldHasValue (CustomFieldValue cv) {
    return null != cv.getDateValue() || null != cv.getTimestampValue() || null != cv.getBooleanValue() || null != cv.getTextValue()
        || null != cv.getNumericValue() || null != cv.getIntValue() || null != cv.getIntArrayValue();
  }

  public void handleSavingCustomFieldValues(List<CustomFieldGroup> groups, Long primaryId){
    User currentUser = securityService.getCurrentUser();
    for(CustomFieldGroup group : groups) {
      for(CustomFieldValue cfv : group.getCustomFieldValues()){
        //todo: only save if something changed
        if(fieldHasValue(cfv)) {
          HashMap<String, Object> params = new HashMap<>();
          params.put("dateValue", cfv.getDateValue());
          params.put("timestampValue", cfv.getTimestampValue());
          params.put("booleanValue", cfv.getBooleanValue());
          params.put("textValue", cfv.getTextValue());
          params.put("numericValue", cfv.getNumericValue());
          params.put("intValue", cfv.getIntValue());
          params.put("intArrayValue", cfv.getIntArrayValue());
          params.put("userId", primaryId);
          params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());

          if(null != cfv.getId()){
            params.put("id", cfv.getId());
            params.put("modifiedById", currentUser.getId());
            sqlCache.update("customFieldValues.updateUserCustomFieldValue", params);
          } else {
            params.put("createdById", currentUser.getId());
            sqlCache.update("customFieldValues.insertUserCustomFieldValue", params);
          }
        }
      }
    }
  }

  public User findByUsernameIgnoreCase(String username) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("username", username);
    Optional<User> user = sqlCache.get("user.findByUsernameIgnoreCase", params, new UserMapper<>(User.class, om));
    return user.orElse(null);
  }

  public User findByUserUuid(UUID uuid) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("uuid", uuid);
    Optional<User> user = sqlCache.get("user.findByUserUuid", params, User.class);
    return user.orElse(null);
  }

  public User findUserById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<User> user = sqlCache.get("user.findUserById", params, User.class);
    return user.orElse(null);
  }

  public List<UserStatusType> getUserStatuses() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<UserStatusType> results = sqlCache.query("user.getUserStatuses", params, UserStatusType.class);
    return results;
  }

  public static class UserMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public UserMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<UserPermission>> userPermissionRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "permissions",
          new JsonCollectionDeserializer(userPermissionRef, objectMapper));

      TypeReference<List<UserOrgHierarchy>> userOrgHierarchyRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "hierarchy",
          new JsonCollectionDeserializer(userOrgHierarchyRef, objectMapper));
    }
  }
}
