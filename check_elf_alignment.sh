#!/bin/bash

# check_elf_alignment.sh
# Checks if all .so files in an APK/AAB are 16KB page-aligned.
# Usage: 

# For a release APK:
# flutter build apk --release
# ./check_elf_alignment.sh build/app/outputs/flutter-apk/app-release.apk

# For an app bundle (AAB):
# flutter build appbundle --release
# ./check_elf_alignment.sh build/app/outputs/bundle/release/app-release.aab


if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-apk-or-aab>"
  exit 1
fi

FILE=$1
TEMP_DIR=$(mktemp -d)

trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Extracting $FILE..."
if [[ $FILE == *.apk ]] || [[ $FILE == *.aab ]]; then
  unzip -o -q "$FILE" -d "$TEMP_DIR"
else
  echo "Unsupported file type. Use .apk or .aab"
  exit 1
fi

# Search for readelf or llvm-readelf
READELF_BIN=$(which readelf || which llvm-readelf)

if [ -z "$READELF_BIN" ]; then
  # Try to find it in common NDK locations on macOS
  NDK_ROOT="$HOME/Library/Android/sdk/ndk"
  READELF_BIN=$(find "$NDK_ROOT" -name "llvm-readelf" | head -n 1)
fi

if [ -z "$READELF_BIN" ]; then
  echo "❌ Error: 'readelf' or 'llvm-readelf' not found."
  echo "Please install the Android NDK or 'binutils' (brew install binutils)."
  exit 1
fi

echo "Checking ELF alignment for $FILE using $READELF_BIN..."
echo "------------------------------------------------"

# Find all .so files
find "$TEMP_DIR" -name "*.so" | while read -r lib; do
  # Get the alignment of the first LOAD segment
  # 0x4000 = 16384 bytes = 16KB
  # 0x10000 = 65536 bytes = 64KB
  alignment_hex=$($READELF_BIN -l "$lib" | grep LOAD | head -n 1 | awk '{print $NF}')
  
  # Convert hex to decimal if needed
  if [[ $alignment_hex == 0x* ]]; then
    alignment_dec=$((alignment_hex))
  else
    alignment_dec=$alignment_hex
  fi

  lib_name=$(basename "$lib")
  if [ "$alignment_dec" -ge 16384 ]; then
    echo "✅ [PASS] $lib_name is aligned to $alignment_hex ($alignment_dec bytes)"
  else
    echo "❌ [FAIL] $lib_name is NOT 16KB aligned ($alignment_hex)"
  fi
done
