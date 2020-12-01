package com.albatross.api.utils;

import com.google.api.client.util.Preconditions;
import com.google.common.collect.Lists;
import lombok.extern.slf4j.Slf4j;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.format.DateTimeParseException;
import java.util.Collection;

@Slf4j
public class ServiceDateUtils {
    public static final Collection<String> ACCEPTED_DATE_FORMATS = Lists.newArrayList("MM/dd/yyyy",
                                                                                      "yyyy-MM-dd",
                                                                                      "yyyyMMdd");
    public static final DateTimeFormatter DATE_FORMATTER = createFormatter(ACCEPTED_DATE_FORMATS);

    public static LocalDate parseDate(String s) {
        Preconditions.checkArgument(s != null, "Cannot parse empty string");

        try {
            return LocalDate.parse(s, DATE_FORMATTER);
        } catch (DateTimeParseException e) {}

        String errorMsg = String.format("DATE_PARSER: Could not parse '%s' as a recognized date string; format must be one of: %s",
                s, ACCEPTED_DATE_FORMATS);
        log.warn(errorMsg);
        throw new IllegalArgumentException(errorMsg);
    }

    private static DateTimeFormatter createFormatter(Collection<String> formats) {
        DateTimeFormatterBuilder builder = new DateTimeFormatterBuilder();
        for (String s : formats)
            builder.optionalStart()
                   .appendPattern(s)
                   .optionalEnd();
        return builder.toFormatter();
    }
}
