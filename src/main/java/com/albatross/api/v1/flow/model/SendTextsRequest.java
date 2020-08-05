package com.blueraven.view.api.v1.dto.admin;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import com.blueraven.enums.TemplatingEngine;

public class SendTextsRequest {
	List<Long> userIDs;
	TemplatingEngine templatingEngine;
	String message;
	List<URI> mediaURLs = new ArrayList<>();

	public List<Long> getUserIDs() {
		return userIDs;
	}

	public void setUserIDs(List<Long> userIDs) {
		this.userIDs = userIDs;
	}

	public TemplatingEngine getTemplatingEngine() {
		return templatingEngine;
	}

	public void setTemplatingEngine(TemplatingEngine templatingEngine) {
		this.templatingEngine = templatingEngine;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public List<URI> getMediaURLs() {
		return mediaURLs;
	}

	public void setMediaURLs(List<URI> mediaURLs) {
		this.mediaURLs = mediaURLs;
	}

}
