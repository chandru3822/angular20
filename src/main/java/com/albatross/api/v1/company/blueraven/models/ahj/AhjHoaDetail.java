package com.albatross.api.v1.company.blueraven.models.ahj;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class AhjHoaDetail extends AhjHoa {
  private List<AhjLink> links;
  private List<AhjContact> contacts;
}
