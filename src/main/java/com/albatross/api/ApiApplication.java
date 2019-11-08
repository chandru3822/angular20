package com.albatross.api;

import org.joda.time.DateTimeZone;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.TimeZone;

@SpringBootApplication
public class ApiApplication {

	public static TimeZone TIMEZONE = TimeZone.getTimeZone("UTC");

	public static void main(String[] args) {
		TimeZone.setDefault(TIMEZONE);
		DateTimeZone.setDefault(DateTimeZone.forTimeZone(TIMEZONE));
		SpringApplication.run(ApiApplication.class, args);
	}

}
