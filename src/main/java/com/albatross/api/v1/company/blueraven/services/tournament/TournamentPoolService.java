package com.albatross.api.v1.company.blueraven.services.tournament;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.tournament.TournamentPool;
import com.albatross.api.v1.company.blueraven.models.tournament.TournamentPoolUser;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Randa Nunn on 2021-03-12.
 */
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class TournamentPoolService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public Optional<TournamentPool> getPoolDetails(Long tournamentId, Long tournamentPoolTypeId) {
//    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("tournamentId", tournamentId);
    params.put("tournamentPoolTypeId", tournamentPoolTypeId);
    Optional<TournamentPool> result = sqlCache.get("tournamentPool.getDetails", params, new TournamentPoolMapper<>(TournamentPool.class, om));
    return result;
  }

  public static class TournamentPoolMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public TournamentPoolMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<TournamentPoolUser>> usersRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "users",
        new JsonCollectionDeserializer(usersRef, objectMapper));
    }
  }
}
