import 'dart:convert';

class WebViewRequestModel {
  String type;
  String url;
  String method;
  String? body;
  Map<String, String>? headers;

  WebViewRequestModel({
    required this.type,
    required this.url,
    required this.method,
    this.body,
    this.headers,
  });

  factory WebViewRequestModel.fromJson(Map<dynamic, dynamic> json) {
    return WebViewRequestModel(
      type: json["type"],
      url: json["url"],
      method: json["method"],
      body: json["body"] is Map ? jsonEncode(json["body"]) : json["body"],
      headers: json["headers"] == null
          ? null
          : Map.fromEntries(
              (json["headers"] as Map).entries.map((e) => MapEntry(e.key.toString(), e.value.toString()))),
    );
  }

  Map<String, dynamic> toJson() => {
        "type": type,
        "url": url,
        "method": method,
        "body": body,
        "headers": headers,
      };
}
