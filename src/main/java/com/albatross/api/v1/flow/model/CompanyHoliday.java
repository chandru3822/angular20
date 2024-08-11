package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
public class CompanyHoliday {
  Long id;
  String name;
  Date date;
  Long companyId;
  Boolean archived;
}
