//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
// Build exe with:
//   dart compile exe -DDART_BUILD="Built on: $(date)" ./bin/dart_install.dart -o ./build/dart_install.exe
// Run with:
//   dart run

// Disable some specific linting rules in this file only
// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_string_interpolations
import 'dart:io';
import 'package:args/args.dart';
import 'package:dav/dav.dart';

// import local code
import 'package:dart_install/sdk_install.dart';
import 'package:dart_install/sdk_version.dart';

const String applicationVersion = "0.6.0";

void main(List<String> arguments) async {
  var parser = ArgParser();
  late ArgResults cliResults;

  parser.addFlag('check',
      abbr: 'c',
      negatable: false,
      defaultsTo: false,
      help: 'Check for any new Dart SDK version.');
  parser.addFlag('install',
      abbr: 'i',
      negatable: false,
      defaultsTo: false,
      help: 'Install (or upgrade via replacement) with the latest Dart SDK.');
  parser.addFlag('version',
      abbr: 'v',
      negatable: false,
      defaultsTo: false,
      help: 'Display this applications version details.');
  parser.addFlag('help',
      abbr: 'h',
      negatable: false,
      help: 'Display additional help information.', callback: (help) {
    if (help) {
      stdout.writeln(
          "\nProgram installs or upgrades via replacement the Dart SDK to the latest version.\n");
      stdout.writeln("Usage:\n${parser.usage}\n");
      stdout.writeln("Copyright © 2023 Simon Rowe <simon@wiremoons.com>");
      stdout.writeln("https://github.com/wiremoons/dart_install");
      exit(0);
    }
  });

  try {
    cliResults = parser.parse(arguments);
  } catch (e) {
    stderr.writeln("\nERROR: unknown exception '${e}'");
    stderr.writeln("\nValid options are:\n${parser.usage}");
    exit(1);
  }

  // display application version information if requested on the command line
  if (cliResults.wasParsed('version')) {
    final version = Dav(appVersion: applicationVersion);
    version.display();
    exit(0);
  }

  // display available Dart SDK version and the installed current one
  if (cliResults.wasParsed('check')) {
    final sdkver = SdkVersion();
    await sdkver.populate();
    sdkver.displayVersions();
    sdkver.displayUpgrade();
    exit(0);
  }

  // Install or reinstall the latest Dart SDk version
  if (cliResults.wasParsed('install')) {
    final sdkver = SdkVersion();
    await sdkver.populate();
    sdkver.displayVersions();
    sdkver.displayUpgrade();
    await upgradeSdk(sdkver.version);
    exit(0);
  }

  // managed any unexpected additional arguments
  if (cliResults.rest.isNotEmpty) {
    stderr.writeln(
        "\nERROR: no command matches input: '${cliResults.rest.toString()}'");
    stderr.writeln("\nValid options are:\n${parser.usage}");
    exit(2);
  }

  // no command line options selected so just exit the application
  stderr.writeln("\nValid options are:\n${parser.usage}");
  exit(0);
}
