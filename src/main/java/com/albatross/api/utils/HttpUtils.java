package com.albatross.api.utils;

import org.apache.commons.io.IOUtils;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;

public class HttpUtils {
  public static HttpResponse call(String method, String url) throws Exception {
    return call(method, new URL(url));
  }

  public static HttpResponse call(String method, URL url) throws Exception {
    return call(method, url, null, null);
  }

  public static HttpResponse call(String method, String url, Map<String, String> headers) throws Exception {
    return call(method, new URL(url), headers);
  }

  public static HttpResponse call(String method, URL url, Map<String, String> headers) throws Exception {
    return call(method, url, headers, null);
  }

  public static HttpResponse call(String method, String url, Map<String, String> headers, InputStream content) throws Exception {
    return call(method, new URL(url), headers, content);
  }

  public static HttpResponse call(String method, URL url, Map<String, String> headers, InputStream content) throws Exception {

    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
    connection.setRequestMethod(method);

    if (content != null) {
      connection.setDoInput(true);
    }
    connection.setDoOutput(true);

    if (headers != null) {
      for (String headerKey : headers.keySet()) {
        connection.setRequestProperty(headerKey, headers.get(headerKey));
      }
    }

    connection.connect();
    if (content != null) {
      try (OutputStream output = connection.getOutputStream()) {
        IOUtils.copy(content, output);
      }
    }

    int responseCode = connection.getResponseCode();
    InputStream error = connection.getErrorStream();
    InputStream result = null;

    if (responseCode < 300) {
      result = connection.getInputStream();
    }

    return new HttpResponse(responseCode, result, error);
  }
}
