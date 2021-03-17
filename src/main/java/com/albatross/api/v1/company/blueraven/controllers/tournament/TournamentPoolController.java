package com.albatross.api.v1.company.blueraven.controllers.tournament;

import com.albatross.api.v1.company.blueraven.models.tournament.TournamentPool;
import com.albatross.api.v1.company.blueraven.models.tournament.TournamentPoolPosition;
import com.albatross.api.v1.company.blueraven.models.tournament.TournamentPoolUser;
import com.albatross.api.v1.company.blueraven.services.tournament.TournamentPoolService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by Randa Nunn on 2021-03-12.
 */
@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/company/blueraven/tournament/{tournamentId}/pool")
public class TournamentPoolController {

  private final TournamentPoolService tournamentPoolService;

  @GetMapping(value = "/byType/{poolTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<TournamentPool> getTournamentPool(@PathVariable Long tournamentId,
                                                    @PathVariable Long poolTypeId) {
    return tournamentPoolService.getPoolDetails(tournamentId, poolTypeId);
  }

  @GetMapping(value = "/usersByType/{poolTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<TournamentPoolUser> getTournamentPoolUsers(@PathVariable Long tournamentId,
                                                         @PathVariable Long poolTypeId) {
    return tournamentPoolService.getPoolUsers(tournamentId, poolTypeId);
  }

  @PostMapping(value = "/{poolId}/addPosition/{positionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<TournamentPoolPosition> addPositionToPool(@PathVariable Long poolId,
                                                            @PathVariable Long positionId) {
    return tournamentPoolService.addPositionToPool(poolId, positionId);
  }

  @DeleteMapping(value = "/{poolId}/deletePosition/{tournamentPoolPositionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deletePositionFromPool(@PathVariable Long tournamentPoolPositionId) {
    tournamentPoolService.deletePositionFromPool(tournamentPoolPositionId);
  }


  @PostMapping(value = "/{poolId}/addUser/{userId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<TournamentPoolUser> addUserToPool(@PathVariable Long poolId,
                                                    @PathVariable Long userId) {
    return tournamentPoolService.addUserToPool(poolId, userId);
  }

  @DeleteMapping(value = "/{poolId}/deleteUser/{tournamentPoolUserId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteUserFromPool(@PathVariable Long tournamentPoolUserId) {
    tournamentPoolService.deleteUserFromPool(tournamentPoolUserId);
  }

}
