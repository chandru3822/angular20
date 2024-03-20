package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

@Data
public class AppointmentType {
  String name;
  Long id;

  public AppointmentType(String name, Long id){
    this.name = name;
    this.id = id;
  }
}
