package com.albatross.api.utils;

import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;

@Slf4j
public class HttpResponse {

    int responseCode;
    InputStream resultStream;
    InputStream errorStream;

    public HttpResponse(int responseCode, InputStream resultStream,
                        InputStream errorStream) {
        super();
        this.responseCode = responseCode;
        this.resultStream = resultStream;
        this.errorStream = errorStream;
    }

    public int getResponseCode() {
        return responseCode;
    }

    public void setResponseCode(int responseCode) {
        this.responseCode = responseCode;
    }

    public InputStream getResultStream() {
        return resultStream;
    }

    public void setResultStream(InputStream resultStream) {
        this.resultStream = resultStream;
    }

    public InputStream getErrorStream() {
        return errorStream;
    }

    public void setErrorStream(InputStream errorStream) {
        this.errorStream = errorStream;
    }

    public String getBody() throws IOException {
        String body = null;

        if (resultStream != null) {
            body = IOUtils.toString(resultStream);
        } else if (errorStream != null) {
            body = IOUtils.toString(errorStream);
        } else {
            log.warn("HTTP: [{}] no response body found", responseCode);
        }

        return body;
    }

    public JSONObject getJSON() throws JSONException, IOException {
        String body = getBody();

        if (body == null) {
            return null;
        }

        return new JSONObject(body);
    }

    public JSONArray getJSONArray() throws JSONException, IOException {
        String body = getBody();

        if (body == null) {
            return null;
        }

        return new JSONArray(body);
    }
}
