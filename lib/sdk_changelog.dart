//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
// Obtain the current 'stable' Dart SDK 'CHANGELOG.md'.
library;
// URL to query for latest available 'stable' version is:
// https://raw.githubusercontent.com/dart-lang/sdk/stable/CHANGELOG.md

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

  /// Obtain Dart SDK changelog data and remove all text after the first markdown '##' heading.
  Future<void> populateLatest() async {
    final allLogText = await _getChangeLogData();
    List<String> changeList = allLogText.split("## ");
    _changeLogText = changeList.elementAt(1).trim();
  }

  /// Obtain the Dart SDK changelog data and keep all the markdown data (ie keep the whole file).
  Future<void> populate() async {
    final allLogText = await _getChangeLogData();
    _changeLogText = allLogText.isEmpty ? "" : allLogText;
  }

  /// Return the latest entry from the Dart SDK changlelog text markdown file.
  get changeLog => _changeLogText;

  /// Display whatever change log data was obtained (ie either [populate()] or [populateLatest()].
  ///
  void displayChangeLog() {
    if (_changeLogText.isNotEmpty) {
      stdout.writeln(
          "\n [✔]  Dart SDK latest change log entry is:\n\n${_changeLogText}");
    } else {
      stdout.writeln("\n [!]  No change log data found.");
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

  /// Request the markdown file containing changelog data for the URL [_changeLogUrl].
  ///
  /// Request the markdown data containing the complete changelog record for stable Dart SDK
  /// versions from the URL [_changeLogUrl]. The URL is converted to a URI [_toUri] and the
  /// web page is requested. Return the body of the page received (markdown file) as a String.
  Future<String> _getChangeLogData() async {
    Client client = Client();
    final response = await client.get(_toUri(_changeLogUrl));
    if (response.statusCode == 200) {
      client.close();
      return response.body;
    } else {
      client.close();
      stderr.writeln(
          '  [!] FATAL ERROR: Dart SDK CHANGELOG.md web request failed with status: ${response.statusCode}.');
      exit(2);
    }
  }
}
