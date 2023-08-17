## 0.9.7
- updates following upgrade to Dart DSK v3.1.0

## 0.9.6
- move duplicate functions to a single new file `sys_utils.dart`
- update `sdk_remove.dart`, `sdk_install.dart` and `sdk_version.dart` to remove duplicate function and use new `sys_utils.dart`
- Increment version to v0.9.6

## 0.9.5
- Fix identification of `HOME` location on Windows in `sdk_install.dart` and `sdk_remove.dart`
- Add error output if `PATH` is empty in `sdk_install.dart` and `sdk_remove.dart`
- Correct spelling typos in `sdk_install.dart` outputs
- Add install note to user about adding Dart DSK 'bin' locations (shown) to their PATH
- Add additional checks for install destination parameters - abort if errors found
- Increment version to v0.9.5
- Improve overall consistency of formatting for message output from `sdk_install.dart`

## 0.9.4
- Improve and fix path and delimiter handling so works cross platform in `sdk_install.dart`
- Increment version to v0.9.4
- Change install steps to only set exec permissions for files on non Windows platforms
- Use `Platform.pathSeparator` in `unzip.dart` to ensure cross platform support
- Update `CHANGELOG.md` format to improve readability

## 0.9.3
- Add to `.gitignore` for exclusion of binary files from Windows build output
- Improve and fix path and delimiter handling so works cross platform in `sdk_version.dart`
- Fix `dart_install -c` command on Windows so now works correctly
- Increment version to v0.9.3

## 0.9.2
- Update `.gitignore` to simplify the `key` exclusions
- Increment version to v0.9.2
- Fix comment typo in `bin/dart_install.dart`
- Fix checking env PATH on Windows as uses different delimiter to Unix

## 0.9.1
- Add Windows batch file to run the build commands: `win-build.bat`
- Fix type in word `running` in `build.sh` script
- Fix errors in this `CHANGELOG.md` file
- Increment version to v0.9.1

## 0.9.0
- For `-r / -remove` also remove any `$HOME/.dart` and `$HOME/.dart-tool` directories
- Improve output messages when running `-r / -remove`
- Increment version to v0.9.0

## 0.8.2
- Correct comments in `sdk_changelog.dart` to reflect the functions actual purpose
- In `sdk_changelog.dart` update the methods to provide either a copy of the Dart SDK `changelog.md` file, or just to show the latest entry only
- Removed glyphs from output messages so only simpler text base feedback is used
- general comments clean up
- Increment version to v0.8.2

## 0.8.1
- Fix Dart SDK removal checking steps to ensure the directory to be removed exists
- Increment version to 0.8.1

## 0.8.0
- Add new command line option for removal of the SDK install
- increment the version to reflect new functionality
- add new source code file `sdk_remove.dart` for new functionality
- update GitHub Action to use Dart SDK 2.19.6

## 0.7.0
- New feature to display the Dart SDK Change Log details for current version
- Update version to v0.7.0 to reflect new feature change.
- New command line flag `-l` or `--changelog` to access new Dart SDK CHANGELOG.md display feature

## 0.6.0
- Improve the command line switch help descriptions
- Ensure either arm64 or x64 is selected as SDK download on macOS and Linux OS
- Improve some code comments for better clarity
- Update version to v0.6.0 to reflect above changes

## 0.5.0
- Updated CI actions file to build with Dart SDK 2.19.2 to work with dav package
- Add step to create the ./build dir if it does not exist for the `build.sh` script
- Add updated packages used to support application (pubspec.lock)
- Add initial step to detect operating systems for Dart SDK downloads - work in progress
- Add step to update an pub packages before build in `build.sh` script

## 0.4.0
- Improve `-h / --help` output to include copyright and website link
- increase version `0.4.0` as feature complete and working
- remove `version.dart` and replace with package `https://pub.dev/packages/dav`

## 0.1.0 - 2022-11-27
* First pre-release creation of project
* Initial Git repo creation
* Create `version.dart` class as first working code
* Add a brief overview of the project purpose in the `README.md`