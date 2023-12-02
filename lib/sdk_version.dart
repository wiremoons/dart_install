//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
// Obtain the current 'stable' Dart SDK version.
library;
// URL to query for latest available 'stable' version is:
// https://storage.googleapis.com/dart-archive/channels/stable/release/latest/VERSION
//

import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' show Client;
import 'package:path/path.dart' as p;

// import local code
import 'package:dart_install/sys_utils.dart';

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
/// The display summary of all version data is via [displayVersions()] method.
/// To confirm if a Dart SDK version upgrade is available [displayUpgrade()] can be used.
///
/// [_sdkVersion]       : Current 'stable' Dart SDK version available for download
/// [_sdkDate]          : Current 'stable' Dart SDK version release date
/// [_sdkRevision]      : Current 'stable' Dart SDK version revision number
/// [_executingVersion] : The Dart SDK version being used to execute this program
/// [_installedVersion] : Any identified Dart SDK version install on the computer
class SdkVersion {
  late String _sdkVersion;
  late String _sdkDate;
  late String _sdkRevision;
  late String _executingVersion;
  late String _installedVersion;

  SdkVersion() {
    _sdkVersion = "";
    _sdkDate = "";
    _sdkRevision = "";
    _installedVersion = "";
    _executingVersion = _executingSdk();
  }

  /// Obtain Dart SDK data and populate SDK info for all class variables.
  Future<void> populate() async {
    await _getSdkJsonData().then((String rawJson) {
      Map<String, dynamic> jsonResponse =
          json.decode(rawJson) as Map<String, dynamic>;
      final sdkData = JsonDataModel.fromJson(jsonResponse);
      _sdkVersion = sdkData.version;
      _sdkDate = sdkData.date;
      _sdkRevision = sdkData.revision;
    });
    _installedVersion = await _installedSdk();
  }

  /// Return the stored Dart SDK values from call fields.
  get version => _sdkVersion;
  get date => _sdkDate;
  get revision => _sdkRevision;
  get installed => _executingVersion;

  /// Output the current available Dart SDK and the local version data.
  ///
  /// [_sdkVersion] and [_sdkDate] are the current 'stable' Dart SDK available for download.
  /// [_installedVersion] is any locally installed Dart SDK or 'Not Found' if none.
  /// [_executingVersion] the version of Dart that is executing this script or AOT compiled program.
  void displayVersions() {
    if (_sdkVersion.isNotEmpty && _executingVersion.isNotEmpty) {
      stdout.writeln("\nDart SDK version status:\n");
      stdout.writeln("Available: '${_sdkVersion}' [${_sdkDate}]");
      stdout.writeln("Installed: '${_installedVersion}'");
      stdout.writeln("Executing: '${_executingVersion}'");
    }
  }

  /// Display information about any possible Dart SDK upgrade.
  ///
  /// Uses function [_canUpgrade()] to decide what output to use for any Dart SDK upgrade availability.
  void displayUpgrade() {
    if (_canUpgrade()) {
      stdout.writeln("\n [!]  Dart SDK upgrade is available.");
    } else {
      stdout.writeln("\n [✔]  Installed Dart SDK is the current version.");
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  //              PRIVATE CLASS METHODS BELOW
  /////////////////////////////////////////////////////////////////////////////

  /// Compare the available SDK version with the installed version to see
  /// if the strings match.
  ///
  /// If the two strings match then assume no upgrade is available.
  /// If either string is empty assume no upgrade is available.
  /// If no Dart SDK is installed current state is 'can be upgraded'.
  bool _canUpgrade() {
    if (_installedVersion == "Not Found") {
      return true;
    }
    if (_sdkVersion.isNotEmpty && _installedVersion.isNotEmpty) {
      return _sdkVersion == _installedVersion ? false : true;
    }
    return false;
  }

  /// Return the current Dart runtime version being executed.
  String _executingSdk() {
    return Platform.version.split(" ").first;
  }

  // return the version of any installed Dart SDK or 'Not Found'
  Future<String> _installedSdk() async {
    String installedSdkPath = await dartSdkPath();
    if (installedSdkPath.isEmpty) {
      return "Not Found";
    }
    // Have a Dart SDK location - check for 'version' file
    final dartSdkVersionFile = File(p.join(installedSdkPath, "version"));
    if (!await dartSdkVersionFile.exists()) {
      return "Not Found";
    }
    try {
      String sdkVersion = await (dartSdkVersionFile.readAsString());
      String newLineDelimiter = Platform.isWindows ? "\r\n" : "\n";
      return sdkVersion.replaceAll(newLineDelimiter, "");
    } catch (e) {
      stderr.writeln('failed to read file: \n${e}');
      return "Not Found";
    }
  }

  /// Convert a URL string to a Dart URI.
  ///
  /// The provided [url] string is  returned as a Dart [Uri]. Program exits
  /// if the conversion fails.
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
