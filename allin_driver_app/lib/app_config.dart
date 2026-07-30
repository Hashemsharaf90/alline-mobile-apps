var this_year = DateTime.now().year.toString();

class AppConfig {
  static String copyright_text =
      "@ Allin $this_year"; //this shows in the splash screen
  static String app_name = "alline Delivery"; //this shows in the splash screen

  //Default language config
  static String default_language = "ar";
  static String mobile_app_code = "ar";
  static bool app_language_rtl = true;
  //configure this
  static String system_key = '123456';
  // "1ab838fc-e066-496c-bc70-43c9c8152550"; //enter your purchase code for the app from codecanyon

  //configure this
  static const bool HTTPS = true;

  static const DOMAIN_PATH =
      "new.allinye.com"; //enter your domain only without https://www.

  //do not configure these below
  static const String API_ENDPATH = "api/v1";
  static const String PUBLIC_FOLDER = "public";
  static const String DELIVERY_PREFIX = "delivery-boy";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  static const String RAW_BASE_URL = "$PROTOCOL$DOMAIN_PATH";
  static const String BASE_URL = "$RAW_BASE_URL/$API_ENDPATH";

  //configure this if you are using amazon s3 like services
  //give direct link to file like https://[[bucketname]].s3.ap-southeast-1.amazonaws.com/
  //otherwise do not change anythink
  static const String BASE_PATH = "$RAW_BASE_URL/$PUBLIC_FOLDER/";
}
