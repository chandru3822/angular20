package com.albatross.api.v1.company.blueraven.services.tournament;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.tournament.TournamentPool;
import com.albatross.api.v1.company.blueraven.models.tournament.TournamentPoolPosition;
import com.albatross.api.v1.company.blueraven.models.tournament.TournamentPoolUser;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.AttachmentService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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

  @Value("${aws.storageBucket}")
  private String bucket;

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final AttachmentService attachmentService;
  private final ObjectMapper om;

  public Optional<TournamentPool> getPoolDetails(Long tournamentId, Long tournamentPoolTypeId) {
//    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("tournamentId", tournamentId);
    params.put("tournamentPoolTypeId", tournamentPoolTypeId);
    Optional<TournamentPool> result = sqlCache.get("tournamentPool.getDetails", params, new TournamentPoolMapper<>(TournamentPool.class, om));
    if(result.isPresent() && null != result.get().getBackgroundAttachmentId()) {
      result.get().setBackgroundAttachmentPresignedUrl(attachmentService.getAttachmentPresignedUrlById(bucket, result.get().getBackgroundAttachmentId()));
    }
    return result;
  }

  public void updatePool(Long tournamentId, Long poolId, TournamentPool pool) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("poolId", poolId);
    params.put("userId", user.getId());
    params.put("customName", pool.getCustomName());
    params.put("startDate", pool.getStartDate());
    params.put("endDate", pool.getEndDate());
    sqlCache.update("tournamentPool.updatePool", params);
  }

  public String getPoolUsers(Long tournamentId, Long tournamentPoolTypeId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("tournamentId", tournamentId);
    params.put("tournamentPoolTypeId", tournamentPoolTypeId);
    String result = sqlCache.queryForObject("tournamentPool.getPoolUsers", params, String.class);
    return result;
  }

  public Optional<TournamentPoolPosition> getPoolPosition(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<TournamentPoolPosition> result = sqlCache.get("tournamentPool.getPosition", params, TournamentPoolPosition.class);
    return result;
  }

  public Optional<TournamentPoolPosition> addPositionToPool(Long poolId, Long positionId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("poolId", poolId);
    params.put("positionId", positionId);
    params.put("createdById", user.trueUserId());
    Long id = sqlCache.updateReturningId("tournamentPool.addPosition", params, "id").longValue();
    return getPoolPosition(id);
  }

  public void deletePositionFromPool(Long tournamentPoolPositionId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("tournamentPoolPositionId", tournamentPoolPositionId);
    params.put("userId", user.getId());
    sqlCache.update("tournamentPool.deletePosition", params);
  }


  public Optional<TournamentPoolUser> getPoolUser(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<TournamentPoolUser> result = sqlCache.get("tournamentPool.getUser", params, TournamentPoolUser.class);
    return result;
  }

  public Optional<TournamentPoolUser> addUserToPool(Long poolId, Long userId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("poolId", poolId);
    params.put("userId", userId);
    params.put("createdById", user.trueUserId());
    Long id = sqlCache.updateReturningId("tournamentPool.addUser", params, "id").longValue();
    return getPoolUser(id);
  }

  public void deleteUserFromPool(Long tournamentPoolUserId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("tournamentPoolUserId", tournamentPoolUserId);
    params.put("userId", user.getId());
    sqlCache.update("tournamentPool.deleteUser", params);
  }

  public void assignUsersToMatches(Long tournamentId, Long poolId, String seededMatches) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("tournamentId", tournamentId);
    params.put("tournamentPoolId", poolId);
    params.put("userId", user.getId());
    params.put("seededMatches", seededMatches);

    sqlCache.query("tournamentPool.assignUsersToMatches", params, String.class);
  }

  public void advanceUsersToWinnerPool(Long tournamentId, Long poolId, List<Long> userIds) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("tournamentId", tournamentId);
    params.put("tournamentPoolId", poolId);
    params.put("userId", user.getId());
    params.put("userIds", userIds);

    sqlCache.update("tournamentPool.advanceUsersToWinnerPool", params);
  }

  public static class TournamentPoolMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public TournamentPoolMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<TournamentPoolUser>> usersRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "users",
        new JsonCollectionDeserializer(usersRef, objectMapper));
      TypeReference<List<TournamentPoolPosition>> positionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "positions",
        new JsonCollectionDeserializer(positionsRef, objectMapper));
    }
  }
}
