package com.albatross.api.exceptions;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value= HttpStatus.CONFLICT, reason="Email already exists") //404
public class EmailInUseException extends Exception {

		private static final long serialVersionUID = -3332292346834265371L;

		public EmailInUseException(String email, String type){
			super(type + " already exists: " + email);
		}

}
