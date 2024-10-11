package com.albatross.api.v1.company.blueraven.models.featDB;

import com.albatross.api.v1.flow.model.User;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@Getter
@Setter
public class AhjNewHomeDetail extends AhjNewHome {
  private List<FeatDbLink> links;
  private List<FeatDbContact> contacts;
}
