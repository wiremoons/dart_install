[![Dart](https://github.com/wiremoons/dart_install/actions/workflows/dart.yml/badge.svg)](https://github.com/wiremoons/dart_install/actions/workflows/dart.yml)

# Dart_Install

Command-line application to install the [Dart SDK](https://dart.dev/get-dart/archive) on 
a macOS system. Written in the [dart programming language](https://dart.dev/).

Project is just to try the language out and see how it fairs for building
system management scripts and tools. The task for the tool is not particularly
important - it was just the first one I thought of.


## Usage

Clone the repo to your computer:
```console
git clone git@github.com:wiremoons/dart_install.git
```

change into the cloned directory:
```console
cd dart_install
```

update required supporting packages:
```console
dart pub update
```

To execute the program as a script:
```dart
dart run
```

To build a compiled version into the `build/` directory:
```dart
dart compile exe -DDART_BUILD="Built on: $(date)" ./bin/dart_install.dart -o ./build/dart_install.exe
```

If you are using *macOS* or *Linux* you can run the above command using the `./buid.sh` script that is 
included in the repo.


## License

Project is open source and uses the [MIT License](./LICENSE).


