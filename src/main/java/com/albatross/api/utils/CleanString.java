package com.albatross.api.utils;

import java.util.regex.Pattern;

/**
 * Created by randa on 12/11/2020.
 */
public class CleanString {

  public static String replaceApostrophe(String textToBeCleaned) {
    if (textToBeCleaned == null){
      return null;
    }
    return textToBeCleaned.replace("’", "'");
  }

  public static String cleanFilename(String filename) {
    if (filename == null){
      return null;
    }
    String cleanFilename = filename.replace(",", "");
    cleanFilename = cleanFilename.replace("’", "'");
    cleanFilename = cleanFilename.replace("“", "\"");
    cleanFilename = cleanFilename.replace("”", "\"");
    return cleanFilename;
  }

  public static String cleanPhone(String phoneNumber) {
    if (phoneNumber == null){
      return null;
    }
    String cleanPhoneNumber = phoneNumber.replaceAll("[^0-9]", "");
    //if the resulting cleaned value if not a valid phone number return null
    //todo: future dev make this work for international numbers
    if(cleanPhoneNumber.isBlank() || cleanPhoneNumber.length() < 10 || cleanPhoneNumber.length() > 11) {
      return null;
    }
    return cleanPhoneNumber;
  }

  public static String snakeToCamel(String snakeCase) {
    return Pattern.compile("_([a-z])")
      .matcher(snakeCase)
      .replaceAll(match -> match.group(1).toUpperCase());
  }
}
