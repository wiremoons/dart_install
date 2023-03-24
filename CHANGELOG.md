## 0.5.0
- Updated CI actions file to build with Dart SDK 2.19.2 to work with dav package
- Add step to create the ./build dir if it does not exist for the 'build.sh' script
- Add updated packages used to support application (pubspec.lock)
- Add initial step to detect operating systems for Dart SDK downloads - work in progress
- Add step to update an pub packages before build in 'build.sh' script

## 0.4.0
- Improve '-h / --help' output to include copyright and website link
- increase version '0.4.0' as feature complete and working
- remove 'version.dart' and replace with package 'https://pub.dev/packages/dav'

## 0.1.0 - 2022-11-27
* First pre-release creation of project
* Initial Git repo creation
* Create `version.dart` class as first working code
* Add a brief overview of the project purpose in the `README.md`