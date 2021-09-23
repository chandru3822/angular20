package com.albatross.api.v1.flow.services.mapbox;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.mapbox.api.geocoding.v5.models.GeocodingResponse;
import com.mapbox.geojson.Feature;
import com.mapbox.geojson.FeatureCollection;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;


@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class MapboxApiService {

  @Value(value = "${mapbox.token}")
  private String MAPBOX_ACCESS_TOKEN;

  @Value(value = "${mapbox.tilesetId}")
  private String MAPBOX_TILESET_ID;

  public List<Double> getLatLong(String address) throws Exception {
    try {
      String urlEncodedAddress = URLEncoder.encode(address, StandardCharsets.UTF_8);
      String url = "https://api.mapbox.com/geocoding/v5/mapbox.places/" + urlEncodedAddress + ".json?access_token=" + MAPBOX_ACCESS_TOKEN;
      HttpResponse resp = HttpUtils.call("GET", url);
      if (resp.getResponseCode() != 200) {
        throw new Exception(resp.getBody());
      }
      JSONObject data = resp.getJSON();

      GeocodingResponse formattedData = GeocodingResponse.fromJson(data.toString());

      List<Double> coordinates = new ArrayList<>();
      if(formattedData.features().size() > 0 && null != formattedData.features().get(0) && null != formattedData.features().get(0).center()) {
         coordinates = Objects.requireNonNull(formattedData.features().get(0).center()).coordinates();
      }
      //remember that these are reversed as long,lat
      return coordinates;

    } catch (Exception ex) {
      log.error("MAPBOX: Error retrieving lat long.", ex);
      throw ex;
    }
  }

  public String getTimezone(Double latitude, Double longitude) throws Exception {
    try {
      String url = "https://api.mapbox.com/v4/" + MAPBOX_TILESET_ID + "/tilequery/" + longitude + "," + latitude + ".json?radius=25&limit=5&dedupe&access_token=" + MAPBOX_ACCESS_TOKEN;
      HttpResponse resp = HttpUtils.call("GET", url);
      if (resp.getResponseCode() != 200) {
        throw new Exception(resp.getBody());
      }
      JSONObject data = resp.getJSON();

      FeatureCollection formattedData = FeatureCollection.fromJson(data.toString());
      String timezone = null;
      if(null != formattedData && null != formattedData.features() && null != formattedData.features().get(0)) {
        Feature firstFeature = formattedData.features().get(0);
        if(null != firstFeature.properties() && null != firstFeature.properties().get("TZID")) {
          timezone = firstFeature.properties().get("TZID").getAsString();
        }
      }

      return timezone;
    } catch (Exception ex) {
      log.error("MAPBOX: Error retrieving lat long.", ex);
      throw ex;
    }
  }

}
