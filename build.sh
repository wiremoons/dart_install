#!/usr/bin/env zsh
#
# Dart AOT Build file for 'dart_install'


##############################################################################
#  HELPER FUNCTION: check_status
#  Check to ensure any command run has a 0 exit code - otherwise abort
##############################################################################
check_status () {
  local LAST_EXIT_CODE=$?
  #printf "Exit code: '%s'\n" "$LAST_EXIT_CODE"
  if [[ $LAST_EXIT_CODE -ne 0 ]]; then
    printf "\n\n ❌ ERROR: last command failed with exit code: '%s'.\nABORT.\n\n" "$LAST_EXIT_CODE"
    exit -99
  fi
  return
}

printf "\n\nBuilding 'dart_install'...\n\n"
dart compile exe -DDART_BUILD="Built on: $(date)" ./bin/dart_install.dart -o ./build/dart_install
check_status
printf "\nbuild completed - see ./build/dart_install\n"
