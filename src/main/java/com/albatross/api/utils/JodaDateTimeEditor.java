package com.albatross.api.v1.flow.utils;

import org.joda.time.DateTimeZone;
import org.joda.time.LocalDateTime;

import java.beans.PropertyEditorSupport;

public class JodaDateTimeEditor extends PropertyEditorSupport {
    @Override
    public void setValue(Object value) {
        if (value != null) {
            value = new LocalDateTime(value).toDateTime(DateTimeZone.UTC);
        }
        super.setValue(value);
    }
}
