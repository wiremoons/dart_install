//
// Copyright 2022 Simon Rowe (simon@wiremoons.com).
//
// Build exe with:
//   dart compile exe -DDART_BUILD="Built on: $(date)" ./bin/dart_install.dart -o ./build/dart_install.exe
// Run with:
//   dart run

// Disable some specific linting rules in this file only
// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_string_interpolations
import 'dart:io';
import 'package:args/args.dart';

// import local code
import 'package:dart_install/version.dart';
import 'package:dart_install/sdk_version.dart';

const String applicationVersion = "0.2.0";

void main(List<String> arguments) async {
  var parser = ArgParser();
  late ArgResults cliResults;

  parser.addFlag('check',
      abbr: 'c',
      negatable: false,
      defaultsTo: false,
      help: 'Check for new Dart SDK version.');
  parser.addFlag('version',
      abbr: 'v',
      negatable: false,
      defaultsTo: false,
      help: 'Display the applications version.');
  parser.addFlag('help',
      abbr: 'h',
      negatable: false,
      help: 'Display additional help information.', callback: (help) {
    if (help) {
      stdout.writeln(
          "\nProgram installs the Dart SDK to the computer it is run from.\n");
      stdout.writeln("Usage:\n${parser.usage}\n");
    }
  });

  try {
    cliResults = parser.parse(arguments);
  } catch (e) {
    stderr.writeln("ERROR: unknown exception '${e}'");
    stderr.writeln("${parser.usage}");
    exit(1);
  }

  if (cliResults.wasParsed('version')) {
    final version = Version(appVersion: applicationVersion);
    version.display();
    exit(0);
  }
  if (cliResults.wasParsed('check')) {
    final sdkver = SdkVersion();
    await sdkver.getSdkVersionData();
    stdout.writeln("Available: '${sdkver.version}' [${sdkver.date}]");
    stdout.writeln("Installed: '${sdkver.installed}'");
  }
  exit(0);
}
