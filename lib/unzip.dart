//
// Copyright 2023 Simon Rowe (simon@wiremoons.com).
//
/// Unzip an archive file
library;

import 'dart:io';
import 'package:archive/archive_io.dart';

/// Unzip the file [downLoadFilePath] to the local directory [destSdkDirectory].
///
/// Both the source [downLoadFilePath] and destination [destSdkDirectory] need to exist.
bool unzipArchive2(String downLoadFilePath, String destSdkDirectory) {
  // Read the Zip file from disk.
  final bytes = File(downLoadFilePath).readAsBytesSync();

  // Decode the Zip file
  final archive = ZipDecoder().decodeBytes(bytes);

  // Provide feedback to the user - as now updates for a while...
  stdout.write(" -->  Extracting Dart SDK install file... please wait");
  // Extract the contents of the Zip archive to disk.
  for (final file in archive) {
    final filename = file.name;
    if (file.isFile) {
      final data = file.content as List<int>;
      File("$destSdkDirectory${Platform.pathSeparator}$filename")
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      Directory("$destSdkDirectory${Platform.pathSeparator}$filename")
          .create(recursive: true);
    }
  }
  // clear the prior user update message now extract finished
  stdout.write("\r                                                      \r");
  return true;
}

/// Unzip the file [downLoadFilePath] to the local directory [destSdkDirectory].
///
/// Both the source [downLoadFilePath] and destination [destSdkDirectory] need to exist.
Future<bool> unzipArchive(
    String downLoadFilePath, String destSdkDirectory) async {
  stdout.write(" -->  Extracting Dart SDK install file... please wait");
  await extractFileToDisk(downLoadFilePath, destSdkDirectory);
  stdout.write("\r                                                      \r");
  return true;
}
