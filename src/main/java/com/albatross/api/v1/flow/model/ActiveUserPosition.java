package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ActiveUserPosition {

	private Long id;
	private String firstName, lastName, email, isPrimary;
}
