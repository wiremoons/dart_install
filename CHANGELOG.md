## 0.8.2
- Correct comments in sdk_changelog.dart to reflect functios actual purpose
- In sdk_changelog.dart update methods for full changelog.md file and one with only the latest entry
- Removed glyphs from output messages so only simplier text base feedback is used
- general comments clean up
- Increment version to 0.8.2

## 0.8.1
- Fix Dart SDK removal checking steps to ensure the directory to be removed exists
- Increment version to 0.8.1

## 0.8.0
- Add new command line option for removal of the SDK install
- increment the version to reflect new functionality
- add new source code file 'sdk_remove.dart' for remove code
- update Githib Action to use Dart SDK 2.19.6

## 0.7.0
- New feature to display the Dart SDK Change Log details for current version
- Update version to v0.7.0 to reflect new feature change.
- New command line flag '-l' or '--changelog' to access new CHANGELOG.md display feature

## 0.6.0
- Improve the command line switch help descriptions
- Ensure either arm64 or x64 is selected as SDK download on macOS and Linux OS
- Improve some code comments for bettter clarity
- Update version to v0.6.0 to reflect above changes

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