package com.albatross.api.utils;

import com.mapbox.api.geocoding.v5.MapboxGeocoding;
import com.mapbox.api.geocoding.v5.models.CarmenFeature;
import com.mapbox.api.geocoding.v5.models.GeocodingResponse;
import com.mapbox.api.tilequery.MapboxTilequery;
import com.mapbox.geojson.Feature;
import com.mapbox.geojson.FeatureCollection;
import com.mapbox.geojson.Point;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import java.util.List;
import java.util.function.ObjLongConsumer;

@Slf4j
@Component
public class LocationUtils {

  @Value(value = "${mapbox.token}")
  private String MAPBOX_ACCESS_TOKEN;

  @Value(value = "${mapbox.tilesetId}")
  private String MAPBOX_TILESET_ID;

  public void getGeocode(String address, Long id, ObjLongConsumer callbackFunction) {
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
          callbackFunction.accept(firstResultPoint, id);
        } else {
          // No results for your request were found.
          log.error("GEO_CODE_ERROR: No result found");
        }
      }

      @Override
      public void onFailure(Call<GeocodingResponse> call, Throwable throwable) {
        log.error("GEO: failure {}", throwable.getMessage());
        throwable.printStackTrace();
      }
    });
  }

  public void getTimezoneByLatLong(Long id, Double longitude, Double latitude, ObjLongConsumer callbackFunction) {
    MapboxTilequery tilequery = MapboxTilequery.builder()
      .accessToken(MAPBOX_ACCESS_TOKEN)
      .tilesetIds(MAPBOX_TILESET_ID)
      .query(Point.fromLngLat(longitude,latitude))
      .radius(25)
      .dedupe(true)
      .build();

      tilequery.enqueueCall(new Callback<FeatureCollection>() {
        @Override public void onResponse(Call<FeatureCollection> call, Response<FeatureCollection> response) {
          List<Feature> featureList = response.body().features();
          if (null != featureList && featureList.size() > 0) {
            Feature firstFeature = featureList.get(0);
            callbackFunction.accept(firstFeature, id);
          } else {
            // No results for your request were found.
            log.error("GEO_CODE_ERROR: No result found");
          }
        }

        @Override public void onFailure(Call<FeatureCollection> call, Throwable throwable) {
          log.error("GEO: tileset failure {}", throwable.getMessage());
          throwable.printStackTrace();
        }
    });
  }

}
