import 'package:test/test.dart';
import 'package:dav/dav.dart';

void main() {
  group('Group of imported module test', () {
    final version = Dav(appVersion: "0.3.1");

    test('First Test', () {
      expect(version.toString(), contains("0.3.1"));
    });
  });
}
