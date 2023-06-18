//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
/// Install or replace (by re-installation) the current 'stable' Dart SDK version.
/// URL to download the latest macOS arm64 'stable' version is:
/// [https://storage.googleapis.com/dart-archive/channels/stable/release/2.18.5/sdk/dartsdk-macos-arm64-release.zip]
/// where the version shown [2.18.5] will be replaced when the SDK version is updated.
/// URL for Raspberry Pi aarch64 on Ubuntu is:
/// [https://storage.googleapis.com/dart-archive/channels/stable/release/2.18.5/sdk/dartsdk-linux-arm64-release.zip]
//

import 'dart:math';
import 'dart:io';
import 'yesno.dart';
import 'unzip.dart';
import 'package:path/path.dart' as p;

/// Create a the Dart SDK download URL for the current version specific to current running OS
/// and the CPU architecture - assuming either Intel x64 or arm64 where Dart SDK make choices available.
String createDownLoadUrl(String sdkVersion) {
  if (sdkVersion.isEmpty) return sdkVersion;
  if (Platform.isMacOS) {
    return Platform.version.contains("arm64")
        ? "https://storage.googleapis.com/dart-archive/channels/stable/release/${sdkVersion}/sdk/dartsdk-macos-arm64-release.zip"
        : "https://storage.googleapis.com/dart-archive/channels/stable/release/${sdkVersion}/sdk/dartsdk-macos-x64-release.zip";
  }
  if (Platform.isLinux) {
    return Platform.version.contains("arm64")
        ? "https://storage.googleapis.com/dart-archive/channels/stable/release/${sdkVersion}/sdk/dartsdk-linux-arm64-release.zip"
        : "https://storage.googleapis.com/dart-archive/channels/stable/release/${sdkVersion}/sdk/dartsdk-linux-x64-release.zip";
  }
  if (Platform.isWindows) {
    return "https://storage.googleapis.com/dart-archive/channels/stable/release/${sdkVersion}/sdk/dartsdk-windows-x64-release.zip";
  }
  // no match found so return empty string.
  return "";
}

/// Construct the local file name to be used to identify the downloaded Dart SDK install zip file.
///
/// Get the name of the file from the [downLoadUrl] created via the [createDownLoadUrl()] function.
/// Uses the 'path package' function [basenameWithoutExtension] to extract just the filename (no extension) from
/// the end of the [downLoadUrl]. The version of the SDK being obtained is then appended, and the '.zip' added
/// back on the end to complete the whole filename construct.
String installFileNameExtract(String downLoadUrl, String sdkVersion) {
  return downLoadUrl.isEmpty
      ? downLoadUrl
      : ("${p.basenameWithoutExtension(downLoadUrl)}-${sdkVersion}.zip");
}

/// Change installed Dart SDK files to have executable permission as: 755.
///
/// Dart has no ability to change a file permissions so the Unix command line program `chmod` is called
/// instead. The provided [file] name has its permissions set to `755`.
Future<void> makeExecutable(File file) async {
  if (!Platform.isWindows) {
    ProcessResult result = await Process.run("chmod", ["755", file.path]);
    if (result.exitCode != 0) {
      stderr.writeln(
          "\n\n [!] ERROR: failed to set execute file permissions for file: '${file}' due to: '${result.stderr}'");
    }
  }
}

/// Locate the full path to the local Dart SDK installation.
///
/// Check if the [DART_SDK] environment variable is set which can be used to identify the installed
/// Dart SDK location. If this exists it is used as it will have been manually set, so should be good.
/// If no [DART_SDK] env exists, then search the [PATH] environment for the *dart* or *dart.exe* files
/// which if available, should be in the Dart SDK *bin/* sub directory.
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
  // Finding [DART_SDK] env failed!
  // check the environment [PATH] for 'dart' or 'dart.exe' file
  final envPath = Platform.environment["PATH"]?.split(":");
  if (envPath == null || envPath.isEmpty) return "";
  //
  // final path = envPath.firstWhere((path) => await dartExeExists(path), orElse: () => "");
  //
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

