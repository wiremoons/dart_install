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

import 'dart:io';
import 'yesno.dart';
import 'unzip.dart';
import 'package:path/path.dart' as p;

// import local code
import 'package:dart_install/sys_utils.dart';

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

/// Check for and create if needed the Dart SDK install location of [HOME/.dart].
///
/// Provide the path to a directory to extract and install the new Dart SDK archive file into.
/// Will use [$HOME/.dart] by default - will create if it does not exist.
Future<String> setSdkInstallDir() async {
  // Account for no 'HOME' environment variable on Windows:
  final homePath = homePathLocation();
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
  stdout.writeln("\n  >>  Dart SDK installation starting...\n");
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
    if (yesNo(question: "Remove existing Dart SDK installation")) {
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
      // User responded 'No' to removal of existing Dart SDK install
      stderr.writeln(
          "\n [!] ERROR: unable to upgrade as existing Dart SDK install exists.\n\n");
      return;
    }
  }
  // Output a summary of key files and locations identified
  stdout.writeln(" [✔]  Key Dart SDK install parameters:");
  stdout.writeln(" [*]   > Dart SDK download URL:         ${downLoadUrl}");
  stdout.writeln(" [*]   > Dart SDk install file:         ${sdkInstallFile}");
  stdout.writeln(" [*]   > Dart SDk install directory:    ${destSdkDirectory}");
  stdout.writeln(" [*]   > Dart SDK download destination: ${downLoadFilePath}");
  // final checks to ensure can proceed
  if ((downLoadUrl.isEmpty) ||
      (sdkInstallFile.isEmpty) ||
      (destSdkDirectory.isEmpty) ||
      (!downLoadFilePath.contains("scratch"))) {
    stderr.writeln(
        "\n\n [!] ERROR: problem detected with the above parameters - Dart SDK install aborted.\n");
    return;
  }
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
  if (!Platform.isWindows) {
    stdout
        .writeln(" [*]  Setting correct file permissions for unarchived files");
    // Ensure the installed Dart SDK files to have executable permission as: 755.
    await makeExecutable(File(p.join(destSdkDirectory, "dart-sdk/bin/dart")));
    await makeExecutable(
        File(p.join(destSdkDirectory, "dart-sdk/bin/dartaotruntime")));
    await makeExecutable(
        File(p.join(destSdkDirectory, "dart-sdk/bin/utils/gen_snapshot")));
  }
  stdout.writeln(" [✔]  Installation of Dart SDK completed.\n");
  stdout.writeln("\n  >>  Post Install Suggestions:\n");
  stdout.writeln(
      " [#]  To disable Dart analytics reporting run:  dart --disable-analytics");
  stdout.writeln(
      " [#]  Ensure Dart SDK is in your PATH:  ${p.join(destSdkDirectory, "dart-sdk", "bin")}\n");
}
