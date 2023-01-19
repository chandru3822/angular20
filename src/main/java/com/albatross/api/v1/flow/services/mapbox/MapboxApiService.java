package com.albatross.api.v1.flow.services.mapbox;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.mapbox.api.geocoding.v5.models.GeocodingResponse;
import com.mapbox.geojson.Feature;
import com.mapbox.geojson.FeatureCollection;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class MapboxApiService {

  @Value(value = "${mapbox.token}")
  private String MAPBOX_ACCESS_TOKEN;

  @Value(value = "${mapbox.tilesetId}")
  private String MAPBOX_TILESET_ID;

  public List<Double> getLatLong(String address) throws Exception {
    try {
      String urlEncodedAddress = URLEncoder.encode(address, StandardCharsets.UTF_8);
      String url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/"
          + urlEncodedAddress
          + ".json?access_token="
          + MAPBOX_ACCESS_TOKEN;
      log.debug("MAPBOX: Geocoding API Request: {}", url);
      HttpResponse resp = HttpUtils.call("GET", url);
      if (resp.getResponseCode() != 200) {
        log.error("MAPBOX: Error response code {}", resp.getResponseCode());
        throw new Exception(resp.getBody());
      }
      JSONObject data = resp.getJSON();

      GeocodingResponse formattedData = GeocodingResponse.fromJson(data.toString());

      List<Double> coordinates = new ArrayList<>();
      if (formattedData.features().size() > 0
            && null != formattedData.features().get(0)
            && null != formattedData.features().get(0).center()) {
        coordinates =
          Objects.requireNonNull(formattedData.features().get(0).center()).coordinates();
      }
      // remember that these are reversed as long,lat
      return coordinates;

    } catch (Exception ex) {
      log.error("MAPBOX: Error retrieving lat long.", ex);
      throw ex;
    }
  }

  public String getAddressSuggestions(String address) throws Exception {
    try {
      int limit = 5;
      String types = "address";
      String proximity = "ip";
      String language = "en";
      boolean autocomplete = true;
      boolean fuzzyMatch = true;

      String urlEncodedAddress = URLEncoder.encode(address, StandardCharsets.UTF_8);
      String url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/"
          + urlEncodedAddress
          + ".json?access_token="
          + MAPBOX_ACCESS_TOKEN
          + "&limit="
          + limit
          + "&types="
          + types
          + "&proximity="
          + proximity
          + "&autocomplete="
          + autocomplete
          + "&fuzzyMatch="
          + fuzzyMatch
          + "&language="
          + language;
      log.debug("MAPBOX: Geocoding Suggestions API Request: {}", url);
      HttpResponse resp = HttpUtils.call("GET", url);
      if (resp.getResponseCode() != 200) {
        log.error("MAPBOX: Error Suggestion response code {}", resp.getResponseCode());
        throw new Exception(resp.getBody());
      }
      JSONObject data = resp.getJSON();
//i couldnt get this mapper to work for some reason
//      GeocodingResponse formattedData = GeocodingResponse.fromJson(data.toString());

      return data.toString();

    } catch (Exception ex) {
      log.error("MAPBOX: Error retrieving suggestions.", ex);
      throw ex;
    }
  }

  public String getDriveTime(String latLongPairs) throws Exception {
    try {
      String urlEncodedPairs = URLEncoder.encode(latLongPairs, StandardCharsets.UTF_8);
      String url =
        "https://api.mapbox.com/directions/v5/mapbox/driving/"
          + urlEncodedPairs
          + "?access_token="
          + MAPBOX_ACCESS_TOKEN;
      log.debug("MAPBOX: Geocoding Drive Time Request: {}", url);
      HttpResponse resp = HttpUtils.call("GET", url);
      if (resp.getResponseCode() != 200) {
        log.error("MAPBOX: Drive Time Error response code {}", resp.getResponseCode());
        throw new Exception(resp.getBody());
      }
      JSONObject data = resp.getJSON();

//      DirectionsResponse formattedData = DirectionsResponse.fromJson(data.toString());

      return data.toString();

    } catch (Exception ex) {
      log.error("MAPBOX: Error retrieving drive time.", ex);
      throw ex;
    }
  }

  public String getTimezone(Double latitude, Double longitude) throws Exception {
    try {
      String url =
        "https://api.mapbox.com/v4/"
          + MAPBOX_TILESET_ID
          + "/tilequery/"
          + longitude
          + ","
          + latitude
          + ".json?radius=25&limit=5&dedupe&access_token="
          + MAPBOX_ACCESS_TOKEN;
      log.debug("MAPBOX: Tilequery API Request: {}", url);
      HttpResponse resp = HttpUtils.call("GET", url);
      if (resp.getResponseCode() != 200) {
        throw new Exception(resp.getBody());
      }
      JSONObject data = resp.getJSON();

      FeatureCollection formattedData = FeatureCollection.fromJson(data.toString());
      String timezone = null;
      if (null != formattedData
            && null != formattedData.features()
            && formattedData.features().size() > 0
            && null != formattedData.features().get(0)) {
        Feature firstFeature = formattedData.features().get(0);
        if (null != firstFeature.properties() && null != firstFeature.properties().get("tzid")) {
          timezone = firstFeature.properties().get("tzid").getAsString();
        }
      }

      return timezone;
    } catch (Exception ex) {
      log.error("MAPBOX: Error retrieving lat long.", ex);
      throw ex;
    }
  }

  public Optional<MapboxGeoResponse> getLatLongAndTimezone(String address) throws Exception {
    final List<Double> latLong = getLatLong(address);
    if (latLong != null && latLong.size() == 2) {
      final Double lng = latLong.get(0);
      final Double lat = latLong.get(1);

      String timezone = null;
      if (lat != null && lng != null) {
        try {
          timezone = getTimezone(lat, lng);
        } catch (Exception e) {
          //do nothing because the getTimezone function already logged this error
        }
      }
      return Optional.of(new MapboxGeoResponse(lng, lat, timezone));
    }
    return Optional.empty();
  }
}
