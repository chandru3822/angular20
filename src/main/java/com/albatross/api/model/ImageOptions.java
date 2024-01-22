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
      params.add("w:%d".formatted(w));
    }

    if (h != null) {
      params.add("h:%d".formatted(w));
    }

    if (q != null) {
      params.add("q:%d".formatted(q));
    }

    if (ext != null) {
      params.add("ext:%s".formatted(ext));
    }

    if (dpr != null && dpr > 0) {
      params.add("dpr:%s".formatted(dpr));
    }

    return String.join("/", params);
  }
}
