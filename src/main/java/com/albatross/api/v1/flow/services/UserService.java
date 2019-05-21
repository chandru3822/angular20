package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
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

  public User findByEmailIgnoreCase(String email) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("email", email);
    Optional<User> user = sqlCache.get("user.findByEmailIgnoreCase", params, User.class);
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
}
