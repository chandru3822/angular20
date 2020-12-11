package com.albatross.api.utils;

/**
 * Created by dave on 4/27/17.
 */
public class CleanString {

    public static String replaceApostrophe(String textToBeCleaned) {
      if (textToBeCleaned == null){
        return null;
      }
      return textToBeCleaned.replace("’", "'");
    }
}
