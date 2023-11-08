package com.albatross.api.utils;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
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
    String cleanFilename = URLDecoder.decode(filename, StandardCharsets.UTF_8); //this removes some special javascript formatting like turning \n into %0A, then we can handle the \n normally after
    cleanFilename = cleanFilename.replaceAll(",", "");
    cleanFilename = cleanFilename.replaceAll("’", "'");
    cleanFilename = cleanFilename.replaceAll("“", "\"");
    cleanFilename = cleanFilename.replaceAll("”", "\"");
    cleanFilename = cleanFilename.replaceAll("\u202F", " "); //replaces Narrow NBSP cuz WTF
    cleanFilename = cleanFilename.replaceAll("\u00A0", " "); //replaces NBSP
    cleanFilename = cleanFilename.replaceAll("\t", " ");
    cleanFilename = cleanFilename.replaceAll("\n", " ");
    cleanFilename = cleanFilename.replaceAll("\r", " ");
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
