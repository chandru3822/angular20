package com.albatross.api.utils;

import java.util.regex.Pattern;

/**
 * Created by randa on 12/11/2020.
 */
public class CleanString {

  public static String replaceApostrophesAndRemoveNBSP(String textToBeCleaned) {
    if (textToBeCleaned == null){
      return null;
    }
    // \u00A0 represents a non-breaking space
    return textToBeCleaned.replace("\u00A0", " ").replace("’", "'").trim();
  }

  public static String cleanFilename(String filename) {
    if (filename == null){
      return null;
    }
    String cleanFilename = filename.replaceAll(",", "");
    cleanFilename = cleanFilename.replaceAll("’", "'");
    cleanFilename = cleanFilename.replaceAll("“", "\"");
    cleanFilename = cleanFilename.replaceAll("”", "\"");
    cleanFilename = cleanFilename.replaceAll("\u2006", ""); //replaces Six-Per-Em Space (cuz we had 25)
    cleanFilename = cleanFilename.replaceAll("\u200B", ""); //replaces a space that doesn't consume any width (cuz we had 1)
    cleanFilename = cleanFilename.replaceAll("\u200C", ""); //zero-width non-joiner (ZWNJ)
    cleanFilename = cleanFilename.replaceAll("\u200D", ""); //zero-width join (ZWJ)
    cleanFilename = cleanFilename.replaceAll("\u202F", ""); //replaces Narrow NBSP cuz WTF
    cleanFilename = cleanFilename.replaceAll("\uFEFF", ""); //zero-width non-breaking space (ZWNBSP)
    cleanFilename = cleanFilename.replaceAll("\u00A0", ""); //replaces NBSP
    cleanFilename = cleanFilename.replaceAll("\t", " ");
    cleanFilename = cleanFilename.replaceAll("\n", " ");
    cleanFilename = cleanFilename.replaceAll("%0A", " "); //this is a newline code as encoded by javascript (we cant url decode though because that causes issues when a filename has a valid % sign in the name)
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
