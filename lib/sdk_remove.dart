//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
/// Remove the Dart SDK installation and the supporting cache files.
//

// Disable some specific linting rules in this file only
// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_string_interpolations
import 'dart:io';
import 'yesno.dart';
import 'package:path/path.dart' as p;

// import local code
import 'package:dart_install/sys_utils.dart';

// remove provided directory path
Future<void> removeDir(String removePath) async {
  if (removePath.isNotEmpty && await Directory(removePath).exists()) {
    // existing matching path found - check with user if removal is ok
    stdout.writeln(" [!]  Existing directory found: '${removePath}'");
    if (yesNo(question: "Remove existing installation")) {
      try {
        stdout.writeln(" [*]  Deleting: ${removePath}");
        await Directory(removePath).delete(recursive: true);
        stdout.writeln(" [✔]  Removal successful.\n");
      } catch (err) {
        stderr.writeln(
            "\n\n [!] ERROR: unable to remove directory: '${err}'.\n\n");
        return;
      }
    } else {
      stderr.writeln(
          "\n [!] ERROR: user declined to remove directory: ${removePath}.\n\n");
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

// TDOO(Simon) : locate on Windows the paths for supporting Dart SDK directories
Future<void> removeSdk() async {
  stdout.writeln("\nDart SDK removal starting...");
  final envHomePath = homePathLocation();
  stdout.writeln(" [*]  Locating the Dart SDK installation directory");
  final String sdkPath = await dartSdkPath();
  stdout.writeln(" [*]  Locating the 'pub-cache' installation directory");
  final String pubcachePath = p.join("$envHomePath", ".pub-cache");
  stdout.writeln(" [*]  Locating the 'dartServer' installation directory");
  final String dartServerPath = p.join("$envHomePath", ".dartServer");
  stdout.writeln(" [*]  Locating the 'dart-tool' installation directory");
  final String dartToolPath = p.join("$envHomePath", ".dart-tool");
  stdout.writeln(" [*]  Locating the 'dart' installation directory");
  final String dartHomePath = p.join("$envHomePath", ".dart");
  // remove the different SDK paths
  stdout.writeln(" [*]  All removal paths set - starting deletion...\n");
  await removeDir(sdkPath);
  await removeDir(pubcachePath);
  await removeDir(dartServerPath);
  await removeDir(dartToolPath);
  await removeDir(dartHomePath);
  stdout.writeln(
      " [✔]  Removal of Dart SDK and supporting directory infrastructure completed.\n");
}
