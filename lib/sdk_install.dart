//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
/// Install or re-install the current 'stable' Dart SDK version.
/// URL to download the latest macOS arm64 'stable' version is:
/// [https://storage.googleapis.com/dart-archive/channels/stable/release/2.18.5/sdk/dartsdk-macos-arm64-release.zip]
/// where the version shown [2.18.5] will be replaced when the SDK version is updated.
//
// Disable some specific linting rules in this file only
// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:math';
import 'dart:io';
import 'package:path/path.dart' as p;

/// Create a the Dart SDK download URL for the current version specific to macOS arm64 install.
String createDownLoadUrl(String sdkVersion) {
  if (sdkVersion.isEmpty) return sdkVersion;
  return "https://storage.googleapis.com/dart-archive/channels/stable/release/${sdkVersion}/sdk/dartsdk-macos-arm64-release.zip";
}

/// Get the name of the downloaded file from the [downLoadUrl] created via the [createDownLoadUrl()] function.
/// Uses [basenameWithoutExtension] to extract just the filename (no extension) from the end of the [downLoadUrl]. The
/// version of the SDK being obtained is then appended, and the '.zip' added back on the end to complete the
/// whole filename construct.
String installFileNameExtract(String downLoadUrl, String sdkVersion) {
  return downLoadUrl.isEmpty
      ? downLoadUrl
      : ("${p.basenameWithoutExtension(downLoadUrl)}-${sdkVersion}.zip");
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
    if (await dartExeExists(p.join(envDartSdkPath, "bin"))) {
      stderr.writeln(
          " [!]  WARNING: env 'DART_SDK' -> '${envDartSdkPath}' contains no 'dart' executable in a 'bin/' subdirectory");
    }
    // return what the user set anyway - as they know their computer best...
    return envDartSdkPath;
  }

  // check the environment PATH for 'dart' or 'dart.exe' file
  final envPath = Platform.environment["PATH"]?.split(":");
  if (envPath == null || envPath.isEmpty) return "";

  // final path = envPath.firstWhere((path) => await dartExeExists(path), orElse: () => "");

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

/// Confirm if the dart executable exists in the provided directory path [dirPath]
/// Additionally check if executing on Windows so [.exe] can be appended to [dart] first.
Future<bool> dartExeExists(String dirPath) async {
  // set correct dart executable name as different on Windows
  final dartExe = Platform.isWindows ? "dart.exe" : "dart";
  // check of the executable exists at the provided path
  final dartPath = File(p.join(dirPath, dartExe));
  return await dartPath.exists();
}

/// Provide the path to a directory to download the new Dart SDK install file into.
/// Will use [$HOME/scratch] by default - will create if it does not exist.
Future<String> setDownLoadPath() async {
  final homePath = Platform.environment["HOME"];
  if (homePath == null || homePath.isEmpty) return "";

  // check for $HOME/scratch - create it if does not exist
  final downLoadPath = p.join(homePath, "scratch");
  if (!await Directory(downLoadPath).exists()) {
    stdout.writeln(" [!]  Creating download directory: '${downLoadPath}'");
    await Directory(downLoadPath).create(recursive: true);
  }
  return downLoadPath;
}

/// Download the file at provided URL [downLoadUrl] to the local file path and name
/// provided as [downLoadFilePath]. Any exisitng file at [downLoadFilePath] will be
/// over written without checking. Returns [true] when completed.
Future<bool> downloadSDk(String downLoadFilePath, String downLoadUrl) async {
  final request = await HttpClient().getUrl(Uri.parse(downLoadUrl));
  final response = await request.close();
  stdout.write(" -->  Downloading Dart SDK install file... please wait");
  await response.pipe(File(downLoadFilePath).openWrite());
  stdout.write("\r                                                      \r");
  return true;
}

Future<String> getFileSize(String filePath, int displayDecimals) async {
  int bytes = await File(filePath).length();
  if (bytes <= 0) return "0 B";
  const sizeSuffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return "${(bytes / pow(1024, i)).toStringAsFixed(displayDecimals)} ${sizeSuffixes[i]}";
}

/// Perform the download and install of the current Dart SDk version.
/// Requires the current Dart SDK version available is provied to the function as [sdkVersion].
Future<void> upgradeSdk(String sdkVersion) async {
  stdout.writeln("\nDart SDK installation starting...");
  stdout.writeln(" [*]  Installing Dart SDK version: '${sdkVersion}'");
  final String downLoadUrl = createDownLoadUrl(sdkVersion);
  if (downLoadUrl.isEmpty) {
    stderr.writeln("\n\n ❌ ERROR: Dart SDK download URL is missing\n");
    return;
  }
  // set up supporting paths and data before executing
  final String sdkInstallFile = installFileNameExtract(downLoadUrl, sdkVersion);
  final String existingDartSdkPath = await dartSdkPath();
  final String downLoadFilePath =
      p.join(await setDownLoadPath(), sdkInstallFile);
  if (existingDartSdkPath.isNotEmpty) {
    // existing Dart SDK found - check with user if should remove first?
    stdout.writeln(
        " [!]  Existing Dart SDK install found: '${existingDartSdkPath}'");
    // TODO : confirm can remove existing Dart SDK - if not abort.
  }
  stdout.writeln(" [*]  Dart SDK download URL: ${downLoadUrl}");
  stdout.writeln(" [*]  Dart SDk install file: ${sdkInstallFile}");
  stdout.writeln(" [*]  Dart SDK download destination: ${downLoadFilePath}");
  // check for an existing downloaded file - use if exists otherwise download new.
  if (await File(downLoadFilePath).exists()) {
    stdout.writeln(
        " [!]  Re-using found previously downloaded file: ${downLoadFilePath}");
  } else {
    if (!await downloadSDk(downLoadFilePath, downLoadUrl)) {
      stderr.writeln("\n\n ❌ ERROR: Dart SDK download failed\n");
      return;
    }
    stdout.writeln(" [✔]  Dart SDK download completed successfully");
  }
  stdout.writeln(
      " [*]  Dart SDK download file size: ${await getFileSize(downLoadFilePath, 1)}");
}