/// Check the provided [dirPath] for a file named *dart.exe* or *dart*.
///
/// Confirm if the dart executable exists in the provided directory path [dirPath]
/// Additionally check if executing on Windows so [.exe] can be appended to [dart] first.
Future<bool> dartExeExists(String dirPath) async {
  // set correct dart executable name as different on Windows
  final dartExe = Platform.isWindows ? "dart.exe" : "dart";
  // check of the executable exists at the provided path
  final dartPath = File(p.join(dirPath, dartExe));
  return await dartPath.exists();
}

/// Identify a suitable directory to download and save the Dart SDK archive file too.
///
/// Return the path to a directory to download the new Dart SDK install file into.
/// Will use [$HOME/scratch] by default - will create it if it does not exist.
Future<String> setDownLoadPath() async {
  final homePath = Platform.environment["HOME"];
  if (homePath == null || homePath.isEmpty) return "";
  //
  // check for $HOME/scratch - create it if does not exist
  final downLoadPath = p.join(homePath, "scratch");
  if (!await Directory(downLoadPath).exists()) {
    stdout.writeln(" [!]  Creating download directory: '${downLoadPath}'");
    await Directory(downLoadPath).create(recursive: true);
  }
  return downLoadPath;
}

/// Check for and create if needed the Dart SDK install location of [HOME/.dart].
///
/// Provide the path to a directory to extract and install the new Dart SDK archive file into.
/// Will use [$HOME/.dart] by default - will create if it does not exist.
Future<String> setSdkInstallDir() async {
  final homePath = Platform.environment["HOME"];
  if (homePath == null || homePath.isEmpty) return "";
  //
  // check for $HOME/.dart - create it if does not exist
  final destSdkDirectory = p.join(homePath, ".dart");
  if (!await Directory(destSdkDirectory).exists()) {
    stdout.writeln(" [!]  Creating download directory: '${destSdkDirectory}'");
    await Directory(destSdkDirectory).create(recursive: true);
  }
  return destSdkDirectory;
}

/// Download the file at the URL [downLoadUrl] to the local path [downLoadFilePath].
///
/// Download the file at provided URL [downLoadUrl] to the local file path and name
/// provided as [downLoadFilePath]. Any existing file at [downLoadFilePath] will be
/// over written without checking. Returns [true] when completed.
Future<bool> downloadSDk(String downLoadFilePath, String downLoadUrl) async {
  try {
    final request = await HttpClient().getUrl(Uri.parse(downLoadUrl));
    final response = await request.close();
    stdout.write(" -->  Downloading Dart SDK install file... please wait");
    await response.pipe(File(downLoadFilePath).openWrite());
    stdout.write("\r                                                      \r");
    return true;
  } catch (e) {
    stderr.writeln(
        "\n\n [!] ERROR: failed to download file: '${downLoadUrl}' due to: '${e}'");
    return false;
  }
}

/// Show the size of a file with the correct suffix such as 'MB' or 'GB' etc
//
// For the provided filename and path check the file size and return it as a String
// with an appended suffix to reflect if it is 'MB', 'TB', etc.
Future<String> getFileSize(String filePath, int displayDecimals) async {
  // TODO: check for non existant file scenario before checking it length?
  int bytes = await File(filePath).length();
  if (bytes <= 0) return "0 B";
  const sizeSuffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return "${(bytes / pow(1024, i)).toStringAsFixed(displayDecimals)} ${sizeSuffixes[i]}";
}

///////////////////////////////////////////////////////////////////////////////
//
//                   sdk_install.dart - main function
//
///////////////////////////////////////////////////////////////////////////////

