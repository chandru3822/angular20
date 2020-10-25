package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Position;
import com.albatross.api.v1.flow.services.PositionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn 10/1/19
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/position")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class PositionController {

  private final PositionService positionService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Position> getPositionsForCompany() {
    return positionService.getPositionsForCompany();
  }

  @GetMapping(value = "/schedulable", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Position> getSchedulablePositions() {
    return positionService.getSchedulablePositions();
  }

  @GetMapping(value = "/withParent", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Position> getPositionsForCompanyWithParent() {
    return positionService.getPositionsForCompanyWithParent();
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Position getPosition(@PathVariable Long id) {
    return positionService.getPosition(id);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Position insertPosition(@RequestBody Position p) {
    return positionService.insertPosition(p);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Position updatePosition(@RequestBody Position p) {
    return positionService.updatePosition(p);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deletePosition(@PathVariable Long id) {
    positionService.deletePosition(id);
  }

}
