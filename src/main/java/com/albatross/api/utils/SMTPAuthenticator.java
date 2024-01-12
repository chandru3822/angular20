package com.albatross.api.utils;

import jakarta.mail.PasswordAuthentication;

public class SMTPAuthenticator extends jakarta.mail.Authenticator {

	private String userName;
	private String password;

	public SMTPAuthenticator(String userName, String password){
		this.userName = userName;
		this.password = password;
	}

    public PasswordAuthentication getPasswordAuthentication() {
       return new PasswordAuthentication(userName, password);
    }
}
