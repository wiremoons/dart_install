//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
/// Misc supporting functions to perform system utility actions in support of
/// the main application.
library;

///

// Disable some specific linting rules in this file only
// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_string_interpolations
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;

/// Set execute permissions on parameter [file].
///
/// Dart has no ability to change a file permissions so the Unix command line
/// program `chmod` is called instead. The provided [file] name has its
/// permissions set to `755`. Only executes the command on non Windows platforms.
/// Possible improvements: check file exists first; return OK or error record;
Future<void> makeExecutable(File file) async {
  if (!Platform.isWindows) {
    ProcessResult result = await Process.run("chmod", ["755", file.path]);
    if (result.exitCode != 0) {
      stderr.writeln(
          "\n\n [!] ERROR: failed to set execute file permissions for file: '${file}' due to: '${result.stderr}'");
    }
  }
}

/// Identify a suitable directory to download and save the Dart SDK archive file too.
///
/// Return the path to a directory to download the new Dart SDK install file into.
/// Will use [$HOME/scratch] by default - will create it if it does not exist.
Future<String> setDownLoadPath() async {
  final homePath = homePathLocation();
  //
  // check for $HOME/scratch - create it if does not exist
  final downLoadPath = p.join(homePath, "scratch");
  if (!await Directory(downLoadPath).exists()) {
    stdout.writeln(" [!]  Creating download directory: '${downLoadPath}'");
    await Directory(downLoadPath).create(recursive: true);
  }
  return downLoadPath;
}

/// Locate the Users 'HOME' or 'USERPROFILE' directory.
///
/// Check for an environment variable `%USERPROFILE%` on Windows or on other
/// systems use environment variable '$HOME' and return the result. On failure
/// return an empty string.
String homePathLocation() {
  // Account for no 'HOME' environment variable on Windows:
  final envHomePath = Platform.isWindows
      ? Platform.environment["USERPROFILE"]
      : Platform.environment["HOME"];
  if (envHomePath == null || envHomePath.isEmpty) {
    stderr.writeln(
        "\n  ERROR: either '\$HOME' or '%USERPROFILE%' not found in environment variables - deletion failure.");
    return "";
  }
  return envHomePath;
}

/// Show the size of a file with the correct suffix such as 'MB' or 'GB' etc
//
// For the provided filename and path check the file size and return it as a String
// with an appended suffix to reflect if it is 'MB', 'TB', etc.
Future<String> getFileSize(String filePath, int displayDecimals) async {
  // TODO: check for non existent file scenario before checking its length?
  int bytes = await File(filePath).length();
  if (bytes <= 0) return "0 B";
  const sizeSuffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return "${(bytes / pow(1024, i)).toStringAsFixed(displayDecimals)} ${sizeSuffixes[i]}";
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
    if (await exeFileExists(p.join(envDartSdkPath, "bin"))) {
      stderr.writeln(
          " [!]  WARNING: env 'DART_SDK' -> '${envDartSdkPath}' contains no 'dart' executable in a 'bin/' subdirectory");
    }
    // return what the user set anyway - as they know their computer best...
    return envDartSdkPath;
  }
  // Finding [DART_SDK] env failed!
  // check the environment [PATH] for 'dart' or 'dart.exe' file
  // Use [splitChar] as Windows and Unix delimit env PATH with ';' or ':'
  String splitChar = Platform.isWindows ? ";" : ":";
  final envPath = Platform.environment["PATH"]?.split(splitChar);
  if (envPath == null || envPath.isEmpty) {
    stderr.writeln("\n  ERROR: no 'PATH' environment variables found.");
    return "";
  }
  //
  // final path = envPath.firstWhere((path) => await exeFileExists(path), orElse: () => "");
  //
  // check each environment PATH entry for a dart file - return on first found
  for (final path in envPath) {
    if (await exeFileExists(path)) {
      // the dart executable is normally in the Dart SDK 'bin/' sub directory - so trim the path
      // Ensure the '/bin' or '\bin' element is managed cross platform
      String binValue = "${Platform.pathSeparator}bin";
      final idx = path.lastIndexOf(binValue);
      return idx == -1 ? path : path.substring(0, idx);
    }
  }
  return "";
}

/// Check the provided [dirPath] for a file named *dart.exe* or *dart*.
///
/// Confirm if the dart executable exists in the provided directory path [dirPath]
/// Additionally check if executing on Windows so [.exe] can be appended to [dart] first.
Future<bool> exeFileExists(String dirPath) async {
  // set correct dart executable name as different on Windows
  final dartExe = Platform.isWindows ? "dart.exe" : "dart";
  // check of the executable exists at the provided path
  final dartPath = File(p.join(dirPath, dartExe));
  return await dartPath.exists();
}
