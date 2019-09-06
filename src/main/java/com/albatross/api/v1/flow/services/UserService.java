package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserPermission;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.UUID;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class UserService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  ObjectMapper om;

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

  public static class UserMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public UserMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<UserPermission>> userPermissionRef = new TypeReference<List<UserPermission>>() {};
      bw.registerCustomEditor(List.class, "permissions",
          new JsonCollectionDeserializer(userPermissionRef, objectMapper));

    }
  }
}
