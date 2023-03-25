//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
// Obtain the current 'stable' Dart SDK 'CHANGELOG.md'.
// URL to query for latest available 'stable' version is:
// https://raw.githubusercontent.com/dart-lang/sdk/stable/CHANGELOG.md
//

import 'dart:core';
import 'dart:io';
import 'package:http/http.dart' show Client;

/// URL for CHANGELOG.md Dart SDK stable releases:
const String _changeLogUrl =
    "https://raw.githubusercontent.com/dart-lang/sdk/stable/CHANGELOG.md";

class ChangeLog {
  late String _changeLogText;

  ChangeLog() {
    _changeLogText = "";
  }

  /// Obtain Dart SDK changelog data
  Future<void> populate() async {
    final allLogText = await _getChangeLogData();
    List<String> changeList = allLogText.split("## ");
    _changeLogText = changeList.elementAt(1).trim();
  }

  /// Return the stored Dart SDK chnagelog text.
  get changeLog => _changeLogText;

  /// Display CHANGELOG.md information.
  ///
  void displayChangeLog() {
    if (_changeLogText.isNotEmpty) {
      stdout.writeln(
          "\n [✔]  Dart SDK latest change log entry is:\n\n${_changeLogText}");
    } else {
      stdout.writeln("\n [!]  No change log data found✅.");
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  //              PRIVATE CLASS METHODS BELOW
  /////////////////////////////////////////////////////////////////////////////

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
      stderr.writeln(
          "FATAL ERROR: Dart SDK CHANGELOG.md URL: 'url' parse error: ${err}");
      exit(1);
    }
  }

  /// Request the JSON data for the Dart SDK URL [_sdkUrl].
  ///
  /// Request the JSON data containing the current available stable Dart SDK
  /// version from the URL [_sdkUrl]. The URL is converted to a URI [_toUri] and the
  /// web page is requested. Return the body of the page received as a String.
  Future<String> _getChangeLogData() async {
    Client client = Client();
    final response = await client.get(_toUri(_changeLogUrl));
    if (response.statusCode == 200) {
      client.close();
      return response.body;
    } else {
      client.close();
      stderr.writeln(
          'FATAL ERROR: Dart SDK CHANGELOG.md web request failed with status: ${response.statusCode}.');
      exit(2);
    }
  }
}