/// Main function to download and install a new Dart SDK.
///
/// Perform the download and install of the current 'stable' Dart SDK version.
/// Requires the current Dart SDK version available is provided to the function as [sdkVersion].
Future<void> upgradeSdk(String sdkVersion) async {
  stdout.writeln("\nDart SDK installation starting...");
  stdout.writeln(" [*]  Installing Dart SDK version: '${sdkVersion}'");
  final String downLoadUrl = createDownLoadUrl(sdkVersion);
  if (downLoadUrl.isEmpty) {
    stderr.writeln("\n\n [!] ERROR: Dart SDK download URL is missing\n");
    return;
  }
  // set up supporting paths and data before executing
  final String sdkInstallFile = installFileNameExtract(downLoadUrl, sdkVersion);
  final String destSdkDirectory = await setSdkInstallDir();
  final String existingDartSdkPath = await dartSdkPath();
  final String downLoadFilePath =
      p.join(await setDownLoadPath(), sdkInstallFile);
  if (existingDartSdkPath.isNotEmpty) {
    // existing Dart SDK found - check with user if should remove first?
    stdout.writeln(
        " [!]  Existing Dart SDK install found: '${existingDartSdkPath}'");
    if (yesNo(question: "Remove exising Dart SDK installation")) {
      stdout.writeln(" [*]  Deleting: ${existingDartSdkPath}");
      try {
        Directory(existingDartSdkPath).deleteSync(recursive: true);
        stdout.writeln(" [✔]  Removal successful.");
      } catch (err) {
        stderr.writeln(
            "\n\n [!] ERROR: unable to remove Dart SDK directory: '${err}'.\n\n");
        return;
      }
    } else {
      stderr.writeln(
          "\n [!] ERROR: unable to upgrade as existing Dart SDK install exists.\n\n");
      return;
    }
  }
  stdout.writeln(" [*]  Dart SDK download URL: ${downLoadUrl}");
  stdout.writeln(" [*]  Dart SDk install file: ${sdkInstallFile}");
  stdout.writeln(" [*]  Dart SDk install directory: ${destSdkDirectory}");
  stdout.writeln(" [*]  Dart SDK download destination: ${downLoadFilePath}");
  // check for an existing downloaded file - use if exists otherwise download new.
  if (await File(downLoadFilePath).exists()) {
    stdout.writeln(
        " [!]  Re-using found previously downloaded file: ${downLoadFilePath}");
  } else {
    if (!await downloadSDk(downLoadFilePath, downLoadUrl)) {
      stderr.writeln("\n\n [!] ERROR: Dart SDK download failed\n");
      return;
    }
    stdout.writeln(" [✔]  Dart SDK download completed successfully");
  }
  // get the download files size and display it for info
  stdout.writeln(
      " [*]  Dart SDK download file size: ${await getFileSize(downLoadFilePath, 1)}");

  // start the unarchiving process
  stdout.writeln(
      " [*]  Unarchiving downloaded Dart SDK to destination: ${destSdkDirectory}");
  // if (!await unzipArchive(downLoadFilePath, destSdkDirectory)) {
  if (!unzipArchive2(downLoadFilePath, destSdkDirectory)) {
    stderr.writeln("\n\n [!] ERROR: Dart SDK unarchive process failed\n");
    return;
  }
  stdout.writeln(" [✔]  Dart SDK unarchive completed successfully");
  stdout.writeln(" [*]  Setting correct file permissions for unarchived files");
  await makeExecutable(File(p.join(destSdkDirectory, "dart-sdk/bin/dart")));
  await makeExecutable(
      File(p.join(destSdkDirectory, "dart-sdk/bin/dartaotruntime")));
  await makeExecutable(
      File(p.join(destSdkDirectory, "dart-sdk/bin/utils/gen_snapshot")));
  stdout.writeln(" [✔]  Installation of Dart SDK completed.\n");
  stdout.writeln(
      "\n [#]  Note: To disable Dart analytics reporting run:  dart --disable-analytics\n");
}
