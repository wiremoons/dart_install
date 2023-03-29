//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
/// Remove the Dart SDK installation and the supporting cache files.
//

import 'dart:io';
import 'yesno.dart';
import 'package:path/path.dart' as p;

// import local code
import 'package:dart_install/sdk_install.dart';

// remove provided directory path
Future<void> removeDir(String removePath) async {
  if (removePath.isNotEmpty && await Directory(removePath).exists()) {
    // existing matching path found - check with user if removal is ok
    stdout.writeln(" [!]  Existing directory found: '${removePath}'");
    if (yesNo(question: "Remove exising installation")) {
      stdout.writeln(" [*]  Deleting: ${removePath}");
      try {
        Directory(removePath).deleteSync(recursive: true);
        stdout.writeln(" [✔]  Removal successful.");
      } catch (err) {
        stderr
            .writeln("\n\n ❌ ERROR: unable to remove directory: '${err}'.\n\n");
        return;
      }
    } else {
      stderr.writeln(
          "\n ❌ ERROR: user declined to remove directory: ${removePath}.\n\n");
      return;
    }
  } else {
    stderr.writeln(
        "\n  ERROR: provided path '${removePath}' does not exists - deletion failure.");
  }
}

///////////////////////////////////////////////////////////////////////////////
//
//                   sdk_remove.dart - primary function entry point
//
///////////////////////////////////////////////////////////////////////////////

Future<void> removeSdk() async {
  stdout.writeln("\nDart SDK removal starting...");
  final envHomePath = Platform.environment["HOME"];
  stdout.writeln(" [*]  Locating the Dart SDK installation directory");
  final String sdkPath = await dartSdkPath();
  stdout.writeln(" [*]  Setting the 'pub-cache' installation directory");
  final String pubcachePath = p.join("$envHomePath", ".pub-cache");
  stdout.writeln(" [*]  Setting the 'dartServer' installation directory");
  final String dartServerPath = p.join("$envHomePath", ".dartServer");
  // remove the different SDK paths
  stdout.writeln(" [*]  All removal paths set - starting deletion...");
  await removeDir(sdkPath);
  await removeDir(pubcachePath);
  await removeDir(dartServerPath);
  stdout.writeln(" [✔]  Removal of Dart SDK completed.\n");
}
