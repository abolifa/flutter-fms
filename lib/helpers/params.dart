enum NetworkStatus { online, offline }

class Constant {
  static String hostUrl = "http://10.0.2.2:8000/"; // Use Sail's exposed port
  static String baseUrl = "${hostUrl}api/";
  static String loginUrl = "${baseUrl}login";
  static String tanks = "${baseUrl}tanks";
  static String transactions = "${baseUrl}transactions";
}
