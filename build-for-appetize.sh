#!/bin/bash

# Build FlashcardFactory for Appetize.io
# This script builds the app for iOS Simulator and creates a zip file

set -e  # Exit on error

echo "🚀 Building FlashcardFactory for Appetize.io..."

# Configuration
WORKSPACE="FlashcardFactory.xcworkspace"
SCHEME="FlashcardFactory"
CONFIGURATION="Debug"
SDK="iphonesimulator"
BUILD_DIR="./build"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"

# Build for simulator
echo "🔨 Building for iOS Simulator..."
xcodebuild -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -sdk "$SDK" \
  -derivedDataPath "$BUILD_DIR" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  clean build

# Find the .app bundle
APP_PATH=$(find "$BUILD_DIR" -name "FlashcardFactory.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
  echo "❌ Error: Could not find FlashcardFactory.app"
  exit 1
fi

echo "✅ App built successfully at: $APP_PATH"

# Create zip file
ZIP_NAME="FlashcardFactory-appetize.zip"
echo "📦 Creating zip file: $ZIP_NAME"

cd "$(dirname "$APP_PATH")"
zip -r "../../../$ZIP_NAME" "FlashcardFactory.app"
cd - > /dev/null

echo ""
echo "✨ SUCCESS! ✨"
echo ""
echo "📱 Your app is ready for Appetize.io!"
echo "📦 Upload this file: $ZIP_NAME"
echo "🌐 Go to: https://appetize.io/upload"
echo ""
