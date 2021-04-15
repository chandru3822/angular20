package com.albatross.api.v1.company.blueraven.controllers.tournament;

import com.albatross.api.v1.company.blueraven.models.tournament.*;
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

  @GetMapping(value = "/{id}/columns", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getFormulaColumns(@PathVariable Long id) {
    return tournamentService.getFormulaColumns(id);
  }

  @GetMapping(value = "/{tournamentId}/scores", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getUserScores(@PathVariable Long tournamentId,
                            @RequestParam Long userId,
                            @RequestParam String startDate,
                            @RequestParam String endDate) {
    return tournamentService.getUserScores(tournamentId, userId, startDate, endDate);
  }

  @GetMapping(value = "/ownerTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<TournamentOwnerType> getTournamentOwnerTypes() {
    return tournamentService.getTournamentOwnerTypes();
  }

  @GetMapping(value = "/formulas/{ownerTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<TournamentFormula> getTournamentFormulas(@PathVariable Long ownerTypeId) {
    return tournamentService.getTournamentFormulas(ownerTypeId);
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

  //brackets
  @GetMapping(value = "/{tournamentId}/brackets", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getBrackets(@PathVariable Long tournamentId) {
    return tournamentService.getBrackets(tournamentId);
  }

  @PostMapping(value = "/bracket", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Bracket> addBracket(@RequestBody Bracket bracket) {
    return tournamentService.addBracket(bracket);
  }

  @PostMapping(value = "/bracket/replicate", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Bracket> replicateBracket(@RequestBody Bracket bracket) {
    return tournamentService.replicateBracket(bracket);
  }

  @DeleteMapping(value = "/bracket/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteBracket(@PathVariable Long id) {
    tournamentService.deleteBracket(id);
  }

  //rounds
  @PutMapping(value = "/round", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Bracket> saveRound(@RequestBody Round round) {
    return tournamentService.saveRound(round, false);
  }

  @PutMapping(value = "/round/{id}/delete", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Bracket> deleteRound(@RequestBody Round round) {
    //has to be a put cuz we need data back after the delete
    return tournamentService.deleteRound(round);
  }

  //matches
  @PutMapping(value = "/bracket/{id}/generateMatches", produces = MediaType.APPLICATION_JSON_VALUE)
  public void generateMatches(@PathVariable Long id) {
    tournamentService.generateMatches(id);
  }

  @PutMapping(value = "/{tournamentId}/round/{roundId}/advanceWinners", produces = MediaType.APPLICATION_JSON_VALUE)
  public void advanceWinners(@PathVariable Long tournamentId,
                             @PathVariable Long roundId,
                             @RequestBody List<Match> matches) {
    tournamentService.advanceWinners(tournamentId, roundId, matches);
  }

  @PutMapping(value = "/{tournamentId}/advance", produces = MediaType.APPLICATION_JSON_VALUE)
  public void advanceMatches(@PathVariable Long tournamentId,
                             @RequestBody List<Match> matches) {
    tournamentService.advanceMatches(tournamentId, matches);
  }
}
