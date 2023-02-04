//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
// Obtain the current 'stable' Dart SDK version.
// URL to query for latest available 'stable' version is:
// https://storage.googleapis.com/dart-archive/channels/stable/release/latest/VERSION
//

import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' show Client;
import 'package:path/path.dart' as p;

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
  late String _executingVersion;
  late String _installedVersion;
  // Map<String, dynamic> jsonResponse = {};

  SdkVersion() {
    _sdkVersion = "";
    _sdkDate = "";
    _sdkRevision = "";
    _installedVersion = "";
    _executingVersion = executingSdk();
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
    _installedVersion = await installedSdk();
  }

  // return the stored Dart SDK values
  get version => _sdkVersion;
  get date => _sdkDate;
  get revision => _sdkRevision;
  get installed => _executingVersion;

  // output the current available Dart SDK and the version installed.
  void displayVersions() {
    if (_sdkVersion.isNotEmpty && _executingVersion.isNotEmpty) {
      stdout.writeln("\nDart SDK version status:\n");
      stdout.writeln("Available: '${_sdkVersion}' [${_sdkDate}]");
      stdout.writeln("Installed: '${_installedVersion}'");
      stdout.writeln("Executing: '${_executingVersion}'");
    }
  }

  /// Compare the available SDk version with the installed version to see
  /// of the strings match.
  ///
  /// If the two strings match then assume no upgrade is available.
  /// If either string is empty assume no upgrade is available.
  bool _canUpgrade() {
    if (_installedVersion == "Not Found") {
      return false;
    }
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
  String executingSdk() {
    return Platform.version.split(" ").first;
  }

  // return the version of any installed Dart SDK or 'Not Found'
  Future<String> installedSdk() async {
    String installedSdkPath = await _dartSdkPath();
    if (installedSdkPath.isEmpty) {
      return "Not Found";
    }
    // Have Dart SDK location - check for 'version' file
    final dartSdkVersionFile = File(p.join(installedSdkPath, "version"));
    if (!await dartSdkVersionFile.exists()) {
      return "Not Found";
    }
    try {
      String sdkVersion = await (dartSdkVersionFile.readAsString());
      return sdkVersion.replaceAll("\n", "");
    } catch (e) {
      stderr.writeln('failed to read file: \n${e}');
      return "Not Found";
    }
  }

  /// Locate the full path to the local Dart SDK installation
  ///
  /// Check if the [DART_SDK] environment variable is set which can be used to identify the installed
  /// Dart SDK location. If this exists it is used as it has been manually set, so should be good.
  /// If no [DART_SDK] env exists, then search the PATH environment for the *dart* or *dart.exe* which if
  /// available should be in the Dart SDK *bin/* sub directory.
  Future<String> _dartSdkPath() async {
    // check if 'DART_SDK' is set and exists
    final envDartSdkPath = Platform.environment["DART_SDK"];
    if (envDartSdkPath != null && envDartSdkPath.isNotEmpty) {
      // Check the dart exe exists in the sub directory 'bin/'
      if (await _dartExeExists(p.join(envDartSdkPath, "bin"))) {
        stderr.writeln(
            " [!]  WARNING: env 'DART_SDK' -> '${envDartSdkPath}' contains no 'dart' executable in a 'bin/' subdirectory");
      }
      // return what the user set anyway - as they know their computer best...
      return envDartSdkPath;
    }
    //
    // DART_SDK env failed!
    // check the environment PATH for 'dart' or 'dart.exe' file
    final envPath = Platform.environment["PATH"]?.split(":");
    if (envPath == null || envPath.isEmpty) return "";
    //
    // final path = envPath.firstWhere((path) => await _dartExeExists(path), orElse: () => "");
    //
    // check each environment PATH entry for a dart file - return on first found
    for (final path in envPath) {
      if (await _dartExeExists(path)) {
        // the dart executable is normally in the Dart SDK 'bin/' sub directory - so trim the path
        final idx = path.lastIndexOf("/bin");
        return idx == -1 ? path : path.substring(0, idx);
      }
    }
    return "";
  }

  /// Confirm if the dart executable exists in the provided directory path [dirPath]
  /// Additionally check if executing on Windows so [.exe] can be appended to [dart] first.
  Future<bool> _dartExeExists(String dirPath) async {
    // set correct dart executable name as different on Windows
    final dartExe = Platform.isWindows ? "dart.exe" : "dart";
    // check of the executable exists at the provided path
    final dartPath = File(p.join(dirPath, dartExe));
    return await dartPath.exists();
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
