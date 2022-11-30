//
// Copyright 2022 Simon Rowe (simon@wiremoons.com).
//
// Build exe with:
//   dart compile exe -DDART_BUILD="Built on: $(date)" ./bin/dart_install.dart -o ./build/dart_install.exe
// Run with:
//   dart run

import 'dart:io';
import 'package:args/args.dart';
import 'package:dart_install/version.dart';

const String applicationVersion = "0.1.0";

void main(List<String> arguments) {
  var parser = ArgParser();
  late var cliResults;

  parser.addFlag('version',
      abbr: 'v',
      negatable: false,
      defaultsTo: false,
      help: 'Display the applications version');
  parser.addFlag('help',
      abbr: 'h',
      negatable: false,
      help: 'Display addtional help information.', callback: (help) {
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
}
