package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.services.mapbox.MapboxApiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/mapbox", produces = MediaType.APPLICATION_JSON_VALUE)
public class MapboxController {

  private final MapboxApiService mapboxApiService;

  @GetMapping(value = "/getLatLong")
  public List<Double> getLatLongFromAddress(@RequestParam String address) throws Exception {
    return mapboxApiService.getLatLong(address);
  }

  @GetMapping(value = "/getSuggestions")
  public String getAddressSuggestions(@RequestParam String address) throws Exception {
    return mapboxApiService.getAddressSuggestions(address);
  }

  @GetMapping(value = "/getDriveTime")
  public String getDriveTime(@RequestParam String latLongPairs) throws Exception {
    return mapboxApiService.getDriveTime(latLongPairs);
  }

}
