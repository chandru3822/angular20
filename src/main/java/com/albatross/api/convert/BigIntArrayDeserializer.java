package com.albatross.api.convert;

import java.beans.PropertyEditorSupport;
import java.sql.Array;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class BigIntArrayDeserializer extends PropertyEditorSupport {

  @Override
  public void setValue(Object value) {
    if (value == null) {
      super.setValue(Collections.emptyList());
      return;
    }

    try {
      if (value instanceof String) {
        String stringValue = (String) value;
        if (stringValue.equals("{}")) {
          super.setValue(Collections.emptyList());
          return;
        }

        String[] stringValues = stringValue.substring(1, stringValue.length() - 1).split(",");
        List<Long> longList = new ArrayList<>();

        for (String str : stringValues) {
          try {
            longList.add(Long.parseLong(str.trim()));
          } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid number in bigint[]: " + str, e);
          }
        }

        super.setValue(longList);
        return;
      }

      if (value instanceof Array) {
        Array sqlArray = (Array) value;
        Object arrayObj = sqlArray.getArray();

        if (arrayObj instanceof Long[]) {
          super.setValue(List.of((Long[]) arrayObj));
        } else if (arrayObj instanceof Number[]) {
          Number[] numbers = (Number[]) arrayObj;
          List<Long> longList = new ArrayList<>();
          for (Number num : numbers) {
            longList.add(num.longValue());
          }
          super.setValue(longList);
        } else {
          throw new IllegalArgumentException("Unexpected array type: " + arrayObj.getClass().getName());
        }
        return;
      }

      throw new IllegalArgumentException("Unsupported type for BigIntArrayDeserializer: " + value.getClass().getName());

    } catch (SQLException e) {
      throw new IllegalArgumentException("Error reading SQL Array", e);
    }
  }
}
