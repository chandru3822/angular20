package com.albatross.api.model;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class ImageOptions {
  private final Long w;
  private final Long h;
  private final Long q;
  private final Long dpr;
  private final ImageFormat ext;

  public String getParams() {
    List<String> params = new ArrayList<>();
    if (w != null) {
      params.add(String.format("w:%d", w));
    }

    if (h != null) {
      params.add(String.format("h:%d", w));
    }

    if (q != null) {
      params.add(String.format("q:%d", q));
    }

    if (ext != null) {
      params.add(String.format("ext:%s", ext));
    }

    if (dpr != null && dpr > 0) {
      params.add(String.format("dpr:%s", dpr));
    }

    return String.join("/", params);
  }
}
