package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
public class DensitySearch {

  private Double upperBoundLatitude, upperBoundLongitude, lowerBoundLatitude, lowerBoundLongitude;
  private List<Long> companyProjectStatusTypeIds;

}
