package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.enums.TemplatingEngine;
import lombok.Getter;
import lombok.Setter;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class SendTextsRequest {
	List<Long> userIDs;
	TemplatingEngine templatingEngine;
	String message;
	List<URI> mediaURLs = new ArrayList<>();
	Long smsTeamId;
}
