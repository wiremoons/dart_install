//
// Copyright 2022 Simon Rowe (simon@wiremoons.com).
//
// Obtain the current 'stable' Dart SDK version.
// URL to query for latest available 'stable' version is:
// https://storage.googleapis.com/dart-archive/channels/stable/release/latest/VERSION
//
// Disable some specific linting rules in this file only
// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' show Client;

/// URL for current Dart SDK stable release:
const String _sdkUrl =
    "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/VERSION";

/// Parse values from the Dart SDK JSON web site response.
///
/// Example returned JSON output:
/// ```json
/// {
///   "date": "2022-12-13",
///   "version": "2.18.6",
///   "revision": "f16b62ea92cc0f04cfd9166992f93419e425c809"
/// }
/// ```
class JsonDataModel {
  final String date;
  final String version;
  final String revision;

  /// Default constructor to parse and extract values needed from JSON input
  JsonDataModel.fromJson(Map<String, dynamic> parsedJson)
      : date = parsedJson['date'],
        version = parsedJson['version'],
        revision = parsedJson['revision'];
}

/// Obtain Dart SDK current stable version and local installed version.
///
/// From the Dart SDK web site [_sdkUrl] obtain the current stable version
/// [_sdkVersion], its release date [_sdkDate], and the SDK revision
/// [_sdkRevision]. The Dart SDK version information is managed via the
/// [populate] method. Once run the obtained data is made available via getters.
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
    _installedVersion = installedSdk();
  }

  // Obtain Dart SDK data and populate SDK info for class variables
  Future<void> populate() async {
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

  // output the current available Dart SDK and the version installed.
  void displayVersions() {
    if (_sdkVersion.isNotEmpty && _installedVersion.isNotEmpty) {
      stdout.writeln("\nDart SDK version status:\n");
      stdout.writeln("Available: '${_sdkVersion}' [${_sdkDate}]");
      stdout.writeln("Installed: '${_installedVersion}'");
    }
  }

  /// Compare the available SDk version with the installed version to see
  /// of the strings match.
  ///
  /// If the two strings match then assume no upgrade is available.
  /// If either string is empty assume no upgrade is available.
  bool _canUpgrade() {
    if (_sdkVersion.isNotEmpty && _installedVersion.isNotEmpty) {
      return _sdkVersion == _installedVersion ? false : true;
    }
    return false;
  }

  /// Display information about any possible Dart SDK upgrade.
  ///
  /// Uses function [_canUpgrade()] to display an appropriate message about any Dart SDK upgrade
  /// availability.
  void displayUpgrade() {
    if (_canUpgrade()) {
      stdout.writeln("\n⚠️   Dart SDK upgrade is available.");
    } else {
      stdout.writeln("\n✅  Installed Dart SDK is the current version.");
    }
  }

  // return the current Dart runtime version
  String installedSdk() {
    return Platform.version.split(" ").first;
  }

  /// Convert a URL string to a Dart URI.
  ///
  /// The provided [url] string is  returned as a Dart [Uri]. Program exits
  /// if the conversion fails, as without a valid URL or URI the  program is
  /// pointless.
  Uri _toUri(String url) {
    Uri sdkUri;
    try {
      sdkUri = Uri.parse(url);
      return sdkUri;
    } catch (err) {
      stderr.writeln("FATAL ERROR: Dart SDK URL: 'url' parse error: ${err}");
      exit(1);
    }
  }

  /// Request the JSON data for the Dart SDK URL [_sdkUrl].
  ///
  /// Request the JSON data containing the current available stable Dart SDK
  /// version from the URL [_sdkUrl]. The URL is converted to a URI [_toUri] and the
  /// web page is requested. Return the body of the page received as a String.
  Future<String> _getSdkJsonData() async {
    Client client = Client();
    final response = await client.get(_toUri(_sdkUrl));
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
