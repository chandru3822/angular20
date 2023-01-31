package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.client.utils.URIBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class SqueezeService {

  //@Value(value = "${squeeze.api.host}")
  //private String apiUrl;

  public void postContact(HashMap<String, Object> contactMap) {
    SimpleDateFormat formatterDate= new SimpleDateFormat("MM/dd/yyyy");
    String contactId = contactMap.remove("id").toString();

    try {
      URIBuilder b = new URIBuilder( "AddToList");//URIBuilder b = new URIBuilder(apiUrl + "AddToList");
      b.addParameter("F9domain", "Squeeze Media");
      b.addParameter("F9list", "Blue Raven Solar Post");
      b.addParameter("F9CallASAP", "true");
      b.addParameter("F9key", "SRC");
      b.addParameter("F9key", "number1");
      b.addParameter("SRC", "OB BLUE RAVEN");
      b.addParameter("first_name", contactMap.remove("first_name").toString());
      b.addParameter("last_name", contactMap.remove("last_name").toString());

      String phoneNumber = contactMap.remove("phone").toString();
      if (phoneNumber.startsWith("1")) {
        phoneNumber = phoneNumber.substring(1);
      }

      b.addParameter("number1", phoneNumber);
      b.addParameter("Loaded", formatterDate.format(new Date()));
      b.addParameter("Email", contactMap.remove("email").toString());
      b.addParameter("state", contactMap.remove("state").toString());
      b.addParameter("street", contactMap.remove("street1").toString());
      b.addParameter("zip", contactMap.remove("postal_code").toString());
      b.addParameter("city", contactMap.remove("city").toString());
      b.addParameter("LEADID", contactId);
      b.addParameter("Created Date", formatterDate.format(new Date()));
      b.addParameter("Lead Source", contactMap.remove("lead_source").toString());
      b.addParameter("Lead Status", contactMap.remove("lead_status").toString());
      //HttpResponse resp = POST(b.build().toString().replaceAll("\\+", "%20"), null);
    } catch (Exception e) {
      log.error(
        "SQUEEZE: Error in posting contactId={}, msg={}",
        contactId,
        e.getMessage());
    }
  }

  private HttpResponse request(String method, String url, InputStream content) throws Exception {
    log.debug("SQUEEZE: sending to Squeeze url: {}", url);
    Map<String, String> headers = new HashMap<>();
    return HttpUtils.call(method, url, headers, content);
  }

  public HttpResponse POST(String url, InputStream content) throws Exception {
    return request("POST", url, content);
  }
}
