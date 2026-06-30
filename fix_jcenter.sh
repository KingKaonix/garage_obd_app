#!/bin/bash
# Patch flutter_bluetooth_serial's build.gradle to remove jcenter() references
# jcenter() was removed in Gradle 8+ / AGP 9+
PACKAGE_DIR="$HOME/.pub-cache/hosted/pub.dev/flutter_bluetooth_serial-0.4.0"
BUILD_GRADLE="$PACKAGE_DIR/android/build.gradle"
if [ -f "$BUILD_GRADLE" ]; then
    echo "Patching flutter_bluetooth_serial build.gradle (jcenter -> mavenCentral)..."
    sed -i 's/jcenter()/mavenCentral()/g' "$BUILD_GRADLE"
    echo "Patched: $BUILD_GRADLE"
else
    echo "Build gradle not found at $BUILD_GRADLE"
fi
