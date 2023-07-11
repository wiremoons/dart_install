@echo off
echo " [*]  Running 'dart pub update' to check packages are current..."
dart pub update
echo " [*]  Running 'dart format' to check source code files..."
dart format --output=none --set-exit-if-changed .
echo " [*]  Running 'dart analyse' to check source code files..."
dart analyze
echo " [*]  Building 'dart_install'..." 
dart compile exe -DDART_BUILD="Built on: $(date)" ./bin/dart_install.dart -o dart_install.exe
echo " [✔]  Build completed.  Run: ./dart_install.exe"
