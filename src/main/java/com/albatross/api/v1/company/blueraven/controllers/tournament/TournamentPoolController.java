package com.albatross.api.v1.company.blueraven.controllers.tournament;

import com.albatross.api.v1.company.blueraven.enums.tournament.TournamentPoolType;
import com.albatross.api.v1.company.blueraven.models.tournament.TournamentPool;
import com.albatross.api.v1.company.blueraven.services.tournament.TournamentPoolService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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

  @GetMapping(value = "/qualifying", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<TournamentPool> getQualifyingPoolDetails(@PathVariable Long tournamentId) {
    return tournamentPoolService.getPoolDetails(tournamentId, TournamentPoolType.QUALIFYING.getId());
  }

  @GetMapping(value = "/lastChance", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<TournamentPool> getLoserPoolDetails(@PathVariable Long tournamentId) {
    return tournamentPoolService.getPoolDetails(tournamentId, TournamentPoolType.LAST_CHANCE.getId());
  }

  @GetMapping(value = "/winner", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<TournamentPool> getWinnerPoolDetails(@PathVariable Long tournamentId) {
    return tournamentPoolService.getPoolDetails(tournamentId, TournamentPoolType.WINNER.getId());
  }

}
