#!/bin/bash
# Patch flutter_bluetooth_serial's build.gradle for AGP 9+ compatibility
# 1. Replace jcenter() with mavenCentral() (jcenter was removed in Gradle 8+)
# 2. Add namespace (required by AGP 9+)
PACKAGE_DIR="$HOME/.pub-cache/hosted/pub.dev/flutter_bluetooth_serial-0.4.0"
BUILD_GRADLE="$PACKAGE_DIR/android/build.gradle"
if [ -f "$BUILD_GRADLE" ]; then
    echo "Patching flutter_bluetooth_serial build.gradle for AGP 9+..."
    
    # Replace jcenter with mavenCentral (idempotent)
    sed -i 's/jcenter()/mavenCentral()/g' "$BUILD_GRADLE"
    
    # Add namespace inside android block if not already present
    if ! grep -q "namespace " "$BUILD_GRADLE"; then
        sed -i '/^android {/a\    namespace "io.github.edufolly.flutterbluetoothserial"' "$BUILD_GRADLE"
    fi
    
    echo "✅ Patched: $BUILD_GRADLE"
else
    echo "Build gradle not found at $BUILD_GRADLE"
    find "$HOME/.pub-cache/hosted/pub.dev/" -path "*/flutter_bluetooth_serial*/android/build.gradle" 2>/dev/null
fi
