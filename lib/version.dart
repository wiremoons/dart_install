
import 'dart:io';

class Version {

  late String _osVersion;
  late String _appVersion;
  late String _osName;
  late String _appName;
  late String _dartVersion;
  late String _computerName;
  late String _numberCpus;
  late String _systemLocale;
  late String _appLastModifiedOrBuilt;
  // Add a build time flag: dart compile exe -DDART_BUILD="Built on: $(date)" ./bin/dart_install.dart
  static const String _buildEnvData = String.fromEnvironment("DART_BUILD", defaultValue: "");
  static const String _buildMode = bool.fromEnvironment('dart.vm.product') ? "Release" : "Debug";
  // alternative Flutter build mode needs: import 'package:flutter/foundation.dart';
  //static const _buildMode = (kReleaseMode) ? "Release" : "Debug";

  Version({required String appVersion}) {
    _osName = _toCapitaliseOS(Platform.operatingSystem);
    _systemLocale = Platform.localeName;
    _appVersion = appVersion;
    _osVersion = Platform.operatingSystemVersion;
    _appName =  _getAppName();
    _dartVersion = Platform.version;
    _computerName = _getComputerName();
    _numberCpus = Platform.numberOfProcessors.toString();
    _appLastModifiedOrBuilt = (_buildEnvData.isNotEmpty) ? _buildEnvData : _getAppLastModified();
  }

  // formats operating system name
  String _toCapitaliseOS(String input) {
    if (input.isEmpty) return input;
    if (input.contains("macos")) {
      return input.substring(0,3) + input.substring(3,input.length).toUpperCase();
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  // check if running as a script or from a compiled exe
  bool _isScript() {
    return (Platform.executable.endsWith("dart")) ? true : false;
  }

  // provide application name (exe) or filename (script)
  String _getAppName() {
    return (_isScript()) ?
    Platform.script.pathSegments.last :
    Platform.resolvedExecutable.split("/").last;
  }

  // applications full path and name (exe) or full path and filename (script)
  String _getAppFullPath() {
    return (_isScript()) ?
    Platform.script.toFilePath() :
    Platform.resolvedExecutable;
  }

  // removes the '.local' on macos from the hostname
  String _getComputerName() {
    return (Platform.localHostname.endsWith(".local")) ?
    Platform.localHostname.split(".").first :
    Platform.localHostname;
  }

  // for a Dart script or where no '-DDART_BUILD' - get the last modified time stamp
  String _getAppLastModified() {
    // TODO: format data time string before returning
    return "Last modified on: ${File(_getAppFullPath()).lastModifiedSync().toLocal()}";
  }

  void display() {
    stdout.writeln("""
  '$_appName' is version: '$_appVersion' built in '$_buildMode' mode.
  $_appLastModifiedOrBuilt
  Running Dart version: '$_dartVersion'.
  Executing on computer '$_computerName' with '$_osName $_osVersion' with $_numberCpus CPUs.
  System locale is '$_systemLocale'.""");
  }

}


// dart compile exe -DDART_BUILD="Built on: $(date)" ./bin/dart_install.dart
// dart compile exe -DDART_BUILD="$(echo git rev-parse HEAD)" ./bin/dart_install.dart

// // Utility used by Version class methods
// extension StringExtension on String {
//   String toCapitaliseOS(String input) {
//   if (input.isEmpty) return input;
//   if (input.contains("macos")) {
//   return input.substring(0,3) + input.substring(3,input.length).toUpperCase();
//   }
//   return input[0].toUpperCase() + input.substring(1);
//   }
// }
