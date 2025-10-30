#!/bin/bash

echo "🐼 Panda in the Garden - Flutter App Setup"
echo "=========================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Navigate to project directory
cd "$(dirname "$0")" || exit

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Check for connected devices
echo ""
echo "📱 Checking for connected devices..."
flutter devices

echo ""
echo "🚀 Setup complete!"
echo ""
echo "To run the app, use one of these commands:"
echo "  flutter run                    # Run on connected device"
echo "  flutter run -d chrome          # Run in Chrome (web)"
echo "  flutter run -d ios             # Run on iOS simulator"
echo "  flutter run -d android         # Run on Android emulator"
echo ""
echo "Test Credentials:"
echo "  🐼 Panda: panda@garden.com / panda123"
echo "  👤 Visitor: alice@example.com / visitor123"
echo ""
echo "Happy gardening! 🌳"
