package com.albatross.api.v1.company.blueraven.controllers.tournament;

import com.albatross.api.v1.company.blueraven.models.tournament.Match;
import com.albatross.api.v1.company.blueraven.models.tournament.Tournament;
import com.albatross.api.v1.company.blueraven.models.tournament.TournamentOwnerType;
import com.albatross.api.v1.company.blueraven.services.tournament.TournamentService;
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
@RequestMapping(value = "/api/v1/company/blueraven/tournament")
public class TournamentController {

  private final TournamentService tournamentService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Tournament> getTournaments() {
    return tournamentService.getTournaments();
  }

  @GetMapping(value = "/ownerTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<TournamentOwnerType> getTournamentOwnerTypes() {
    return tournamentService.getTournamentOwnerTypes();
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteTournament(@PathVariable Long id) {
    tournamentService.deleteTournament(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Tournament> updateTournament(@RequestBody Tournament tournament) {
    return tournamentService.updateTournament(tournament);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Tournament> addTournament(@RequestBody Tournament tournament) {
    return tournamentService.addTournament(tournament);
  }

  @GetMapping(value = "/active", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Tournament> getActiveTournaments() {
    return tournamentService.getActiveTournaments();
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Tournament> getTournament(@PathVariable Long id) {
    return tournamentService.getTournament(id);
  }

  @PutMapping(value = "/advance", produces = MediaType.APPLICATION_JSON_VALUE)
  public void advanceMatches(@RequestBody List<Match> matches) {
    tournamentService.advanceMatches(matches);
  }

}
