//
// Copyright 2022 Simon Rowe (simon@wiremoons.com).
//
// Obtain the current 'stable' Dart SDK version.
// URL to query for latest available 'stable' version is:
// https://storage.googleapis.com/dart-archive/channels/stable/release/latest/VERSION
//
// Disable some specific linting rules in this file only
// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' show Client;

// URL for current Dart SDK stable release:
const String _sdkUrl =
    "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/VERSION";

// Values parsed from the Dart SDK JSON web site response data
// Example returned JSON output:
// {
//   "date": "2022-12-13",
//   "version": "2.18.6",
//   "revision": "f16b62ea92cc0f04cfd9166992f93419e425c809"
// }
class JsonDataModel {
  final String date;
  final String version;
  final String revision;

  // default constructor to parse and extract value needed from JSON input
  JsonDataModel.fromJson(Map<String, dynamic> parsedJson)
      : date = parsedJson['date'],
        version = parsedJson['version'],
        revision = parsedJson['revision'];
}

// Obtain Dart SDK current stable version from web site and then make data available when requested
class SdkVersion {
  late String _sdkVersion;
  late String _sdkDate;
  late String _sdkRevision;
  late String _installedVersion;
  // Map<String, dynamic> jsonResponse = {};

  SdkVersion() {
    _sdkVersion = "";
    _sdkDate = "";
    _sdkRevision = "";
    _installedVersion = _getInstallSdkVersion();
  }

  // Obtain Dart SDK data and populate SDK info for class variables
  Future<void> getSdkVersionData() async {
    await _getSdkJsonData().then((String rawJson) {
      Map<String, dynamic> jsonResponse =
          json.decode(rawJson) as Map<String, dynamic>;
      final sdkData = JsonDataModel.fromJson(jsonResponse);
      _sdkVersion = sdkData.version;
      _sdkDate = sdkData.date;
      _sdkRevision = sdkData.revision;
    });
  }

  // return the stored Dart SDK values
  get version => _sdkVersion;
  get date => _sdkDate;
  get revision => _sdkRevision;
  get installed => _installedVersion;

  // return the current Dart runtime version
  String _getInstallSdkVersion() {
    return Platform.version.split(" ").first;
  }

  // Convert a URL string to a Dart Uri
  Uri _getSdkUri(String url) {
    Uri sdkUri;
    try {
      sdkUri = Uri.parse(url);
      return sdkUri;
    } catch (err) {
      stderr.writeln("FATAL ERROR: Dart SDK URL: 'url' parse error: ${err}");
      exit(1);
    }
  }

  // Request the web page data for the Dart SDK URL using costs value: `_sdkUrl`
  // Return the body of the page received as a String.
  Future<String> _getSdkJsonData() async {
    Client client = Client();
    final response = await client.get(_getSdkUri(_sdkUrl));
    if (response.statusCode == 200) {
      client.close();
      return response.body;
    } else {
      client.close();
      stderr.writeln(
          'FATAL ERROR: Dart SDK web request failed with status: ${response.statusCode}.');
      exit(2);
    }
  }
}
