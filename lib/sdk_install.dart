//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
/// Install or re-install the current 'stable' Dart SDK version.
/// URL to download the latest macOS arm64 'stable' version is:
/// [https://storage.googleapis.com/dart-archive/channels/stable/release/2.18.5/sdk/dartsdk-macos-arm64-release.zip]
/// where the version shown [2.18.5] will be replaced when the SDK version is updated.
// Disable some specific linting rules in this file only
// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:io';
import 'package:path/path.dart' as p;

/// Create a the Dart SDK download URL for the current version specific to macOS arm64 install.
String createDownLoadUrl(String sdkVersion) {
  if (sdkVersion.isEmpty) return sdkVersion;
  return "https://storage.googleapis.com/dart-archive/channels/stable/release/${sdkVersion}/sdk/dartsdk-macos-arm64-release.zip";
}

/// Get the name of the downloaded file from the [downLoadUrl] created via the [createDownLoadUrl()] function
String installFileExtract(String downLoadUrl) {
  return downLoadUrl.isEmpty ? downLoadUrl : p.basename(downLoadUrl);
}

/// Locate the full path to the local Dart SDK installation
///
/// Check if the [DART_SDK] environment variable is set which can be used to identify the installed
/// Dart SDK location. If this exists it is used as it has been manually set, so should be good.
/// If no [DART_SDK] env exists, then search the PATH environment for the *dart* or *dart.exe* which if
/// available should be in the Dart SDK *bin/* sub directory.
Future<String> dartSdkPath() async {
  // check if 'DART_SDK' is set and exists
  final envDartSdkPath = Platform.environment["DART_SDK"];
  if (envDartSdkPath != null && envDartSdkPath.isNotEmpty) {
    // Check the dart exe exists in the sub directory 'bin/'
    if (await dartExeExists(p.join(envDartSdkPath, "bin"))){
      stderr.writeln(" [!]  WARNING: env 'DART_SDK' -> '${envDartSdkPath}' contains no 'dart' executable in a 'bin/' subdirectory");
    }
    // return what the user set anyway - as they know their computer best...
    return envDartSdkPath;
  }

  // check the environment PATH for 'dart' or 'dart.exe' file
  final envPath = Platform.environment["PATH"]?.split(":");
  if (envPath == null || envPath.isEmpty) return "";

  // check each environment PATH entry for a dart file - return on first found
  for (final path in envPath) {
    if (await dartExeExists(path)) {
      // the dart executable is normally in the Dart SDK 'bin/' sub directory - so trim the path
      final idx = path.lastIndexOf("/bin");
      return idx == -1 ? path : path.substring(0, idx);
    }
  }
  return "";
}

/// Confirm is the dart executable exists in the provided directory path [dirPath]
Future<bool> dartExeExists(String dirPath) async {
  // set correct dart executable name as different on Windows
  final dartExe = Platform.isWindows ? "dart.exe" : "dart";
  // check of the executable exists at the provided path
  final dartPath = File(p.join(dirPath, dartExe));
  return await dartPath.exists();
}

/// Perform the download and install of the current Dart SDk version.
Future<void> upgradeSdk(String sdkVersion) async {
  stdout.writeln("\nDart SDK installation starting...");
  stdout.writeln(" [*]  Installing Dart SDK version: '${sdkVersion}'");
  final String downLoadUrl = createDownLoadUrl(sdkVersion);
  if (downLoadUrl.isEmpty) {
    stderr.writeln("\n\n ❌ ERROR: Dart SDK download URL is missing\n");
    return;
  }
  final String sdkInstallFile = installFileExtract(downLoadUrl);
  final String existingDartSdkPath = await dartSdkPath();
  if (existingDartSdkPath.isNotEmpty) {
    // existing Dart SDK found - check with user if should remove first?
    stdout.writeln(
        " [!]  Existing Dart SDK install found: '${existingDartSdkPath}'");
  }
  // stdout.writeln(" [*]  Previously downloaded file found - re-using: ${sdkDownloadPath}/${sdkInstallFile}")
  stdout.writeln(" [*]  Dart SDK download URL: ${downLoadUrl}");
  stdout.writeln(" [*]  Dart SDk install file: ${sdkInstallFile}");
}
