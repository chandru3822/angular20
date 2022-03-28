package com.albatross.api.v1.company.blueraven.models.wellsfargo;

import java.util.List;

public interface FlatFileRecord {
  RecordType getRecordId();

  List<Object> getFields();
}
