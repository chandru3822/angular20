package com.albatross.api.utils;

import com.mapbox.api.geocoding.v5.MapboxGeocoding;
import com.mapbox.api.geocoding.v5.models.CarmenFeature;
import com.mapbox.api.geocoding.v5.models.GeocodingResponse;
import com.mapbox.geojson.Point;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import java.util.List;
import java.util.function.Consumer;
import java.util.function.ObjLongConsumer;

@Slf4j
@Component
public class LocationUtils {

  @Value(value = "${mapbox.token}")
  private String MAPBOX_ACCESS_TOKEN;

  public void getGeocode(String address, Long id, ObjLongConsumer callbackFunction) {
    //todo: neither of these options are working

//    try {
//      URL url = new URL("https://api.mapbox.com/geocoding/v5/mapbox.places/Los%20Angeles.json?access_token="+MAPBOX_ACCESS_TOKEN);
//      Map<String, String> headers = new HashMap<>();
//      headers.put("Content-Type", "application/json");
//      String payload = "{}";
//      HttpResponse httpResponse = HttpUtils.call("GET", url, headers, new ByteArrayInputStream(payload.getBytes(Charset.forName("UTF-8"))));
//
//      log.info("hello there: {}", httpResponse);
//    } catch (Exception xx) {
//      log.info("failure: {}", xx);
//    }

    MapboxGeocoding mapboxGeocoding = MapboxGeocoding.builder()
        .accessToken(MAPBOX_ACCESS_TOKEN)
        .query(address)
        .build();

    mapboxGeocoding.enqueueCall(new Callback<GeocodingResponse>() {
      @Override
      public void onResponse(Call<GeocodingResponse> call, Response<GeocodingResponse> response) {
        List<CarmenFeature> results = response.body().features();
        if (results.size() > 0) {
          Point firstResultPoint = results.get(0).center();
          log.info("result point: {}", firstResultPoint.toString());
          //todo: firstResultPoint is defined with everything I need, but I can't figure out how to return it.
          callbackFunction.accept(firstResultPoint, id);
        } else {
          // No results for your request were found.
          log.error("GEO_CODE_ERROR: No result found");
        }
      }

      @Override
      public void onFailure(Call<GeocodingResponse> call, Throwable throwable) {
        throwable.printStackTrace();
      }
    });
  }

}
