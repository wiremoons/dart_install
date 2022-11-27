//
// Copyright 2022 Simon Rowe (simon@wiremoons.com).
//
// Build exe with:
//   dart compile exe -DDART_BUILD="Built on: $(date)" ./bin/dart_install.dart
// Run with:
//   dart ./bin/dart_install.dart

import 'package:args/args.dart';
import 'package:dart_install/version.dart';

const String applicationVersion = "0.1.0";

void main(List<String> arguments) {
  var version = Version(appVersion: applicationVersion);
  version.display();
}
