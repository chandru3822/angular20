package com.albatross.api.v1.company.blueraven.models.featDB;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class HoaDetail extends Hoa {
  private List<FeatDbLink> links;
  private List<FeatDbContact> contacts;
}
