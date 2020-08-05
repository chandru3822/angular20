package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.enums.TemplatingEngine;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

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
